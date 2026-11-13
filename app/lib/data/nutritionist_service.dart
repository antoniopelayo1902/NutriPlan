import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/errors.dart';
import '../domain/models/food_group.dart';
import '../domain/models/patient_summary.dart';
import '../domain/models/plan.dart';
import '../domain/models/portions.dart';
import '../domain/models/user_role.dart';
import 'firestore/firestore_mappers.dart';
import 'firestore/firestore_paths.dart';
import 'mock/seed.dart';

/// Lecturas y escrituras de Firestore que hace la cuenta de nutrióloga.
abstract final class NutritionistService {
  /// Nombre de la nutrióloga [uid].
  static Future<String> loadName(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirestorePaths.user(uid).get();
    if (!doc.exists) throw const NotFoundError('User not found');
    return doc.data()!['name'] as String;
  }

  /// Pacientes vinculados (users con nutritionistId igual a [uid]).
  static Future<List<PatientSummary>> patientsOf(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await FirestorePaths.usersCollection()
            .where('nutritionistId', isEqualTo: uid)
            .get();
    final List<PatientSummary> out = <PatientSummary>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        PatientSummary(
          uid: d.id,
          name: d.data()['name'] as String,
          email: (d.data()['email'] as String?) ?? '',
          objective: (d.data()['objective'] as String?) ?? '',
        ),
    ];
    out.sort((PatientSummary a, PatientSummary b) => a.name.compareTo(b.name));
    return out;
  }

  /// Cambia el nombre en su usuario y en el catálogo de nutriólogas.
  static Future<void> rename(String uid, String name) async {
    if (name.trim().isEmpty) {
      throw const DomainValidationError('Name is required');
    }
    final WriteBatch batch = FirestorePaths.db.batch();
    batch.update(FirestorePaths.user(uid), <String, dynamic>{
      'name': name.trim(),
    });
    batch.set(FirestorePaths.nutritionist(uid), <String, dynamic>{
      'name': name.trim(),
    });
    await batch.commit();
  }

  /// El paciente [patientUid] queda vinculado con la nutrióloga [nutriUid].
  /// Regresa el nombre de la nutrióloga para mostrarlo.
  static Future<String> link(String patientUid, String nutriUid) async {
    final DocumentSnapshot<Map<String, dynamic>> nutri =
        await FirestorePaths.user(nutriUid).get();
    if (!nutri.exists ||
        UserRole.parse(nutri.data()!['role']) != UserRole.nutritionist) {
      throw const NotFoundError('Nutritionist not found');
    }
    await FirestorePaths.user(patientUid)
        .update(<String, dynamic>{'nutritionistId': nutriUid});
    return nutri.data()!['name'] as String;
  }

  /// Quita al paciente de la lista: vuelve a la nutrióloga de ejemplo.
  static Future<void> unlink(String patientUid) async {
    await FirestorePaths.user(patientUid)
        .update(<String, dynamic>{'nutritionistId': SeedData.nutritionistId});
  }

  /// Porciones diarias del plan del paciente, o null si no tiene plan.
  static Future<Portions?> loadTargets(String patientUid) async {
    final DocumentSnapshot<Map<String, dynamic>> plan =
        await FirestorePaths.plan(patientUid).get();
    if (!plan.exists) return null;
    return FirestoreMappers.portionsFromMap(plan.data()!['dailyTargets']);
  }

  /// Mínimo por grupo: lo que piden las comidas del día más cargado, para
  /// que las porciones diarias nunca queden por debajo del plan.
  static Future<Portions> loadMinimums(String patientUid) async {
    final QuerySnapshot<Map<String, dynamic>> days = await FirestorePaths.days(
      patientUid,
    ).get();
    final Map<FoodGroup, double> max = <FoodGroup, double>{};
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in days.docs) {
      final DayPlan day = FirestoreMappers.dayFromMap(d.data());
      Portions total = Portions.zero;
      for (final Meal m in day.meals) {
        total = total + m.portions;
      }
      for (final FoodGroup g in FoodGroup.values) {
        if (total[g] > (max[g] ?? 0)) max[g] = total[g];
      }
    }
    return Portions(max);
  }

  /// Publica las porciones nuevas en el plan del paciente.
  static Future<void> publishTargets({
    required String patientUid,
    required String nutriUid,
    required Portions targets,
  }) async {
    await FirestorePaths.plan(patientUid).update(<String, dynamic>{
      'dailyTargets': FirestoreMappers.portionsToMap(targets),
      'nutritionistId': nutriUid,
      'publishedAt': Timestamp.now(),
    });
  }
}
