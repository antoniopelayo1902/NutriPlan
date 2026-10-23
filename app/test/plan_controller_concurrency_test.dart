import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/application/plan_controller.dart';
import 'package:nutriplan/data/mock/seed.dart';
import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/repositories/plan_repository.dart';

DateTime now() => DateTime(2026, 10, 8, 10);

class _FakeRepo implements PlanRepository {
  _FakeRepo(this.loads, this.saves);

  final List<Future<Plan?>> loads;
  final List<Future<void>> saves;
  final List<DayPlan> saved = <DayPlan>[];
  int _loadCalls = 0;
  int _saveCalls = 0;

  @override
  Future<Plan?> loadPlan() => loads[_loadCalls++];

  @override
  Future<void> saveDay(DayPlan day) {
    saved.add(day);
    return saves[_saveCalls++];
  }

  @override
  Future<List<EquivalentOption>> loadOptions(MealSlot slot) async =>
      const <EquivalentOption>[];
}

void main() {
  final Plan plan = SeedData.build(now).plan;

  test('overlapping loads end with the latest call state', () async {
    final first = Completer<Plan?>();
    final second = Completer<Plan?>();
    final c = PlanController(
      repository: _FakeRepo(<Future<Plan?>>[first.future, second.future], []),
      clock: now,
    );
    final a = c.load();
    final b = c.retry();
    second.complete(plan);
    await b;
    expect(c.plan, same(plan));
    expect(c.loading, isFalse);
    first.complete(null);
    await a;
    expect(c.plan, same(plan));
    expect(c.loading, isFalse);
    expect(c.hasError, isFalse);
  });

  test('stale failed load does not overwrite the latest result', () async {
    final first = Completer<Plan?>();
    final second = Completer<Plan?>();
    final c = PlanController(
      repository: _FakeRepo(<Future<Plan?>>[first.future, second.future], []),
      clock: now,
    );
    final a = c.load();
    final b = c.load();
    second.complete(plan);
    await b;
    first.completeError(StateError('late'));
    await a;
    expect(c.plan, same(plan));
    expect(c.hasError, isFalse);
  });

  test(
    'failed save then successful save ends with the successful value',
    () async {
      final fail = Completer<void>();
      final ok = Completer<void>();
      final repo = _FakeRepo(
        <Future<Plan?>>[Future<Plan?>.value(plan)],
        <Future<void>>[fail.future, ok.future],
      );
      final c = PlanController(repository: repo, clock: now);
      await c.load();
      final DateTime day = DateTime(2026, 10, 8);
      final Meal meal = c.plan!.dayOn(day)!.meals.first;
      final bool original = meal.done;

      final t1 = c.toggleDone(day, meal.id);
      final t2 = c.toggleDone(day, meal.id);
      fail.completeError(StateError('disk'));
      await t1;
      ok.complete();
      await t2;

      Meal current() => c.plan!.dayOn(day)!.mealById(meal.id);
      expect(current().done, !original);
      expect(repo.saved.last.mealById(meal.id).done, !original);
      expect(c.hasError, isFalse);
    },
  );
}
