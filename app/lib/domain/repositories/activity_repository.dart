import '../models/activity.dart';

abstract interface class ActivityRepository {
  Future<ActivityGoal> loadGoal();
  Future<List<ActivityLog>> loadLogs();
  Future<void> add(ActivityLog log);

  /// Throws NotFoundError for an unknown id.
  Future<void> remove(String id);
}
