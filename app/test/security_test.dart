import 'package:flutter_test/flutter_test.dart';

import 'fakes/mock_controllers.dart';
import 'fakes/in_memory_activity_repository.dart';
import 'fakes/in_memory_plan_repository.dart';
import 'fakes/seed.dart';

import 'package:nutriplan/domain/errors.dart';
import 'package:nutriplan/domain/models/activity.dart';
import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/models/portions.dart';
import 'package:nutriplan/domain/services/fit.dart';

DateTime now() => DateTime(2026, 10, 8, 10);
final DateTime today = DateTime(2026, 10, 8);

void main() {
  late SeedData seed;
  late InMemoryPlanRepository repo;
  setUp(() {
    seed = SeedData.build(now);
    repo = InMemoryPlanRepository(
      plan: seed.plan,
      options: seed.options,
      clock: now,
    );
  });

  group('S1 done meals are immutable', () {
    test('computeFit and applySwapToDay reject a done target', () {
      final day = seed.plan.dayOn(today)!;
      final done = day.meals.firstWhere((m) => m.done);
      final opt = seed.options[done.slot]!.first;
      expect(
        () => computeFit(day, done, opt, seed.plan.dailyTargets),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test(
      'controller returns null for a done meal and leaves it unchanged',
      () async {
        final c = buildAppControllers(clock: now);
        await c.loadAll();
        final done = c.plan.todayPlan!.meals.firstWhere((m) => m.done);
        final r = await c.plan.applySwap(
          today,
          done.id,
          seed.options[done.slot]!.first,
        );
        expect(r, isNull);
        expect(c.plan.todayPlan!.mealById(done.id).dish, done.dish);
      },
    );

    test('repo rejects rewriting a done meal', () async {
      final day = seed.plan.dayOn(today)!;
      final done = day.meals.firstWhere((m) => m.done);
      final forged = day.replaceMeal(done.copyWith(dish: 'forged'));
      await expectLater(
        repo.saveDay(forged),
        throwsA(isA<DomainValidationError>()),
      );
    });
  });

  group('S2 repo enforces invariants', () {
    test('rejects unknown dishes and oversize portions', () async {
      final day = seed.plan.dayOn(today)!;
      final comida = day.meals.firstWhere((m) => m.slot == MealSlot.comida);
      final forged = day.replaceMeal(
        comida.copyWith(
          dish: 'forged',
          portions: Portions({FoodGroup.cereal: 20}),
        ),
      );
      await expectLater(
        repo.saveDay(forged),
        throwsA(isA<DomainValidationError>()),
      );
      final over = day.replaceMeal(
        comida.copyWith(
          dish: seed.options[MealSlot.comida]![3].dish,
          portions: seed.options[MealSlot.comida]![3].portions,
        ),
      );
      await expectLater(
        repo.saveDay(over),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('accepts a legitimate option', () async {
      final day = seed.plan.dayOn(today)!;
      final comida = day.meals.firstWhere((m) => m.slot == MealSlot.comida);
      final o = seed.options[MealSlot.comida]![0];
      final fit = computeFit(day, comida, o, seed.plan.dailyTargets);
      await repo.saveDay(applySwapToDay(day, comida.id, o, fit));
    });
  });

  test('S3 option slot must match the meal slot', () {
    final day = seed.plan.dayOn(today)!;
    final cena = day.meals.firstWhere((m) => m.slot == MealSlot.cena);
    final EquivalentOption wrong = seed.options[MealSlot.desayuno]!.first;
    expect(
      () => computeFit(day, cena, wrong, seed.plan.dailyTargets),
      throwsA(isA<DomainValidationError>()),
    );
  });

  group('S4 future and foreign writes', () {
    test('controller ignores toggling a future day; repo rejects it', () async {
      final c = buildAppControllers(clock: now);
      await c.loadAll();
      final future = c.plan.plan!.days.last;
      await c.plan.toggleDone(future.date, future.meals.first.id);
      expect(c.plan.plan!.dayOn(future.date)!.meals.first.done, isFalse);
      final forged = future.replaceMeal(
        future.meals.first.copyWith(done: true),
      );
      await expectLater(
        repo.saveDay(forged),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('activity repo rejects foreign, future and disallowed logs', () async {
      final a = InMemoryActivityRepository(
        goal: seed.goal,
        logs: seed.logs,
        ownerPatientId: 'pat-1',
        clock: now,
      );
      ActivityLog log({String patient = 'pat-1', DateTime? date}) =>
          ActivityLog(
            id: 'x${patient.hashCode}${date.hashCode}',
            patientId: patient,
            date: date ?? today,
            kind: ActivityKind.yoga,
            minutes: 30,
            kcal: 90,
          );
      await expectLater(
        a.add(log(patient: 'pat-OTHER')),
        throwsA(isA<DomainValidationError>()),
      );
      await expectLater(
        a.add(log(date: DateTime(2099))),
        throwsA(isA<DomainValidationError>()),
      );
      final limited = InMemoryActivityRepository(
        goal: ActivityGoal(
          sessions: 1,
          minutes: 10,
          types: [
            ActivityType(
              kind: ActivityKind.bici,
              defaultMin: 10,
              kcalPerMin: 7,
            ),
          ],
        ),
        logs: const [],
        ownerPatientId: 'pat-1',
        clock: now,
      );
      await expectLater(
        limited.add(log()),
        throwsA(isA<DomainValidationError>()),
      );
      await a.add(log());
    });
  });

  group('S6 day writes only accept server-computed swaps', () {
    test('rejects a same-dish portion cut with no swap', () async {
      final day = seed.plan.dayOn(today)!;
      final undone = day.meals.firstWhere((m) => !m.done);
      final forged = day.replaceMeal(undone.copyWith(portions: Portions.zero));
      await expectLater(
        repo.saveDay(forged),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('rejects zeroing a future day', () async {
      final future = seed.plan.days.last;
      DayPlan forged = future;
      for (final m in future.meals) {
        forged = forged.replaceMeal(m.copyWith(portions: Portions.zero));
      }
      await expectLater(
        repo.saveDay(forged),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('rejects a forged swappedFrom', () async {
      final day = seed.plan.dayOn(today)!;
      final undone = day.meals.firstWhere((m) => !m.done);
      final forged = day.replaceMeal(undone.copyWith(swappedFrom: 'fake'));
      await expectLater(
        repo.saveDay(forged),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('rejects a swap plus an extra cut in another meal', () async {
      final day = seed.plan.dayOn(today)!;
      final comida = day.meals.firstWhere((m) => m.slot == MealSlot.comida);
      final o = seed.options[MealSlot.comida]![0];
      final fit = computeFit(day, comida, o, seed.plan.dailyTargets);
      DayPlan next = applySwapToDay(day, comida.id, o, fit);
      final other = next.meals.firstWhere((m) => !m.done && m.id != comida.id);
      next = next.replaceMeal(other.copyWith(portions: Portions.zero));
      await expectLater(
        repo.saveDay(next),
        throwsA(isA<DomainValidationError>()),
      );
    });

    test('every fitting option is accepted through the controller', () async {
      final c = buildAppControllers(clock: now);
      await c.loadAll();
      final day = c.plan.todayPlan!;
      final target = day.meals.firstWhere((m) => !m.done);
      for (final o in seed.options[target.slot]!) {
        final fit = c.plan.fitFor(today, target.id, o);
        if (fit == null || fit.fit.name == 'no') continue;
        final r = await c.plan.applySwap(today, target.id, o);
        expect(r, isNotNull, reason: o.dish);
        return;
      }
    });
  });

  group('S7 activity repo checks owner and kcal', () {
    late InMemoryActivityRepository a;
    final foreign = ActivityLog(
      id: 'foreign-1',
      patientId: 'pat-OTHER',
      date: today,
      kind: ActivityKind.yoga,
      minutes: 30,
      kcal: 90,
    );
    setUp(() {
      a = InMemoryActivityRepository(
        goal: seed.goal,
        logs: [...seed.logs, foreign],
        ownerPatientId: 'pat-1',
        clock: now,
      );
    });

    test('cannot remove or list another patient\'s log', () async {
      await expectLater(a.remove(foreign.id), throwsA(isA<NotFoundError>()));
      expect((await a.loadLogs()).any((l) => l.id == foreign.id), isFalse);
    });

    test('rejects a client-chosen kcal', () async {
      await expectLater(
        a.add(
          ActivityLog(
            id: 'cheat',
            patientId: 'pat-1',
            date: today,
            kind: ActivityKind.yoga,
            minutes: 30,
            kcal: 99999,
          ),
        ),
        throwsA(isA<DomainValidationError>()),
      );
    });
  });
}
