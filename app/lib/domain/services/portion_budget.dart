import '../models/food_group.dart';
import '../models/plan.dart';
import '../models/portions.dart';

class BudgetRow {
  const BudgetRow({
    required this.group,
    required this.consumed,
    required this.target,
  });

  final FoodGroup group;
  final double consumed;
  final double target;

  bool get over => consumed > target;
}

class PortionBudget {
  const PortionBudget({required this.rows, required this.pctCovered});

  final List<BudgetRow> rows;

  /// Rounded half-up integer, 0..100.
  final int pctCovered;
}

/// Half-up rounding of a non-negative ratio expressed as a percentage.
int roundPct(double numerator, double denominator) {
  if (denominator <= 0) return 0;
  return (numerator * 100 / denominator + 0.5).floor();
}

/// Consumed (done meals) versus daily targets for the budgeted groups.
/// pctCovered = sum(min(consumed, target)) / sum(target).
PortionBudget computeBudget(DayPlan day, Portions targets) {
  Portions consumed = Portions.zero;
  for (final Meal m in day.meals) {
    if (m.done) consumed = consumed + m.portions;
  }
  final List<BudgetRow> rows = <BudgetRow>[
    for (final FoodGroup g in FoodGroup.budgeted)
      BudgetRow(group: g, consumed: consumed[g], target: targets[g]),
  ];
  double covered = 0;
  double sumTarget = 0;
  for (final BudgetRow r in rows) {
    covered += r.consumed < r.target ? r.consumed : r.target;
    sumTarget += r.target;
  }
  return PortionBudget(rows: rows, pctCovered: roundPct(covered, sumTarget));
}
