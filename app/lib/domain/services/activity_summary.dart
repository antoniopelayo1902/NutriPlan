import '../../core/clock.dart';
import '../models/activity.dart';
import 'portion_budget.dart';

class ActivitySummary {
  const ActivitySummary({
    required this.minutes,
    required this.sessions,
    required this.pct,
    required this.goalMinutes,
    required this.goalSessions,
    required this.minutesPerDay,
    required this.logs,
  });

  final int minutes;
  final int sessions;

  /// Rounded integer percent of the weekly minutes goal (may exceed 100).
  final int pct;
  final int goalMinutes;
  final int goalSessions;

  /// Monday to Sunday.
  final List<int> minutesPerDay;

  /// Logs of the current week, newest first.
  final List<ActivityLog> logs;

  bool get goalMet => pct >= 100;
}

/// Summary of the Mon-Sun week that contains [today].
ActivitySummary summarizeActivity(
  List<ActivityLog> all,
  ActivityGoal goal,
  DateTime today,
) {
  final DateTime monday = mondayOf(today);
  final DateTime nextMonday = DateTime(
    monday.year,
    monday.month,
    monday.day + 7,
  );
  final List<ActivityLog> week = all.where((ActivityLog l) {
    final DateTime d = dateOnly(l.date);
    return !d.isBefore(monday) && d.isBefore(nextMonday);
  }).toList()..sort((ActivityLog a, ActivityLog b) => b.date.compareTo(a.date));
  final List<int> perDay = List<int>.filled(7, 0);
  int minutes = 0;
  for (final ActivityLog l in week) {
    perDay[dateOnly(l.date).weekday - DateTime.monday] += l.minutes;
    minutes += l.minutes;
  }
  return ActivitySummary(
    minutes: minutes,
    sessions: week.length,
    pct: roundPct(minutes.toDouble(), goal.minutes.toDouble()),
    goalMinutes: goal.minutes,
    goalSessions: goal.sessions,
    minutesPerDay: perDay,
    logs: week,
  );
}
