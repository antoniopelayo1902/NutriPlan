import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/domain/errors.dart';
import 'package:nutriplan/domain/models/activity.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/measurement.dart';
import 'package:nutriplan/domain/models/patient.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/models/portions.dart';

import 'helpers.dart';

void main() {
  group('Portions', () {
    test('accepts non-negative multiples of 0.5', () {
      final x = p(<FoodGroup, double>{
        FoodGroup.cereal: 1.5,
        FoodGroup.fruta: 0,
      });
      expect(x[FoodGroup.cereal], 1.5);
      expect(x[FoodGroup.fruta], 0);
      expect(x[FoodGroup.leche], 0);
    });

    test('rejects negative values', () {
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: -0.5}),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('rejects values that are not multiples of 0.5', () {
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: 0.3}),
        throwsA(isA<DomainValidationError>()),
      );
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: 1.25}),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('rejects absurd values and negative zero', () {
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: 1e9}),
        throwsA(isA<DomainValidationError>()),
      );
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: -0.0}),
        throwsA(isA<DomainValidationError>()),
      );
      expect(
        p(<FoodGroup, double>{FoodGroup.cereal: 20})[FoodGroup.cereal],
        20,
      );
    });

    test('rejects NaN and infinity', () {
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: double.nan}),
        throwsA(isA<DomainValidationError>()),
      );
      expect(
        () => p(<FoodGroup, double>{FoodGroup.cereal: double.infinity}),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('add, subtract, equality and kcal', () {
      final a = p(<FoodGroup, double>{FoodGroup.cereal: 2, FoodGroup.fruta: 1});
      final b = p(<FoodGroup, double>{FoodGroup.cereal: 1});
      expect((a + b)[FoodGroup.cereal], 3);
      expect((a - b)[FoodGroup.cereal], 1);
      expect(() => b - a, throwsA(isA<DomainValidationError>()));
      expect(
        a == p(<FoodGroup, double>{FoodGroup.fruta: 1, FoodGroup.cereal: 2}),
        isTrue,
      );
      expect(
        a.hashCode,
        p(<FoodGroup, double>{FoodGroup.fruta: 1, FoodGroup.cereal: 2})
            .hashCode,
      );
      expect(a.kcal, 2 * 70 + 60);
      expect(a.totalPortions, 3);
      expect(Portions.zero.isEmpty, isTrue);
      expect(a.entries.first.key, FoodGroup.fruta);
    });

    test('kcal per portion follows SMAE', () {
      expect(FoodGroup.values.map((g) => g.kcalPerPortion).toList(), <int>[
        25,
        60,
        70,
        55,
        120,
        95,
        45,
        40,
      ]);
    });
  });

  group('Meal', () {
    test('valid construction', () {
      final m = meal('m1', MealSlot.cena, <FoodGroup, double>{});
      expect(m.swapped, isFalse);
      expect(m.copyWith(done: true).done, isTrue);
    });

    test('empty id is rejected', () {
      expect(
        () => meal('', MealSlot.cena, <FoodGroup, double>{}),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('time must be HH:mm', () {
      for (final bad in <String>['8:00', '24:00', '12:60', 'abc', '']) {
        expect(
          () => Meal(
            id: 'x',
            slot: MealSlot.cena,
            time: bad,
            dish: 'd',
            portions: Portions.zero,
          ),
          throwsA(isA<DomainValidationError>()),
          reason: bad,
        );
      }
    });

    test('day rejects duplicate meal ids', () {
      expect(
        () => day(DateTime(2026, 1, 1), <Meal>[
          meal('a', MealSlot.cena, <FoodGroup, double>{}),
          meal('a', MealSlot.comida, <FoodGroup, double>{}),
        ]),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('unknown meal id throws NotFoundError', () {
      final d = day(DateTime(2026, 1, 1), <Meal>[]);
      expect(() => d.mealById('nope'), throwsA(isA<NotFoundError>()));
    });
  });

  group('Activity', () {
    test('minutes must be 1..600', () {
      ActivityLog make(int minutes) => ActivityLog(
        id: 'l',
        patientId: 'p',
        date: DateTime(2026, 1, 1),
        kind: ActivityKind.yoga,
        minutes: minutes,
        kcal: 10,
      );
      expect(make(1).minutes, 1);
      expect(make(600).minutes, 600);
      expect(() => make(0), throwsA(isA<DomainValidationError>()));
      expect(() => make(601), throwsA(isA<DomainValidationError>()));
      expect(() => make(-5), throwsA(isA<DomainValidationError>()));
    });

    test('empty ids are rejected', () {
      expect(
        () => ActivityLog(
          id: '',
          patientId: 'p',
          date: DateTime(2026, 1, 1),
          kind: ActivityKind.yoga,
          minutes: 10,
          kcal: 10,
        ),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('kcal is minutes times kcalPerMin', () {
      final t = ActivityType(
        kind: ActivityKind.bici,
        defaultMin: 40,
        kcalPerMin: 7,
      );
      expect(t.kcalFor(40), 280);
    });

    test('goal and types validate', () {
      expect(
        () => ActivityGoal(sessions: 0, minutes: 10, types: const []),
        throwsA(isA<DomainValidationError>()),
      );
      expect(
        () =>
            ActivityType(kind: ActivityKind.yoga, defaultMin: 0, kcalPerMin: 3),
        throwsA(isA<DomainValidationError>()),
      );
      final goal = ActivityGoal(
        sessions: 1,
        minutes: 10,
        types: [
          ActivityType(kind: ActivityKind.yoga, defaultMin: 30, kcalPerMin: 3),
        ],
      );
      expect(goal.typeOf(ActivityKind.yoga).defaultMin, 30);
      expect(
        () => goal.typeOf(ActivityKind.bici),
        throwsA(isA<NotFoundError>()),
      );
    });
  });

  group('Patient and measurement', () {
    test('initials', () {
      final pat = Patient(
        id: '1',
        name: 'Laura Méndez',
        birthDate: DateTime(1990),
        sex: 'F',
        objective: 'x',
        nutritionistId: 'n',
      );
      expect(pat.initials, 'LM');
    });

    test('patient requires id and name', () {
      expect(
        () => Patient(
          id: '',
          name: 'A',
          birthDate: DateTime(1990),
          sex: 'F',
          objective: 'x',
          nutritionistId: 'n',
        ),
        throwsA(isA<DomainValidationError>()),
      );
      expect(
        () => Nutritionist(id: '', name: 'x'),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('measurement rejects non-positive values and empty ids', () {
      Measurement make({double weight = 70, String id = 'm'}) => Measurement(
        id: id,
        patientId: 'p',
        date: DateTime(2026, 6, 1),
        weightKg: weight,
        heightM: 1.6,
        bodyFatPct: 25,
        muscleKg: 20,
      );
      expect(make().weightKg, 70);
      expect(() => make(weight: 0), throwsA(isA<DomainValidationError>()));
      expect(() => make(weight: -1), throwsA(isA<DomainValidationError>()));
      expect(() => make(id: ''), throwsA(isA<DomainValidationError>()));
    });
  });
}
