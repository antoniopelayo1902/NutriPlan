import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/application/app_controllers.dart';
import 'package:nutriplan/application/toast_controller.dart';

import 'fakes/mock_controllers.dart';
import 'fakes/scenario.dart';
import 'fakes/in_memory_activity_repository.dart';
import 'fakes/in_memory_plan_repository.dart';
import 'fakes/seed.dart';

import 'package:nutriplan/domain/errors.dart';
import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/fit.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/application/plan_controller.dart';
import 'package:nutriplan/application/activity_controller.dart';

DateTime now() => DateTime(2026, 10, 8, 10);
final DateTime today = DateTime(2026, 10, 8);

Future<AppControllers> loaded({Scenario s = Scenario.normal}) async {
  final c = buildAppControllers(clock: now, scenario: s);
  await c.loadAll();
  return c;
}

void main() {
  group('repositories', () {
    test('plan repo validates ids and returns the stored plan', () async {
      final seed = SeedData.build(now);
      final repo = InMemoryPlanRepository(
        plan: seed.plan,
        options: seed.options,
        clock: now,
      );
      final plan = (await repo.loadPlan())!;
      final d = plan.dayOn(today)!;
      await repo.saveDay(
        d.replaceMeal(d.meals.first.copyWith(done: !d.meals.first.done)),
      );
      expect(
        (await repo.loadPlan())!.dayOn(today)!.meals.first.done,
        !d.meals.first.done,
      );
      expect(
        () => repo.saveDay(DayPlan(date: DateTime(2030), meals: const [])),
        throwsA(isA<NotFoundError>()),
      );
      final other = DayPlan(date: today, meals: [d.meals.first]);
      expect(() => repo.saveDay(other), throwsA(isA<NotFoundError>()));
      expect((await repo.loadOptions(MealSlot.cena)).length, 5);
    });

    test(
      'plan repo scenarios: noPlan returns null, error fails once',
      () async {
        final seed = SeedData.build(now);
        final none = InMemoryPlanRepository(
          plan: seed.plan,
          options: seed.options,
          clock: now,
          scenario: Scenario.noPlan,
        );
        expect(await none.loadPlan(), isNull);
        final err = InMemoryPlanRepository(
          plan: seed.plan,
          options: seed.options,
          clock: now,
          scenario: Scenario.error,
        );
        await expectLater(err.loadPlan(), throwsA(isA<RepositoryError>()));
        expect(await err.loadPlan(), isNotNull);
      },
    );

    test('scenario parsing is whitelisted', () {
      expect(Scenario.parse('noPlan'), Scenario.noPlan);
      expect(Scenario.parse('error'), Scenario.error);
      expect(Scenario.parse('../../etc'), Scenario.normal);
      expect(Scenario.parse(null), Scenario.normal);
      expect(Scenario.parse(''), Scenario.normal);
    });

    test('activity repo adds, removes and rejects unknown ids', () async {
      final seed = SeedData.build(now);
      final repo = InMemoryActivityRepository(
        goal: seed.goal,
        logs: seed.logs,
        ownerPatientId: 'pat-1',
        clock: now,
      );
      expect((await repo.loadLogs()).length, 3);
      await repo.remove('log-1');
      expect((await repo.loadLogs()).length, 2);
      await expectLater(repo.remove('nope'), throwsA(isA<NotFoundError>()));
      final copy = await repo.loadLogs();
      copy.clear();
      expect((await repo.loadLogs()).length, 2);
    });

    test('seed is relative to the clock week and has 3 logs, 4 months', () {
      final seed = SeedData.build(() => DateTime(2026, 10, 12)); // Monday
      expect(seed.plan.days.first.date, DateTime(2026, 10, 12));
      expect(seed.plan.days.length, 7);
      expect(seed.logs.length, 3);
      expect(seed.measurements.map((m) => m.date.month), <int>[6, 7, 8, 9]);
      expect(seed.goal.sessions, 5);
      expect(seed.goal.minutes, 150);
      expect(SeedData.previousWeekAdherence, isNonZero);
    });
  });

  group('PlanController', () {
    test('loads plan, derived values', () async {
      final c = await loaded();
      expect(c.plan.loading, isFalse);
      expect(c.plan.todayPlan!.date, today);
      expect(c.plan.budget!.rows.length, 7);
      expect(c.plan.weekAdherencePct, greaterThan(0));
      expect(c.plan.swaps, 1);
      expect(c.plan.streak, 2);
    });

    test('toggleDone updates budget and reverts on failure', () async {
      final seed = SeedData.build(now);
      final repo = InMemoryPlanRepository(
        plan: seed.plan,
        options: seed.options,
        clock: now,
      );
      final plan = PlanController(repository: repo, clock: now);
      await plan.load();
      final before = plan.budget!.pctCovered;
      final comida = SeedData.mealId(3, MealSlot.comida);
      await plan.toggleDone(today, comida);
      expect(plan.budget!.pctCovered, greaterThan(before));
      await plan.toggleDone(today, comida);
      expect(plan.budget!.pctCovered, before);

      repo.failNextWrite = true;
      await plan.toggleDone(today, comida);
      expect(plan.hasError, isTrue);
      expect(plan.budget!.pctCovered, before); // reverted
      expect(plan.todayPlan!.mealById(comida).done, isFalse);
    });

    test('actions never throw for unknown ids', () async {
      final c = await loaded();
      await c.plan.toggleDone(today, 'nope');
      expect(c.plan.hasError, isTrue);
    });

    test('applySwap: yes, adjust, no', () async {
      final c = await loaded();
      final comida = SeedData.mealId(3, MealSlot.comida);
      final opts = c.plan.optionsFor(MealSlot.comida);
      FitResult fit(EquivalentOption o) => c.plan.fitFor(today, comida, o)!;
      final yes = opts.firstWhere((o) => fit(o).fit == Fit.yes);
      final adjust = opts.firstWhere((o) => fit(o).fit == Fit.adjust);
      final no = opts.firstWhere((o) => fit(o).fit == Fit.no);

      final before = c.plan.todayPlan!;
      final rNo = await c.plan.applySwap(today, comida, no);
      expect(rNo!.fit, Fit.no);
      expect(
        c.plan.todayPlan!.mealById(comida).dish,
        before.mealById(comida).dish,
      );

      final rAdjust = await c.plan.applySwap(today, comida, adjust);
      expect(rAdjust!.fit, Fit.adjust);
      final after = c.plan.todayPlan!;
      final from = rAdjust.rebalance!.fromMealId;
      expect(
        after.mealById(from).portions[rAdjust.rebalance!.group],
        before.mealById(from).portions[rAdjust.rebalance!.group] -
            rAdjust.rebalance!.amount,
      );
      expect(before.mealById(from).done, isFalse);
      expect(after.mealById(comida).swapped, isTrue);

      final rYes = await c.plan.applySwap(today, comida, yes);
      expect(rYes!.fit, Fit.yes);
      expect(c.plan.swaps, 2);
    });

    test('noPlan and error scenarios, retry recovers', () async {
      final none = await loaded(s: Scenario.noPlan);
      expect(none.plan.plan, isNull);
      expect(none.plan.hasError, isFalse);
      final err = await loaded(s: Scenario.error);
      expect(err.plan.hasError, isTrue);
      expect(err.plan.plan, isNull);
      await err.plan.retry();
      expect(err.plan.hasError, isFalse);
      expect(err.plan.plan, isNotNull);
    });
  });

  group('ActivityController', () {
    test(
      'quickLog adds a log for today, remove deletes it, failures revert',
      () async {
        final seed = SeedData.build(now);
        final repo = InMemoryActivityRepository(
          goal: seed.goal,
          logs: seed.logs,
          ownerPatientId: 'pat-1',
          clock: now,
        );
        final a = ActivityController(
          repository: repo,
          clock: now,
          patientId: 'pat-1',
        );
        await a.load();
        final before = a.summary!.minutes;
        final log = await a.quickLog(a.goal!.types.first);
        expect(log!.date, today);
        expect(a.summary!.minutes, before + 30);
        expect(await a.remove(log.id), isTrue);
        expect(a.summary!.minutes, before);

        repo.failNextWrite = true;
        expect(await a.quickLog(a.goal!.types.first), isNull);
        expect(a.summary!.minutes, before);
        expect(a.hasError, isTrue);
        expect(await a.remove('nope'), isFalse);
        expect(a.logs.length, 3);
      },
    );
  });

  group('ProgressController and Shell', () {
    test('progress loads measurements oldest first', () async {
      final c = await loaded();
      expect(c.progress.measurements.length, 4);
      expect(c.progress.latest!.date.month, 9);
    });

    test('shell openSwap, clear and finish', () async {
      final c = await loaded();
      c.shell.openSwap(today, 'x');
      expect(c.shell.tabIndex, 2);
      expect(c.shell.pendingSwap!.mealId, 'x');
      c.shell.clearSwap();
      expect(c.shell.pendingSwap, isNull);
      c.shell.openSwap(today, 'x');
      c.shell.finishSwap(today);
      expect(c.shell.tabIndex, 0);
      expect(c.shell.selectedDay, today);
    });
  });

  group('ToastController', () {
    test('FIFO, one at a time, 2.5s each', () async {
      final t = ToastController(duration: const Duration(milliseconds: 30));
      final seen = <String>[];
      t.addListener(() {
        if (t.current != null) seen.add(t.current!.text);
      });
      t.show('a');
      t.show('b');
      t.show('c');
      expect(t.current!.text, 'a');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(seen, <String>['a', 'b', 'c']);
      expect(t.current, isNull);
      t.dispose();
      expect(ToastController().duration.inMilliseconds, 2500);
    });
  });
}
