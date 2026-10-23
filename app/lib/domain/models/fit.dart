import 'food_group.dart';

/// Traffic-light result of trying an alternative in a day.
enum Fit { yes, adjust, no }

/// Move [amount] portions of [group] out of meal [fromMealId].
class Rebalance {
  const Rebalance({
    required this.fromMealId,
    required this.group,
    required this.amount,
  });

  final String fromMealId;
  final FoodGroup group;
  final double amount;
}

class FitResult {
  const FitResult(this.fit, [this.rebalance]);

  final Fit fit;
  final Rebalance? rebalance;
}
