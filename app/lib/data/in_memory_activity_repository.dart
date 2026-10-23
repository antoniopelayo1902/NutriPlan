import '../core/clock.dart';
import '../core/scenario.dart';
import '../domain/errors.dart';
import '../domain/models/activity.dart';
import '../domain/repositories/activity_repository.dart';

class InMemoryActivityRepository implements ActivityRepository {
  InMemoryActivityRepository({
    required ActivityGoal goal,
    required List<ActivityLog> logs,
    required this.ownerPatientId,
    required this.clock,
    this.scenario = Scenario.normal,
    this.latency = Duration.zero,
  }) : _goal = goal,
       _logs = List<ActivityLog>.of(logs);

  final ActivityGoal _goal;
  final List<ActivityLog> _logs;
  final String ownerPatientId;
  final Clock clock;
  final Scenario scenario;
  final Duration latency;
  bool _failedOnce = false;

  /// Test hook: the next write throws a [RepositoryError].
  bool failNextWrite = false;

  Future<void> _maybeFailLoad() async {
    await Future<void>.delayed(latency);
    if (scenario == Scenario.error && !_failedOnce) {
      _failedOnce = true;
      throw const RepositoryError('activity unavailable');
    }
  }

  @override
  Future<ActivityGoal> loadGoal() async {
    await _maybeFailLoad();
    return _goal;
  }

  @override
  Future<List<ActivityLog>> loadLogs() async {
    await Future<void>.delayed(latency);
    return _logs
        .where((ActivityLog l) => l.patientId == ownerPatientId)
        .toList();
  }

  @override
  Future<void> add(ActivityLog log) async {
    await Future<void>.delayed(latency);
    if (failNextWrite) {
      failNextWrite = false;
      throw const RepositoryError('write failed');
    }
    if (log.patientId != ownerPatientId) {
      throw const DomainValidationError('Log belongs to another patient');
    }
    if (dateOnly(log.date).isAfter(dateOnly(clock()))) {
      throw const DomainValidationError('Future logs are not allowed');
    }
    if (!_goal.types.any((ActivityType t) => t.kind == log.kind)) {
      throw const DomainValidationError('Activity type not allowed');
    }
    // kcal is derived from the goal, never trusted from the client.
    if (log.kcal != _goal.typeOf(log.kind).kcalFor(log.minutes)) {
      throw const DomainValidationError('kcal does not match the activity');
    }
    if (_logs.any((ActivityLog l) => l.id == log.id)) {
      throw const DomainValidationError('Duplicate log id');
    }
    _logs.add(log);
  }

  @override
  Future<void> remove(String id) async {
    await Future<void>.delayed(latency);
    if (failNextWrite) {
      failNextWrite = false;
      throw const RepositoryError('write failed');
    }
    // A log of another patient looks the same as a missing one.
    final int i = _logs.indexWhere(
      (ActivityLog l) => l.id == id && l.patientId == ownerPatientId,
    );
    if (i < 0) throw const NotFoundError('Log not found');
    _logs.removeAt(i);
  }
}
