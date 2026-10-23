import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/domain/models/activity.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/measurement.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/models/portions.dart';
import 'package:nutriplan/domain/services/activity_summary.dart';
import 'package:nutriplan/domain/services/adherence.dart';
import 'package:nutriplan/domain/services/measurement_trend.dart';
import 'package:nutriplan/domain/services/portion_budget.dart';
import 'package:nutriplan/domain/services/progress.dart';

import 'helpers.dart';

// Monday 5 Oct 2026 .. Sunday 11 Oct 2026.
DateTime dayOf(int i) => DateTime(2026, 10, 5 + i);

DayPlan mk(
  int i,
  List<bool> done, {
  List<String>? dishes,
  List<bool>? swapped,
}) {
  const slots = MealSlot.values;
  return day(dayOf(i), <Meal>[
    for (int k = 0; k < done.length; k++)
      Meal(
        id: 'd$i-$k',
        slot: slots[k % 4],
        time: '08:00',
        dish: dishes == null ? 'plato-$i-$k' : dishes[k],
        portions: Portions.zero,
        done: done[k],
        swappedFrom: (swapped != null && swapped[k]) ? 'original' : null,
      ),
  ]);
}

Plan planOf(List<DayPlan> days, {int prev = 50}) => Plan(
  id: 'p',
  patientId: 'pt',
  nutritionistId: 'n',
  publishedAt: dayOf(0),
  weeks: 4,
  dailyTargets: Portions.zero,
  days: days,
  activityGoal: ActivityGoal(sessions: 5, minutes: 150, types: const []),
  previousWeekAdherence: prev,
);

