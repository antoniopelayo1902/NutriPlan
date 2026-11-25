import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/application/nutri_plan_controller.dart';
import 'package:nutriplan/data/firestore/firestore_mappers.dart';
import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/models/portions.dart';
import 'package:nutriplan/domain/models/week_menu.dart';

EquivalentOption dish(MealSlot slot, String name, Map<FoodGroup, double> p) =>
    EquivalentOption(
      id: '${slot.name}-$name',
      slot: slot,
      dish: name,
      portions: Portions(p),
    );

final EquivalentOption huevo = dish(MealSlot.desayuno, 'Huevo', {
  FoodGroup.aoa: 1,
  FoodGroup.cereal: 2,
});
final EquivalentOption avena = dish(MealSlot.desayuno, 'Avena', {
  FoodGroup.cereal: 3,
});
final EquivalentOption pera = dish(MealSlot.colacion, 'Pera', {
  FoodGroup.fruta: 1,
});
final EquivalentOption pollo = dish(MealSlot.comida, 'Pollo', {
  FoodGroup.aoa: 3,
  FoodGroup.cereal: 2,
});
final EquivalentOption sopa = dish(MealSlot.cena, 'Sopa', {
  FoodGroup.verdura: 2,
});

/// Lunes con los cuatro tiempos y el resto de la semana copiado.
WeekMenu fullMenu() => WeekMenu()
    .withPick(0, huevo)
    .withPick(0, pera)
    .withPick(0, pollo)
    .withPick(0, sopa)
    .copyDayToWeek(0);

void main() {
  group('WeekMenu', () {
    test('a new menu is missing all 28 meals', () {
      expect(WeekMenu().missing, 28);
      expect(WeekMenu().complete, isFalse);
    });

    test('copying a day fills the whole week', () {
      final WeekMenu m = fullMenu();
      expect(m.complete, isTrue);
      expect(m.pick(6, MealSlot.comida)!.dish, 'Pollo');
    });

    test('minimum targets come from the heaviest day', () {
      final WeekMenu m = fullMenu().withPick(3, avena);
      final Portions min = m.minimumTargets;
      expect(min[FoodGroup.cereal], 5);
      expect(min[FoodGroup.aoa], 4);
      expect(min[FoodGroup.verdura], 2);
    });

    test('dayFor keeps meals whose dish did not change', () {
      final DateTime monday = DateTime(2026, 11, 23);
      final DayPlan first = fullMenu().dayFor(monday);
      final DayPlan marked = first.replaceMeal(
        first.meals.first.copyWith(done: true),
      );
      final DayPlan again = fullMenu().dayFor(monday, current: marked);
      expect(again.meals.first.done, isTrue);
      final DayPlan changed = fullMenu()
          .withPick(0, avena)
          .dayFor(monday, current: marked);
      expect(changed.meals.first.dish, 'Avena');
      expect(changed.meals.first.done, isFalse);
      expect(changed.meals.first.time, mealTimes[MealSlot.desayuno]);
    });

    test('survives the Firestore round trip', () {
      final WeekMenu m = fullMenu().withPick(2, avena);
      final WeekMenu back = FirestoreMappers.menuFromMap(
        FirestoreMappers.menuToMap(m),
      )!;
      expect(back.complete, isTrue);
      expect(back.pick(2, MealSlot.desayuno)!.dish, 'Avena');
      expect(back.pick(2, MealSlot.desayuno)!.portions, avena.portions);
    });
  });

  group('NutriPlanController', () {
    NutriPlanController build({WeekMenu? saved, List<WeekMenu>? published}) =>
        NutriPlanController(
          loadCatalog: () async => <MealSlot, List<EquivalentOption>>{
            MealSlot.desayuno: <EquivalentOption>[avena, huevo],
            MealSlot.colacion: <EquivalentOption>[pera],
            MealSlot.comida: <EquivalentOption>[pollo],
            MealSlot.cena: <EquivalentOption>[sopa],
          },
          loadMenu: () async => saved,
          publish: (WeekMenu m) async => published?.add(m),
        );

    test('cannot publish until the week is complete', () async {
      final List<WeekMenu> sent = <WeekMenu>[];
      final NutriPlanController c = build(published: sent);
      await c.load();
      expect(c.hasPlan, isFalse);
      c.pick(huevo);
      expect(await c.publish(), isFalse);
      c
        ..pick(pera)
        ..pick(pollo)
        ..pick(sopa)
        ..copyDayToWeek();
      expect(await c.publish(), isTrue);
      expect(sent.single.complete, isTrue);
      expect(c.hasPlan, isTrue);
    });

    test('picks go to the selected day', () async {
      final NutriPlanController c = build(saved: fullMenu());
      await c.load();
      expect(c.hasPlan, isTrue);
      c
        ..selectDay(4)
        ..pick(avena);
      expect(c.menu.pick(4, MealSlot.desayuno)!.dish, 'Avena');
      expect(c.menu.pick(3, MealSlot.desayuno)!.dish, 'Huevo');
    });
  });
}
