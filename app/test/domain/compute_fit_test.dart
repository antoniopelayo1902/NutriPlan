import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/data/mock/seed.dart';
import 'package:nutriplan/domain/errors.dart';
import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/fit.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/services/fit.dart';

import 'helpers.dart';

void main() {
  const FoodGroup c = FoodGroup.cereal;
  const FoodGroup a = FoodGroup.aoa;
  const FoodGroup g = FoodGroup.grasa;
  final targets = p(<FoodGroup, double>{c: 4, a: 3, g: 2});
  final d = DateTime(2026, 10, 8);

  DayPlan basic({bool cenaDone = false, bool desayunoDone = false}) =>
      day(d, <Meal>[
        meal('b', MealSlot.desayuno, <FoodGroup, double>{
          c: 1,
          a: 1,
        }, done: desayunoDone),
        meal('c', MealSlot.comida, <FoodGroup, double>{c: 2, a: 1, g: 1}),
        meal('n', MealSlot.cena, <FoodGroup, double>{
          c: 1,
          a: 1,
          g: 1,
        }, done: cenaDone),
      ]);

  test('computeFit: yes when nothing goes over', () {
    final day0 = basic();
    final r = computeFit(
      day0,
      day0.meals[1],
      option(<FoodGroup, double>{c: 2, a: 1, g: 1}),
      targets,
    );
    expect(r.fit, Fit.yes);
    expect(r.rebalance, isNull);
  });

  test('computeFit: target meal is excluded from the base total', () {
    final day0 = basic();
    // Replacing comida with the same portions must still fit exactly.
    final r = computeFit(
      day0,
      day0.meals[1],
      option(<FoodGroup, double>{c: 2, a: 1, g: 1}),
      targets,
    );
    expect(r.fit, Fit.yes);
  });

  test('computeFit: adjust when one group is over by <= 1 and another meal can give', () {
    final day0 = basic();
    final r = computeFit(
      day0,
      day0.meals[1],
      option(<FoodGroup, double>{c: 2, a: 1, g: 1.5}),
      targets,
    );
    expect(r.fit, Fit.adjust);
    expect(r.rebalance!.group, g);
    expect(r.rebalance!.amount, 0.5);
    // Latest slot first: cena before desayuno.
    expect(r.rebalance!.fromMealId, 'n');
  });

  test('computeFit: done meals are never used for rebalance', () {
    final day0 = basic(cenaDone: true);
    final r = computeFit(
      day0,
      day0.meals[1],
      option(<FoodGroup, double>{c: 2, a: 1, g: 1.5}),
      targets,
    );
    // Only desayuno is left and it holds no grasa: nothing to move.
    expect(r.fit, Fit.no);
  });

  test(
    'computeFit: rebalance skips done meals and picks the next candidate',
    () {
      final day0 = basic(cenaDone: true);
      final r = computeFit(
        day0,
        day0.meals[1],
        option(<FoodGroup, double>{c: 2.5, a: 1, g: 1}),
        targets,
      );
      expect(r.fit, Fit.adjust);
      expect(r.rebalance!.fromMealId, 'b');
      expect(r.rebalance!.group, c);
    },
  );

  test('computeFit: no when over by more than one portion', () {
    final day0 = basic();
    final r = computeFit(
      day0,
      day0.meals[1],
      option(<FoodGroup, double>{c: 4, a: 1, g: 1}),
      targets,
    );
    expect(r.fit, Fit.no);
  });

  test('computeFit: no when two groups are over', () {
    final day0 = basic();
    final r = computeFit(
      day0,
      day0.meals[1],
      option(<FoodGroup, double>{c: 3, a: 2, g: 1}),
      targets,
    );
    expect(r.fit, Fit.no);
  });

  test('computeFit: no when no other meal holds enough of the group', () {
    final day0 = day(d, <Meal>[
      meal('c', MealSlot.comida, <FoodGroup, double>{c: 2}),
      meal('n', MealSlot.cena, <FoodGroup, double>{c: 2}),
    ]);
    final r = computeFit(
      day0,
      day0.meals[0],
      option(<FoodGroup, double>{c: 2, g: 3}),
      targets,
    );
    expect(r.fit, Fit.no);
  });

  group('applySwapToDay', () {
    test('replaces dish and portions, sets swappedFrom, applies rebalance', () {
      final day0 = basic();
      final opt = option(<FoodGroup, double>{c: 2, a: 1, g: 1.5});
      final r = computeFit(day0, day0.meals[1], opt, targets);
      final next = applySwapToDay(day0, 'c', opt, r);
      expect(next.mealById('c').dish, 'Opcion');
      expect(next.mealById('c').swappedFrom, 'Plato c');
      expect(next.mealById('c').portions[g], 1.5);
      expect(next.mealById('n').portions[g], 0.5);
      // Done desayuno untouched, original day untouched.
      expect(next.mealById('b').portions, day0.mealById('b').portions);
      expect(day0.mealById('n').portions[g], 1);
    });

    test('keeps the original dish when swapping twice', () {
      final day0 = basic();
      final opt = option(<FoodGroup, double>{c: 1});
      final r = computeFit(day0, day0.meals[1], opt, targets);
      final once = applySwapToDay(day0, 'c', opt, r);
      final twice = applySwapToDay(
        once,
        'c',
        opt,
        computeFit(once, once.meals[1], opt, targets),
      );
      expect(twice.mealById('c').swappedFrom, 'Plato c');
    });

    test('rejects a "no" result', () {
      final day0 = basic();
      final opt = option(<FoodGroup, double>{c: 4});
      expect(
        () => applySwapToDay(day0, 'c', opt, const FitResult(Fit.no)),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('unknown meal id throws NotFoundError', () {
      final day0 = basic();
      final opt = option(<FoodGroup, double>{c: 1});
      expect(
        () => applySwapToDay(day0, 'zzz', opt, const FitResult(Fit.yes)),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('seeded data', () {
    test('today Comida has at least one yes, one adjust and one no option', () {
      final seed = SeedData.build(() => DateTime(2026, 10, 8, 10));
      final dayToday = seed.plan.dayOn(DateTime(2026, 10, 8))!;
      final comida = dayToday.meals.firstWhere(
        (m) => m.slot == MealSlot.comida,
      );
      final List<EquivalentOption> opts = seed.options[MealSlot.comida]!;
      expect(opts.length, 5);
      final fits = opts
          .map(
            (o) => computeFit(dayToday, comida, o, seed.plan.dailyTargets).fit,
          )
          .toSet();
      expect(fits, <Fit>{Fit.yes, Fit.adjust, Fit.no});
    });

    test('every slot has 5 options', () {
      final seed = SeedData.build(() => DateTime(2026, 10, 8));
      for (final MealSlot s in MealSlot.values) {
        expect(seed.options[s]!.length, 5);
      }
    });

    test('seeded days stay within the daily targets', () {
      final seed = SeedData.build(() => DateTime(2026, 10, 8));
      for (final day in seed.plan.days) {
        var total = p(<FoodGroup, double>{});
        for (final m in day.meals) {
          total = total + m.portions;
        }
        for (final grp in FoodGroup.values) {
          expect(
            total[grp] <= seed.plan.dailyTargets[grp],
            isTrue,
            reason: '${day.date} $grp',
          );
        }
      }
    });
  });
}
