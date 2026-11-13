import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/clock.dart';
import '../domain/errors.dart';
import '../domain/models/plan.dart';
import 'firestore/firestore_mappers.dart';
import 'firestore/firestore_paths.dart';

/// Factor WOW: compartir el plan con un QR e importarlo escaneándolo.
abstract final class PlanShareService {
  static const String _prefix = 'nutriplan:plan:';
  static const String _nutriPrefix = 'nutriplan:nutri:';

  /// Código QR de una nutrióloga, para que sus pacientes se vinculen.
  static String nutriCodeFor(String uid) => '$_nutriPrefix$uid';

  /// Uid de la nutrióloga dentro de un código, o null si no es de ese tipo.
  static String? nutriUidFrom(String raw) {
    final String code = raw.trim();
    if (!code.startsWith(_nutriPrefix)) return null;
    final String uid = code.substring(_nutriPrefix.length);
    return uid.isEmpty ? null : uid;
  }

  /// Texto que va dentro del QR del usuario [uid].
  static String codeFor(String uid) => '$_prefix$uid';

  /// Uid dentro de un código escaneado, o null si no es de NutriPlan.
  static String? uidFrom(String raw) {
    final String code = raw.trim();
    if (!code.startsWith(_prefix)) return null;
    final String uid = code.substring(_prefix.length);
    return uid.isEmpty ? null : uid;
  }

  /// Copia el plan y los días de esta semana de [fromUid] a [toUid].
  /// Las comidas llegan sin marcar, como un plan nuevo.
  static Future<void> importPlan({
    required String fromUid,
    required String toUid,
    Clock clock = DateTime.now,
  }) async {
    if (fromUid == toUid) {
      throw const DomainValidationError('Own plan');
    }
    final DocumentSnapshot<Map<String, dynamic>> header =
        await FirestorePaths.plan(fromUid).get();
    if (!header.exists) throw const NotFoundError('Plan not found');
    final DateTime monday = mondayOf(clock());
    final QuerySnapshot<Map<String, dynamic>> days = await FirestorePaths.days(
      fromUid,
    ).where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monday)).get();
    if (days.docs.isEmpty) throw const NotFoundError('Plan not found');
    final WriteBatch batch = FirestorePaths.db.batch();
    batch.set(FirestorePaths.plan(toUid), header.data()!);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in days.docs) {
      final DayPlan day = FirestoreMappers.dayFromMap(d.data());
      final DayPlan clean = DayPlan(
        date: day.date,
        meals: <Meal>[for (final Meal m in day.meals) _unmarked(m)],
      );
      batch.set(
        FirestorePaths.days(toUid).doc(d.id),
        FirestoreMappers.dayToMap(clean),
      );
    }
    await batch.commit();
  }

  static Meal _unmarked(Meal m) => Meal(
    id: m.id,
    slot: m.slot,
    time: m.time,
    dish: m.dish,
    portions: m.portions,
    swappedFrom: m.swappedFrom,
  );
}
