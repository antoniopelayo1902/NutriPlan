import '../errors.dart';

enum ActivityKind { caminata, fuerza, bici, yoga }

/// Allowed activity type with the nutritionist's default duration.
class ActivityType {
  ActivityType({
    required this.kind,
    required this.defaultMin,
    required this.kcalPerMin,
  }) {
    if (defaultMin < minMinutes || defaultMin > maxMinutes || kcalPerMin <= 0) {
      throw const DomainValidationError('Invalid activity type');
    }
  }

  static const int minMinutes = 1;
  static const int maxMinutes = 600;

  final ActivityKind kind;
  final int defaultMin;
  final double kcalPerMin;

  /// Energy for a session of [minutes] (rounded).
  int kcalFor(int minutes) => (minutes * kcalPerMin).round();
}

class ActivityGoal {
  ActivityGoal({
    required this.sessions,
    required this.minutes,
    required this.types,
  }) {
    if (sessions < 1 || minutes < 1) {
      throw const DomainValidationError('Goal must be positive');
    }
  }

  /// Meta inicial de un plan nuevo: 150 min a la semana, lo que recomienda
  /// la OMS para adultos. El nutriólogo la puede ajustar después.
  static ActivityGoal recommended() => ActivityGoal(
    sessions: 5,
    minutes: 150,
    types: <ActivityType>[
      ActivityType(kind: ActivityKind.caminata, defaultMin: 30, kcalPerMin: 4),
      ActivityType(kind: ActivityKind.fuerza, defaultMin: 45, kcalPerMin: 5),
      ActivityType(kind: ActivityKind.bici, defaultMin: 40, kcalPerMin: 7),
      ActivityType(kind: ActivityKind.yoga, defaultMin: 30, kcalPerMin: 3),
    ],
  );

  final int sessions;
  final int minutes;
  final List<ActivityType> types;

  ActivityType typeOf(ActivityKind kind) {
    for (final ActivityType t in types) {
      if (t.kind == kind) return t;
    }
    throw const NotFoundError('Unknown activity type');
  }
}

class ActivityLog {
  ActivityLog({
    required this.id,
    required this.patientId,
    required this.date,
    required this.kind,
    required this.minutes,
    required this.kcal,
  }) {
    if (id.isEmpty || patientId.isEmpty) {
      throw const DomainValidationError('Activity log ids are required');
    }
    if (minutes < ActivityType.minMinutes ||
        minutes > ActivityType.maxMinutes) {
      throw const DomainValidationError('Minutes must be between 1 and 600');
    }
    if (kcal < 0) {
      throw const DomainValidationError('kcal must not be negative');
    }
  }

  final String id;
  final String patientId;
  final DateTime date;
  final ActivityKind kind;
  final int minutes;
  final int kcal;
}