void main() {
  group('portion budget', () {
    final targets = p(<FoodGroup, double>{
      FoodGroup.verdura: 4,
      FoodGroup.fruta: 2,
      FoodGroup.cereal: 6,
      FoodGroup.azucar: 3,
    });

    test('budget: 0 meals done gives 0% and 7 rows without azucar', () {
      final b = computeBudget(
        day(dayOf(0), <Meal>[
          meal('a', MealSlot.desayuno, <FoodGroup, double>{
            FoodGroup.cereal: 2,
          }),
        ]),
        targets,
      );
      expect(b.pctCovered, 0);
      expect(b.rows.length, 7);
      expect(b.rows.any((r) => r.group == FoodGroup.azucar), isFalse);
      expect(b.rows.every((r) => r.consumed == 0), isTrue);
    });

    test('budget: all done covers every target', () {
      final b = computeBudget(
        day(dayOf(0), <Meal>[
          meal('a', MealSlot.desayuno, <FoodGroup, double>{
            FoodGroup.verdura: 4,
            FoodGroup.fruta: 2,
            FoodGroup.cereal: 6,
          }, done: true),
        ]),
        targets,
      );
      expect(b.pctCovered, 100);
      expect(b.rows.any((r) => r.over), isFalse);
    });

    test('budget: over target flags the row and caps coverage at 100', () {
      final b = computeBudget(
        day(dayOf(0), <Meal>[
          meal('a', MealSlot.desayuno, <FoodGroup, double>{
            FoodGroup.verdura: 6,
            FoodGroup.fruta: 2,
            FoodGroup.cereal: 6,
          }, done: true),
        ]),
        targets,
      );
      final verdura = b.rows.firstWhere((r) => r.group == FoodGroup.verdura);
      expect(verdura.over, isTrue);
      expect(b.pctCovered, 100);
    });

    test('budget: only done meals count and percent rounds half-up', () {
      // covered = 1 of 12 target portions = 8.33% -> 8
      final b = computeBudget(
        day(dayOf(0), <Meal>[
          meal('a', MealSlot.desayuno, <FoodGroup, double>{
            FoodGroup.cereal: 1,
          }, done: true),
          meal('b', MealSlot.comida, <FoodGroup, double>{FoodGroup.cereal: 5}),
        ]),
        targets,
      );
      expect(b.pctCovered, 8);
    });

    test('roundPct rounds half up and guards zero denominators', () {
      expect(roundPct(1, 8), 13); // 12.5 -> 13
      expect(roundPct(1, 3), 33);
      expect(roundPct(2, 3), 67);
      expect(roundPct(1, 0), 0);
    });
  });

  group('adherence', () {
    final today = dayOf(2); // Wednesday

    test('future days are always pending, even if marked done', () {
      final d = mk(4, <bool>[true, true]);
      expect(dayStatus(d, today), DayStatus.pending);
    });

    test('day status complete, partial, pending', () {
      expect(dayStatus(mk(0, <bool>[true, true]), today), DayStatus.complete);
      expect(dayStatus(mk(0, <bool>[true, false]), today), DayStatus.partial);
      expect(dayStatus(mk(0, <bool>[false, false]), today), DayStatus.pending);
      expect(dayStatus(day(dayOf(0), <Meal>[]), today), DayStatus.pending);
    });

    test('day adherence percent', () {
      expect(dayAdherencePct(mk(0, <bool>[true, false, false])), 33);
      expect(dayAdherencePct(mk(0, <bool>[true, true, true, true])), 100);
    });

    test('week adherence only counts days up to and including today', () {
      final plan = planOf(<DayPlan>[
        mk(0, <bool>[true, true]),
        mk(1, <bool>[true, false]),
        mk(2, <bool>[false, false]),
        mk(3, <bool>[true, true]), // future: ignored
      ]);
      // 3 done of 6 meals up to Wednesday
      expect(weekAdherence(plan, today), 50);
    });

    test('week adherence is 0 when nothing has happened yet', () {
      final plan = planOf(<DayPlan>[
        mk(5, <bool>[true]),
      ]);
      expect(weekAdherence(plan, today), 0);
    });

    test('a swapped meal that is done counts fully', () {
      final plan = planOf(<DayPlan>[
        mk(
          0,
          <bool>[true, true],
          swapped: <bool>[true, false],
          dishes: <String>['a', 'b'],
        ),
      ]);
      expect(weekAdherence(plan, today), 100);
    });

    test('delta versus previous week is in points', () {
      expect(adherenceDelta(72, 68), 4);
      expect(adherenceDelta(60, 68), -8);
    });
  });

  group('progress', () {
    final today = dayOf(3); // Thursday

    test('streak ends today when today is complete', () {
      final plan = planOf(<DayPlan>[
        mk(0, <bool>[false, true]),
        mk(1, <bool>[true, true]),
        mk(2, <bool>[true, true]),
        mk(3, <bool>[true, true]),
      ]);
      expect(currentStreak(plan, today), 3);
    });

    test('streak when today is incomplete ends yesterday', () {
      final plan = planOf(<DayPlan>[
        mk(0, <bool>[true, true]),
        mk(1, <bool>[true, true]),
        mk(2, <bool>[true, true]),
        mk(3, <bool>[true, false]),
      ]);
      expect(currentStreak(plan, today), 3);
    });

    test('streak is zero when yesterday is not complete and today neither', () {
      final plan = planOf(<DayPlan>[
        mk(2, <bool>[true, false]),
        mk(3, <bool>[false, false]),
      ]);
      expect(currentStreak(plan, today), 0);
    });

    test('streak stops at the first gap', () {
      final plan = planOf(<DayPlan>[
        mk(0, <bool>[true, true]),
        mk(1, <bool>[false, true]),
        mk(2, <bool>[true, true]),
        mk(3, <bool>[false, false]),
      ]);
      expect(currentStreak(plan, today), 1);
    });

    test('variety counts distinct dishes among done meals', () {
      final plan = planOf(<DayPlan>[
        mk(0, <bool>[true, true, false], dishes: <String>['a', 'b', 'c']),
        mk(1, <bool>[true, true, true], dishes: <String>['a', 'd', 'e']),
      ]);
      expect(varietyCount(plan), 4);
    });

    test('swap count counts meals with swappedFrom', () {
      final plan = planOf(<DayPlan>[
        mk(
          0,
          <bool>[true, true],
          swapped: <bool>[true, false],
          dishes: <String>['a', 'b'],
        ),
        mk(
          1,
          <bool>[false, false],
          swapped: <bool>[true, true],
          dishes: <String>['a', 'b'],
        ),
      ]);
      expect(swapCount(plan), 3);
    });

    test('achievements follow their thresholds', () {
      final plan = planOf(<DayPlan>[
        mk(
          0,
          <bool>[true, true, true],
          dishes: <String>['a', 'b', 'c'],
          swapped: <bool>[true, false, false],
        ),
        mk(1, <bool>[true, true, true], dishes: <String>['d', 'e', 'f']),
        mk(2, <bool>[true, true, true], dishes: <String>['g', 'h', 'i']),
        mk(3, <bool>[true, true, true], dishes: <String>['j', 'k', 'l']),
      ]);
      expect(achievements(plan, today), Achievement.values);
      expect(
        achievements(
          planOf(<DayPlan>[
            mk(3, <bool>[false]),
          ]),
          today,
        ),
        isEmpty,
      );
    });
  });

  group('activity summary', () {
    final goal = ActivityGoal(sessions: 5, minutes: 150, types: const []);
    final today = DateTime(2026, 10, 8);
    ActivityLog log(String id, DateTime d, int min) => ActivityLog(
      id: id,
      patientId: 'p',
      date: d,
      kind: ActivityKind.caminata,
      minutes: min,
      kcal: min * 4,
    );

    test('week minutes sum the Mon-Sun week, pct is a rounded integer', () {
      final s = summarizeActivity(
        <ActivityLog>[
          log('1', DateTime(2026, 10, 5), 30),
          log('2', DateTime(2026, 10, 7), 45),
          log('3', DateTime(2026, 10, 4), 99), // previous Sunday: excluded
          log('4', DateTime(2026, 10, 12), 99), // next Monday: excluded
        ],
        goal,
        today,
      );
      expect(s.minutes, 75);
      expect(s.sessions, 2);
      expect(s.pct, 50);
      expect(s.minutesPerDay, <int>[30, 0, 45, 0, 0, 0, 0]);
      expect(s.goalMet, isFalse);
      expect(s.logs.first.id, '2'); // newest first
    });

    test('success threshold is at 100 percent', () {
      expect(
        summarizeActivity(
          <ActivityLog>[log('1', today, 149)],
          goal,
          today,
        ).goalMet,
        isFalse,
      );
      expect(
        summarizeActivity(
          <ActivityLog>[log('1', today, 150)],
          goal,
          today,
        ).goalMet,
        isTrue,
      );
      expect(
        summarizeActivity(<ActivityLog>[log('1', today, 200)], goal, today).pct,
        133,
      );
    });

    test('pct rounds to the nearest integer', () {
      expect(
        summarizeActivity(<ActivityLog>[log('1', today, 100)], goal, today).pct,
        67,
      );
    });

    test('empty week', () {
      final s = summarizeActivity(const <ActivityLog>[], goal, today);
      expect(s.minutes, 0);
      expect(s.pct, 0);
      expect(s.logs, isEmpty);
    });
  });

  group('measurement trend', () {
    Measurement m(
      int month,
      double weight,
      double fat,
      double muscle,
      double waist,
      double? tri,
    ) {
      return Measurement(
        id: 'm$month',
        patientId: 'p',
        date: DateTime(2026, month, 10),
        weightKg: weight,
        heightM: 1.6,
        bodyFatPct: fat,
        muscleKg: muscle,
        skinfolds: Skinfolds(tricipital: tri),
        circumferences: Circumferences(cintura: waist),
      );
    }

    final all = <Measurement>[
      m(8, 72, 27, 22.5, 81, 21),
      m(6, 73, 29, 22, 84, 24),
      m(9, 71.2, 26, 23, 79.5, 19.5),
    ];

    test('delta is latest minus first month, regardless of input order', () {
      final t = trendFor(all, MeasurementMetric.weight)!;
      expect(t.first, 73);
      expect(t.latest, 71.2);
      expect(t.delta, closeTo(-1.8, 1e-9));
      expect(t.dates.first.month, 6);
    });

    test('weight, fat, waist and tricipital improve when they go down', () {
      for (final metric in <MeasurementMetric>[
        MeasurementMetric.weight,
        MeasurementMetric.bodyFat,
        MeasurementMetric.waist,
        MeasurementMetric.tricipital,
      ]) {
        expect(trendFor(all, metric)!.improving, isTrue, reason: metric.name);
        expect(metric.improvesWhenDown, isTrue);
      }
    });

    test('muscle improves when it goes up', () {
      final t = trendFor(all, MeasurementMetric.muscle)!;
      expect(t.delta, greaterThan(0));
      expect(t.improving, isTrue);
      expect(MeasurementMetric.muscle.improvesWhenDown, isFalse);
    });

    test('reversed directions are not improving', () {
      final worse = <Measurement>[
        m(6, 70, 25, 23, 80, 20),
        m(9, 72, 27, 22, 82, 22),
      ];
      for (final metric in MeasurementMetric.values) {
        expect(
          trendFor(worse, metric)!.improving,
          isFalse,
          reason: metric.name,
        );
      }
    });

    test('missing values are skipped and empty input yields null', () {
      final partial = <Measurement>[
        m(6, 70, 25, 23, 80, null),
        m(9, 69, 24, 23.5, 78, 18),
      ];
      expect(trendFor(partial, MeasurementMetric.tricipital)!.values, <double>[
        18,
      ]);
      expect(trendFor(const <Measurement>[], MeasurementMetric.weight), isNull);
      expect(
        trendFor(<Measurement>[
          m(6, 70, 25, 23, 80, null),
        ], MeasurementMetric.tricipital),
        isNull,
      );
    });
  });
}
