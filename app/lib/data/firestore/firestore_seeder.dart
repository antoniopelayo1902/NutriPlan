import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/clock.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/equivalent_option.dart';
import '../../domain/models/measurement.dart';
import '../../domain/models/plan.dart';
import '../mock/seed.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Crea en Firestore el plan de ejemplo que el nutriólogo le asigna a una
/// cuenta nueva. Después de esto, la app solo lee y escribe en Firestore.
class FirestoreSeeder {
  FirestoreSeeder({required this.clock});

  final Clock clock;

  /// Catálogo compartido: el nutriólogo y las opciones equivalentes.
  Future<void> ensureCatalog() async {
    final SeedData seed = SeedData.build(clock);
    final DocumentSnapshot<Map<String, dynamic>> nut =
        await FirestorePaths.nutritionist(seed.nutritionist.id).get();
    final QuerySnapshot<Map<String, dynamic>> opts =
        await FirestorePaths.optionsCollection().limit(1).get();
    if (nut.exists && opts.docs.isNotEmpty) return;
    final WriteBatch batch = FirestorePaths.db.batch();
    batch.set(
      FirestorePaths.nutritionist(seed.nutritionist.id),
      <String, dynamic>{'name': seed.nutritionist.name},
    );
    for (final List<EquivalentOption> list in seed.options.values) {
      for (final EquivalentOption o in list) {
        batch.set(
          FirestorePaths.optionsCollection().doc(o.id),
          FirestoreMappers.optionToMap(o),
        );
      }
    }
    await batch.commit();
  }

  /// Plan, días, sesiones y medidas de ejemplo para el usuario [uid].
  Future<void> seedUser(String uid) async {
    final SeedData seed = SeedData.build(clock);
    final WriteBatch batch = FirestorePaths.db.batch();
    batch.set(FirestorePaths.plan(uid), FirestoreMappers.planToMap(seed.plan));
    for (final DayPlan d in seed.plan.days) {
      batch.set(
        FirestorePaths.days(uid).doc(FirestoreMappers.dayId(d.date)),
        FirestoreMappers.dayToMap(d),
      );
    }
    for (final ActivityLog l in seed.logs) {
      batch.set(
        FirestorePaths.activityLogs(uid).doc(l.id),
        FirestoreMappers.logToMap(_logFor(uid, l)),
      );
    }
    for (final Measurement m in seed.measurements) {
      final Map<String, dynamic> data = FirestoreMappers.measurementToMap(m);
      data['patientId'] = uid;
      batch.set(FirestorePaths.measurements(uid).doc(m.id), data);
    }
    await batch.commit();
  }

  /// Si la semana actual no tiene días (cambió la semana), los crea vacíos.
  Future<void> ensureWeek(String uid) async {
    final DateTime monday = mondayOf(clock());
    final DocumentSnapshot<Map<String, dynamic>> first =
        await FirestorePaths.days(uid)
            .doc(FirestoreMappers.dayId(monday))
            .get();
    if (first.exists) return;
    final SeedData seed = SeedData.build(clock);
    final WriteBatch batch = FirestorePaths.db.batch();
    for (final DayPlan d in seed.plan.days) {
      batch.set(
        FirestorePaths.days(uid).doc(FirestoreMappers.dayId(d.date)),
        FirestoreMappers.dayToMap(_freshDay(d)),
      );
    }
    await batch.commit();
  }

  static ActivityLog _logFor(String uid, ActivityLog l) => ActivityLog(
    id: l.id,
    patientId: uid,
    date: l.date,
    kind: l.kind,
    minutes: l.minutes,
    kcal: l.kcal,
  );

  /// Día nuevo: sin comidas marcadas y con los platillos originales.
  static DayPlan _freshDay(DayPlan d) => DayPlan(
    date: d.date,
    meals: <Meal>[
      for (final Meal m in d.meals)
        Meal(
          id: m.id,
          slot: m.slot,
          time: m.time,
          dish: m.swappedFrom ?? m.dish,
          portions: m.swappedFrom == null
              ? m.portions
              : SeedData.slotPortions(m.slot),
        ),
    ],
  );
}
