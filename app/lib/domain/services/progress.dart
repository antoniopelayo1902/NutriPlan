import '../../core/clock.dart';
import '../models/plan.dart';
import 'adherence.dart';

enum Achievement { streak3, variety5, firstSwap, adherence80 }

/// Consecutive complete days ending today when today is complete, otherwise
/// ending yesterday.
int currentStreak(Plan plan, DateTime today) {
  final DateTime t = dateOnly(today);
  DateTime cursor = t;
  final DayPlan? todayPlan = plan.dayOn(t);
  if (todayPlan == null || dayStatus(todayPlan, t) != DayStatus.complete) {
    cursor = DateTime(t.year, t.month, t.day - 1);
  }
  int streak = 0;
  while (true) {
    final DayPlan? d = plan.dayOn(cursor);
    if (d == null || dayStatus(d, t) != DayStatus.complete) break;
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return streak;
}

/// Distinct dish names among done meals this week.
int varietyCount(Plan plan) {
  final Set<String> dishes = <String>{};
  for (final DayPlan d in plan.days) {
    for (final Meal m in d.meals) {
      if (m.done) dishes.add(m.dish);
    }
  }
  return dishes.length;
}

/// Meals replaced through an equivalent this week.
int swapCount(Plan plan) {
  int n = 0;
  for (final DayPlan d in plan.days) {
    n += d.meals.where((Meal m) => m.swappedFrom != null).length;
  }
  return n;
}

List<Achievement> achievements(Plan plan, DateTime today) {
  return <Achievement>[
    if (currentStreak(plan, today) >= 3) Achievement.streak3,
    if (varietyCount(plan) >= 5) Achievement.variety5,
    if (swapCount(plan) >= 1) Achievement.firstSwap,
    if (weekAdherence(plan, today) >= 80) Achievement.adherence80,
  ];
}
