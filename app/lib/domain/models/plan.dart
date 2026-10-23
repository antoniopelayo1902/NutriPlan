import '../../core/clock.dart';
import '../errors.dart';
import 'activity.dart';
import 'portions.dart';

enum MealSlot { desayuno, colacion, comida, cena }

final RegExp _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

class Meal {
  Meal({
    required this.id,
    required this.slot,
    required this.time,
    required this.dish,
    required this.portions,
    this.done = false,
    this.swappedFrom,
  }) {
    if (id.isEmpty) throw const DomainValidationError('Meal id is required');
    if (!_timePattern.hasMatch(time)) {
      throw const DomainValidationError('Meal time must be HH:mm');
    }
    if (dish.trim().isEmpty) {
      throw const DomainValidationError('Dish is required');
    }
  }

  final String id;
  final MealSlot slot;
  final String time;
  final String dish;
  final Portions portions;
  final bool done;

  /// Original dish when this meal was replaced through an equivalent.
  final String? swappedFrom;

  bool get swapped => swappedFrom != null;

  Meal copyWith({
    String? dish,
    Portions? portions,
    bool? done,
    String? swappedFrom,
  }) {
    return Meal(
      id: id,
      slot: slot,
      time: time,
      dish: dish ?? this.dish,
      portions: portions ?? this.portions,
      done: done ?? this.done,
      swappedFrom: swappedFrom ?? this.swappedFrom,
    );
  }
}

class DayPlan {
  DayPlan({required DateTime date, required List<Meal> meals})
    : date = dateOnly(date),
      meals = List<Meal>.unmodifiable(meals) {
    final Set<String> ids = meals.map((Meal m) => m.id).toSet();
    if (ids.length != meals.length) {
      throw const DomainValidationError('Meal ids must be unique within a day');
    }
  }

  final DateTime date;
  final List<Meal> meals;

  Meal mealById(String id) {
    for (final Meal m in meals) {
      if (m.id == id) return m;
    }
    throw const NotFoundError('Meal not found');
  }

  DayPlan replaceMeal(Meal meal) {
    mealById(meal.id);
    return DayPlan(
      date: date,
      meals: <Meal>[for (final Meal m in meals) m.id == meal.id ? meal : m],
    );
  }
}

class Plan {
  Plan({
    required this.id,
    required this.patientId,
    required this.nutritionistId,
    required this.publishedAt,
    required this.weeks,
    required this.dailyTargets,
    required List<DayPlan> days,
    required this.activityGoal,
    required this.previousWeekAdherence,
  }) : days = List<DayPlan>.unmodifiable(days) {
    if (id.isEmpty || patientId.isEmpty) {
      throw const DomainValidationError('Plan ids are required');
    }
    if (weeks < 1 || days.isEmpty) {
      throw const DomainValidationError('Plan needs weeks and days');
    }
    if (previousWeekAdherence < 0 || previousWeekAdherence > 100) {
      throw const DomainValidationError('Adherence must be 0..100');
    }
  }

  final String id;
  final String patientId;
  final String nutritionistId;
  final DateTime publishedAt;
  final int weeks;
  final Portions dailyTargets;
  final List<DayPlan> days;
  final ActivityGoal activityGoal;

  /// Adherence (0..100) of the week before the current one.
  final int previousWeekAdherence;

  DayPlan? dayOn(DateTime date) {
    for (final DayPlan d in days) {
      if (sameDay(d.date, date)) return d;
    }
    return null;
  }

  Plan replaceDay(DayPlan day) {
    if (dayOn(day.date) == null) {
      throw const NotFoundError('Day not found');
    }
    return Plan(
      id: id,
      patientId: patientId,
      nutritionistId: nutritionistId,
      publishedAt: publishedAt,
      weeks: weeks,
      dailyTargets: dailyTargets,
      days: <DayPlan>[
        for (final DayPlan d in days) sameDay(d.date, day.date) ? day : d,
      ],
      activityGoal: activityGoal,
      previousWeekAdherence: previousWeekAdherence,
    );
  }
}
