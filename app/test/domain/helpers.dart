import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/models/portions.dart';

Portions p(Map<FoodGroup, double> m) => Portions(m);

Meal meal(
  String id,
  MealSlot slot,
  Map<FoodGroup, double> portions, {
  bool done = false,
  String? dish,
}) {
  return Meal(
    id: id,
    slot: slot,
    time: '08:00',
    dish: dish ?? 'Plato $id',
    portions: p(portions),
    done: done,
  );
}

EquivalentOption option(
  Map<FoodGroup, double> portions, {
  MealSlot slot = MealSlot.comida,
}) {
  return EquivalentOption(
    id: 'o-${portions.hashCode}',
    slot: slot,
    dish: 'Opcion',
    portions: p(portions),
  );
}

DayPlan day(DateTime date, List<Meal> meals) =>
    DayPlan(date: date, meals: meals);
