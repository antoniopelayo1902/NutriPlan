import '../../core/clock.dart';
import '../models/plan.dart';
import 'portion_budget.dart';

enum DayStatus { complete, partial, pending }

/// Complete when every meal is done, partial when at least one is, pending
/// otherwise. Future days are always pending.
DayStatus dayStatus(DayPlan day, DateTime today) {
  if (dateOnly(day.date).isAfter(dateOnly(today))) return DayStatus.pending;
  if (day.meals.isEmpty) return DayStatus.pending;
  final int done = day.meals.where((Meal m) => m.done).length;
  if (done == day.meals.length) return DayStatus.complete;
  if (done > 0) return DayStatus.partial;
  return DayStatus.pending;
}

/// Done meals over total meals of the day, rounded half-up (0..100).
int dayAdherencePct(DayPlan day) {
  final int done = day.meals.where((Meal m) => m.done).length;
  return roundPct(done.toDouble(), day.meals.length.toDouble());
}

/// Done meals over meals in days up to and including [today], rounded.
/// A swapped meal that is done counts fully.
int weekAdherence(Plan plan, DateTime today) {
  int done = 0;
  int total = 0;
  for (final DayPlan d in plan.days) {
    if (dateOnly(d.date).isAfter(dateOnly(today))) continue;
    total += d.meals.length;
    done += d.meals.where((Meal m) => m.done).length;
  }
  return roundPct(done.toDouble(), total.toDouble());
}

/// Points of difference versus the previous week.
int adherenceDelta(int current, int previous) => current - previous;
