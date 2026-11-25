import '../../core/clock.dart';
import 'equivalent_option.dart';
import 'food_group.dart';
import 'plan.dart';
import 'portions.dart';

/// Hora de cada tiempo de comida en un plan nuevo.
const Map<MealSlot, String> mealTimes = <MealSlot, String>{
  MealSlot.desayuno: '08:00',
  MealSlot.colacion: '11:00',
  MealSlot.comida: '14:30',
  MealSlot.cena: '20:00',
};

/// Menú que arma el nutriólogo: un platillo del catálogo para cada tiempo
/// de comida de cada día (0 = lunes ... 6 = domingo). Se repite cada semana.
class WeekMenu {
  WeekMenu([Map<int, Map<MealSlot, EquivalentOption>> picks = const {}])
    : _picks = <int, Map<MealSlot, EquivalentOption>>{
        for (final MapEntry<int, Map<MealSlot, EquivalentOption>> e
            in picks.entries)
          e.key: Map<MealSlot, EquivalentOption>.unmodifiable(e.value),
      };

  static const int days = 7;

  final Map<int, Map<MealSlot, EquivalentOption>> _picks;

  /// Platillo elegido para [day] y [slot], o null si falta.
  EquivalentOption? pick(int day, MealSlot slot) => _picks[day]?[slot];

  /// Copia del menú con [option] en el día [day].
  WeekMenu withPick(int day, EquivalentOption option) =>
      WeekMenu(<int, Map<MealSlot, EquivalentOption>>{
        ..._picks,
        day: <MealSlot, EquivalentOption>{...?_picks[day], option.slot: option},
      });

  /// Copia del menú donde todos los días quedan igual que [day].
  WeekMenu copyDayToWeek(int day) =>
      WeekMenu(<int, Map<MealSlot, EquivalentOption>>{
        for (int d = 0; d < days; d++)
          d: <MealSlot, EquivalentOption>{...?_picks[day]},
      });

  /// Comidas que faltan por elegir en toda la semana.
  int get missing {
    int n = 0;
    for (int d = 0; d < days; d++) {
      for (final MealSlot s in MealSlot.values) {
        if (pick(d, s) == null) n++;
      }
    }
    return n;
  }

  bool get complete => missing == 0;

  /// Porciones del día más cargado: el plan diario no puede pedir menos.
  Portions get minimumTargets {
    final Map<FoodGroup, double> max = <FoodGroup, double>{};
    for (int d = 0; d < days; d++) {
      Portions total = Portions.zero;
      for (final EquivalentOption o
          in _picks[d]?.values ?? const <EquivalentOption>[]) {
        total = total + o.portions;
      }
      for (final FoodGroup g in FoodGroup.values) {
        if (total[g] > (max[g] ?? 0)) max[g] = total[g];
      }
    }
    return Portions(max);
  }

  /// Día [date] según el menú. Las comidas que no cambian de platillo se
  /// quedan como estaban en [current] para no borrar lo que ya marcó.
  DayPlan dayFor(DateTime date, {DayPlan? current}) {
    final int d = dateOnly(date).weekday - DateTime.monday;
    return DayPlan(
      date: date,
      meals: <Meal>[
        for (final MealSlot slot in MealSlot.values)
          _meal(d, slot, _currentMeal(current, slot)),
      ],
    );
  }

  Meal _meal(int d, MealSlot slot, Meal? current) {
    final EquivalentOption o = pick(d, slot)!;
    if (current != null && (current.swappedFrom ?? current.dish) == o.dish) {
      return current;
    }
    return Meal(
      id: 'd$d-${slot.name}',
      slot: slot,
      time: current?.time ?? mealTimes[slot]!,
      dish: o.dish,
      portions: o.portions,
    );
  }

  static Meal? _currentMeal(DayPlan? day, MealSlot slot) {
    for (final Meal m in day?.meals ?? const <Meal>[]) {
      if (m.slot == slot) return m;
    }
    return null;
  }
}
