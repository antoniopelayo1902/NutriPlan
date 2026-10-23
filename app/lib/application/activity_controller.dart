import 'package:flutter/foundation.dart';

import '../core/clock.dart';
import '../domain/models/activity.dart';
import '../domain/repositories/activity_repository.dart';
import '../domain/services/activity_summary.dart';

class ActivityController extends ChangeNotifier {
  ActivityController({
    required ActivityRepository repository,
    required Clock clock,
    required this.patientId,
  }) : _repository = repository,
       _clock = clock;

  final ActivityRepository _repository;
  final Clock _clock;
  final String patientId;

  bool _loading = true;
  Object? _error;
  ActivityGoal? _goal;
  List<ActivityLog> _logs = <ActivityLog>[];
  int _seq = 0;

  bool get loading => _loading;
  Object? get error => _error;
  bool get hasError => _error != null;
  ActivityGoal? get goal => _goal;
  List<ActivityLog> get logs => List<ActivityLog>.unmodifiable(_logs);

  ActivitySummary? get summary {
    final ActivityGoal? g = _goal;
    return g == null ? null : summarizeActivity(_logs, g, _clock());
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _goal = await _repository.loadGoal();
      _logs = await _repository.loadLogs();
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => load();

  /// Logs one session of [type] for today with its default duration.
  /// Returns the new log, or null when the action failed.
  Future<ActivityLog?> quickLog(ActivityType type) async {
    final List<ActivityLog> before = _logs;
    try {
      final ActivityLog log = ActivityLog(
        id: 'log-${_clock().microsecondsSinceEpoch}-${++_seq}',
        patientId: patientId,
        date: dateOnly(_clock()),
        kind: type.kind,
        minutes: type.defaultMin,
        kcal: type.kcalFor(type.defaultMin),
      );
      _logs = <ActivityLog>[...before, log];
      _error = null;
      notifyListeners();
      try {
        await _repository.add(log);
        return log;
      } catch (e) {
        _logs = before;
        _error = e;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e;
      notifyListeners();
      return null;
    }
  }

  /// Removes a session. Returns false when the action failed.
  Future<bool> remove(String id) async {
    final List<ActivityLog> before = _logs;
    _logs = before.where((ActivityLog l) => l.id != id).toList();
    _error = null;
    notifyListeners();
    try {
      await _repository.remove(id);
      return true;
    } catch (e) {
      _logs = before;
      _error = e;
      notifyListeners();
      return false;
    }
  }
}
