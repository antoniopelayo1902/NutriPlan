import 'package:flutter/foundation.dart';

import '../core/clock.dart';
import '../domain/models/equivalent_option.dart';
import '../domain/models/fit.dart';
import '../domain/models/plan.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/services/adherence.dart';
import '../domain/services/fit.dart';
import '../domain/services/portion_budget.dart';
import '../domain/services/progress.dart';

/// Week plan state with optimistic writes. Actions never throw: failures
/// revert the change and set [error] (docs section 7, `_act`).
class PlanController extends ChangeNotifier {
  PlanController({required PlanRepository repository, required Clock clock})
    : _repository = repository,
      _clock = clock;

  final PlanRepository _repository;
  final Clock _clock;

  int _loadGeneration = 0;
  Future<void> _saveQueue = Future<void>.value();

  bool _loading = true;
  Object? _error;
  Plan? _plan;
  Map<MealSlot, List<EquivalentOption>> _options =
      const <MealSlot, List<EquivalentOption>>{};

  bool get loading => _loading;
  Object? get error => _error;
  bool get hasError => _error != null;
  Plan? get plan => _plan;

  DateTime get today => dateOnly(_clock());

  List<EquivalentOption> optionsFor(MealSlot slot) =>
      _options[slot] ?? const <EquivalentOption>[];

  DayPlan? get todayPlan => _plan?.dayOn(today);

  PortionBudget? get budget {
    final Plan? p = _plan;
    final DayPlan? d = todayPlan;
    if (p == null || d == null) return null;
    return computeBudget(d, p.dailyTargets);
  }

  int get weekAdherencePct {
    final Plan? p = _plan;
    return p == null ? 0 : weekAdherence(p, today);
  }

  int get adherenceDeltaPts {
    final Plan? p = _plan;
    return p == null
        ? 0
        : adherenceDelta(weekAdherence(p, today), p.previousWeekAdherence);
  }

  DayStatus statusOf(DayPlan day) => dayStatus(day, today);

  int get swaps => _plan == null ? 0 : swapCount(_plan!);
  int get variety => _plan == null ? 0 : varietyCount(_plan!);
  int get streak => _plan == null ? 0 : currentStreak(_plan!, today);
  List<Achievement> get earned =>
      _plan == null ? const <Achievement>[] : achievements(_plan!, today);

  /// [silent] vuelve a leer sin mostrar el esqueleto de carga (refresh).
  Future<void> load({bool silent = false}) async {
    final int generation = ++_loadGeneration;
    if (!silent) _loading = true;
    _error = null;
    notifyListeners();
    Plan? loaded;
    Object? failure;
    final Map<MealSlot, List<EquivalentOption>> opts =
        <MealSlot, List<EquivalentOption>>{};
    try {
      loaded = await _repository.loadPlan();
      if (loaded != null) {
        for (final MealSlot s in MealSlot.values) {
          opts[s] = await _repository.loadOptions(s);
        }
      }
    } catch (e) {
      failure = e;
    }
    // A newer load() superseded this one: drop its result.
    if (generation != _loadGeneration) return;
    if (failure != null) {
      _error = failure;
      // Si falla un refresh se queda el plan que ya se veía.
      if (!silent) _plan = null;
    } else {
      _plan = loaded;
      _options = opts;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> retry() => load();

  Future<void> refresh() => load(silent: true);

  /// Traffic-light result for [option] on the meal [mealId] of [date].
  FitResult? fitFor(DateTime date, String mealId, EquivalentOption option) {
    final Plan? p = _plan;
    final DayPlan? day = p?.dayOn(date);
    if (p == null || day == null) return null;
    try {
      return computeFit(day, day.mealById(mealId), option, p.dailyTargets);
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleDone(DateTime date, String mealId) async {
    // Future days cannot be pre-marked.
    if (dateOnly(date).isAfter(today)) return;
    try {
      await _commit(date, (DayPlan day) {
        final Meal meal = day.mealById(mealId);
        return day.replaceMeal(meal.copyWith(done: !meal.done));
      });
    } catch (e) {
      _fail(e);
    }
  }

  /// Applies [option]. Returns the fit result, or null if the action failed.
  /// A "no" result changes nothing.
  Future<FitResult?> applySwap(
    DateTime date,
    String mealId,
    EquivalentOption option,
  ) async {
    final FitResult? first = fitFor(date, mealId, option);
    if (first == null || _plan?.dayOn(date) == null) {
      _fail(StateError('swap target missing'));
      return null;
    }
    if (first.fit == Fit.no) return first;
    FitResult? applied;
    try {
      final bool ok = await _commit(date, (DayPlan day) {
        final FitResult? r = fitFor(date, mealId, option);
        if (r == null || r.fit == Fit.no) return null;
        applied = r;
        return applySwapToDay(day, mealId, option, r);
      });
      return ok ? applied : null;
    } catch (e) {
      _fail(e);
      return null;
    }
  }

  void _fail(Object e) {
    _error = e;
    notifyListeners();
  }

  /// Optimistic write of one day. Commits run strictly one after another so
  /// a failed earlier save can never revert over a later successful one.
  /// [build] derives the next day from the state current when its turn comes.
  Future<bool> _commit(DateTime date, DayPlan? Function(DayPlan) build) {
    final Future<bool> result = _saveQueue.then((_) => _run(date, build));
    _saveQueue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<bool> _run(DateTime date, DayPlan? Function(DayPlan) build) async {
    final Plan? current = _plan;
    final DayPlan? previous = current?.dayOn(date);
    if (current == null || previous == null) return false;
    final DayPlan? next = build(previous);
    if (next == null) return false;
    _plan = current.replaceDay(next);
    _error = null;
    notifyListeners();
    try {
      await _repository.saveDay(next);
      return true;
    } catch (e) {
      final Plan? now = _plan;
      if (now != null) _plan = now.replaceDay(previous);
      _error = e;
      notifyListeners();
      return false;
    }
  }
}
