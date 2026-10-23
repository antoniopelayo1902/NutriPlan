import '../errors.dart';
import '../models/equivalent_option.dart';
import '../models/fit.dart';
import '../models/food_group.dart';
import '../models/plan.dart';
import '../models/portions.dart';

/// Decides whether [alt] can replace [target] inside [day].
///
/// Deterministic rules:
/// 1. newTotal = portions of every meal of the day except [target], plus the
///    portions of [alt].
/// 2. over[g] = max(0, newTotal[g] - dailyTargets[g]). No group over: yes.
/// 3. Exactly one group over, by at most 1.0, and some OTHER not-done meal
///    holds at least that much of the group: adjust. The meal is the first
///    match in slot order, latest slot first (cena, comida, colacion,
///    desayuno). Done meals are never touched.
/// 4. Anything else: no.
FitResult computeFit(
  DayPlan day,
  Meal target,
  EquivalentOption alt,
  Portions dailyTargets,
) {
  _checkSwappable(target, alt);
  Portions total = alt.portions;
  for (final Meal m in day.meals) {
    if (m.id != target.id) total = total + m.portions;
  }

  final Map<FoodGroup, double> over = <FoodGroup, double>{};
  for (final FoodGroup g in FoodGroup.values) {
    final double excess = total[g] - dailyTargets[g];
    if (excess > 0) over[g] = excess;
  }
  if (over.isEmpty) return const FitResult(Fit.yes);
  if (over.length > 1) return const FitResult(Fit.no);

  final MapEntry<FoodGroup, double> only = over.entries.first;
  if (only.value > 1.0) return const FitResult(Fit.no);

  final List<Meal> candidates =
      day.meals.where((Meal m) => m.id != target.id && !m.done).toList()
        ..sort((Meal a, Meal b) => b.slot.index.compareTo(a.slot.index));
  for (final Meal m in candidates) {
    if (m.portions[only.key] >= only.value) {
      return FitResult(
        Fit.adjust,
        Rebalance(fromMealId: m.id, group: only.key, amount: only.value),
      );
    }
  }
  return const FitResult(Fit.no);
}

/// Pure: returns a new [DayPlan] with [alt] in place of the meal [mealId] and
/// the rebalance applied. Throws [DomainValidationError] for a "no" result.
DayPlan applySwapToDay(
  DayPlan day,
  String mealId,
  EquivalentOption alt,
  FitResult result,
) {
  if (result.fit == Fit.no) {
    throw const DomainValidationError('A "no" swap cannot be applied');
  }
  final Meal current = day.mealById(mealId);
  _checkSwappable(current, alt);
  DayPlan next = day.replaceMeal(
    current.copyWith(
      dish: alt.dish,
      portions: alt.portions,
      swappedFrom: current.swappedFrom ?? current.dish,
    ),
  );
  final Rebalance? r = result.rebalance;
  if (r != null) {
    final Meal from = next.mealById(r.fromMealId);
    if (from.done) {
      throw const DomainValidationError('Done meals cannot be rebalanced');
    }
    next = next.replaceMeal(
      from.copyWith(
        portions: from.portions.withGroup(
          r.group,
          from.portions[r.group] - r.amount,
        ),
      ),
    );
  }
  return next;
}

/// A meal that is already done is a record of what was eaten and must not
/// change; an option can only replace a meal of its own slot.
void _checkSwappable(Meal target, EquivalentOption alt) {
  if (target.done) {
    throw const DomainValidationError('A done meal cannot be swapped');
  }
  if (alt.slot != target.slot) {
    throw const DomainValidationError('Option slot does not match the meal');
  }
}
