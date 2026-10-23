import '../core/clock.dart';
import '../core/scenario.dart';
import '../domain/models/food_group.dart';
import '../domain/models/portions.dart';
import '../domain/errors.dart';
import '../domain/models/equivalent_option.dart';
import '../domain/models/fit.dart';
import '../domain/models/plan.dart';
import '../domain/repositories/plan_repository.dart';
import '../domain/services/fit.dart';

class InMemoryPlanRepository implements PlanRepository {
  InMemoryPlanRepository({
    required Plan plan,
    required Map<MealSlot, List<EquivalentOption>> options,
    required this.clock,
    this.scenario = Scenario.normal,
    this.latency = Duration.zero,
  }) : _plan = plan,
       _options = options;

  Plan _plan;
  final Map<MealSlot, List<EquivalentOption>> _options;
  final Clock clock;
  final Scenario scenario;
  final Duration latency;
  bool _failedOnce = false;

  /// Test hook: the next write throws a [RepositoryError].
  bool failNextWrite = false;

  @override
  Future<Plan?> loadPlan() async {
    await Future<void>.delayed(latency);
    if (scenario == Scenario.error && !_failedOnce) {
      _failedOnce = true;
      throw const RepositoryError('plan unavailable');
    }
    if (scenario == Scenario.noPlan) return null;
    return _plan;
  }

  @override
  Future<void> saveDay(DayPlan day) async {
    await Future<void>.delayed(latency);
    if (failNextWrite) {
      failNextWrite = false;
      throw const RepositoryError('write failed');
    }
    final DayPlan? existing = _plan.dayOn(day.date);
    if (existing == null) throw const NotFoundError('Day not found');
    final Set<String> known = existing.meals.map((Meal m) => m.id).toSet();
    final Set<String> given = day.meals.map((Meal m) => m.id).toSet();
    if (known.length != given.length || !known.containsAll(given)) {
      throw const NotFoundError('Meal not found');
    }
    _validateWrite(existing, day);
    _plan = _plan.replaceDay(day);
  }

  /// Server-side style invariants for a day write.
  ///
  /// Done flags may change on their own. Any change to dish, portions or
  /// swappedFrom must be exactly one equivalent swap, recomputed here with
  /// [computeFit] and [applySwapToDay]; the client never decides portions,
  /// rebalances or swappedFrom.
  void _validateWrite(DayPlan existing, DayPlan next) {
    final DateTime today = dateOnly(clock());
    final List<Meal> changed = <Meal>[];
    for (final Meal m in next.meals) {
      final Meal old = existing.mealById(m.id);
      if (m.slot != old.slot || m.time != old.time) {
        throw const DomainValidationError('Meal slot and time are fixed');
      }
      if (m.done && next.date.isAfter(today)) {
        throw const DomainValidationError('Future meals cannot be done');
      }
      if (!_sameContent(m, old)) {
        if (old.done) {
          throw const DomainValidationError('Done meals cannot change');
        }
        changed.add(m);
      }
    }
    if (changed.isNotEmpty && !_isServerSwap(existing, next, changed)) {
      throw const DomainValidationError('Unknown dish or portions');
    }
    Portions total = Portions.zero;
    for (final Meal m in next.meals) {
      total = total + m.portions;
    }
    for (final FoodGroup g in FoodGroup.values) {
      if (total[g] > _plan.dailyTargets[g]) {
        throw const DomainValidationError('Day exceeds the daily targets');
      }
    }
  }

  /// True when [next] equals the result of applying one listed option to one
  /// of the [changed] meals of [existing].
  bool _isServerSwap(DayPlan existing, DayPlan next, List<Meal> changed) {
    for (final Meal m in changed) {
      final Meal old = existing.mealById(m.id);
      for (final EquivalentOption o in _options[m.slot] ?? const []) {
        if (o.dish != m.dish || o.portions != m.portions) continue;
        final FitResult fit;
        final DayPlan expected;
        try {
          fit = computeFit(existing, old, o, _plan.dailyTargets);
          if (fit.fit == Fit.no) continue;
          expected = applySwapToDay(existing, m.id, o, fit);
        } on DomainValidationError {
          continue;
        }
        if (next.meals.every(
          (Meal n) => _sameContent(n, expected.mealById(n.id)),
        )) {
          return true;
        }
      }
    }
    return false;
  }

  static bool _sameContent(Meal a, Meal b) =>
      a.dish == b.dish &&
      a.portions == b.portions &&
      a.swappedFrom == b.swappedFrom;

  @override
  Future<List<EquivalentOption>> loadOptions(MealSlot slot) async {
    await Future<void>.delayed(latency);
    return List<EquivalentOption>.of(
      _options[slot] ?? const <EquivalentOption>[],
    );
  }
}
