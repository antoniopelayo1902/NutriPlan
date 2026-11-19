import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/clock.dart';
import '../../domain/errors.dart';
import '../../domain/models/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// CRUD de las sesiones de actividad en users/{uid}/activityLogs.
class FirestoreActivityRepository implements ActivityRepository {
  FirestoreActivityRepository({required this.uid, required this.clock});

  final String uid;
  final Clock clock;

  /// La meta de actividad viene del plan que publicó el nutriólogo.
  @override
  Future<ActivityGoal> loadGoal() async {
    final DocumentSnapshot<Map<String, dynamic>> plan =
        await FirestorePaths.plan(uid).get();
    if (!plan.exists) throw const NotFoundError('Plan not found');
    return FirestoreMappers.goalFromMap(
      plan.data()!['activityGoal'] as Map<String, dynamic>,
    );
  }

  /// Read: todas las sesiones, de la más antigua a la más reciente.
  @override
  Future<List<ActivityLog>> loadLogs() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await FirestorePaths.activityLogs(uid).orderBy('date').get();
    return <ActivityLog>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        FirestoreMappers.logFromMap(d.id, d.data()),
    ];
  }

  /// Create: guarda una sesión nueva con su id.
  @override
  Future<void> add(ActivityLog log) async {
    await _validate(log);
    await FirestorePaths.activityLogs(uid)
        .doc(log.id)
        .set(FirestoreMappers.logToMap(log));
  }

  /// Update: reemplaza una sesión que ya existe.
  @override
  Future<void> update(ActivityLog log) async {
    await _validate(log);
    final DocumentReference<Map<String, dynamic>> ref =
        FirestorePaths.activityLogs(uid).doc(log.id);
    if (!(await ref.get()).exists) throw const NotFoundError('Log not found');
    await ref.set(FirestoreMappers.logToMap(log));
  }

  /// Delete: borra la sesión [id].
  @override
  Future<void> remove(String id) async {
    final DocumentReference<Map<String, dynamic>> ref =
        FirestorePaths.activityLogs(uid).doc(id);
    if (!(await ref.get()).exists) throw const NotFoundError('Log not found');
    await ref.delete();
  }

  /// Mismas reglas que antes: sin fechas futuras y kcal calculadas del tipo.
  Future<void> _validate(ActivityLog log) async {
    if (log.patientId != uid) {
      throw const DomainValidationError('Log belongs to another patient');
    }
    if (dateOnly(log.date).isAfter(dateOnly(clock()))) {
      throw const DomainValidationError('Future logs are not allowed');
    }
    final ActivityGoal goal = await loadGoal();
    if (log.kcal != goal.typeOf(log.kind).kcalFor(log.minutes)) {
      throw const DomainValidationError('kcal does not match the activity');
    }
  }
}
