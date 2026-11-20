import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/clock.dart';
import '../../domain/models/equivalent_option.dart';
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
    final QuerySnapshot<Map<String, dynamic>> opts =
        await FirestorePaths.optionsCollection().limit(1).get();
    if (opts.docs.isNotEmpty) return;
    final SeedData seed = SeedData.build(clock);
    final WriteBatch batch = FirestorePaths.db.batch();
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

  /// Plan de la semana para una cuenta nueva: sin comidas marcadas, sin
  /// sesiones y sin medidas. Lo demás lo captura el paciente o su nutriólogo.
  Future<void> seedUser(String uid) async {
    final SeedData seed = SeedData.build(clock);
    final WriteBatch batch = FirestorePaths.db.batch();
    final Map<String, dynamic> plan = FirestoreMappers.planToMap(seed.plan);
    plan['previousWeekAdherence'] = 0;
    batch.set(FirestorePaths.plan(uid), plan);
    for (final DayPlan d in seed.plan.days) {
      batch.set(
        FirestorePaths.days(uid).doc(FirestoreMappers.dayId(d.date)),
        FirestoreMappers.dayToMap(_freshDay(d)),
      );
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
