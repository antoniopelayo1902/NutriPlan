import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/clock.dart';
import '../../domain/errors.dart';
import '../../domain/models/equivalent_option.dart';
import '../../domain/models/plan.dart';
import '../../domain/repositories/plan_repository.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Plan de la semana guardado en Firestore para el usuario [uid].
class FirestorePlanRepository implements PlanRepository {
  FirestorePlanRepository({required this.uid, required this.clock});

  final String uid;
  final Clock clock;

  /// Lee el plan y los 7 días de la semana actual. Null si no hay plan.
  @override
  Future<Plan?> loadPlan() async {
    final DocumentSnapshot<Map<String, dynamic>> header =
        await FirestorePaths.plan(uid).get();
    if (!header.exists) return null;
    final DateTime monday = mondayOf(clock());
    final DateTime nextMonday = DateTime(
      monday.year,
      monday.month,
      monday.day + 7,
    );
    final QuerySnapshot<Map<String, dynamic>> snap =
        await FirestorePaths.days(uid)
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
            .where('date', isLessThan: Timestamp.fromDate(nextMonday))
            .orderBy('date')
            .get();
    if (snap.docs.isEmpty) return null;
    final List<DayPlan> days = <DayPlan>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        FirestoreMappers.dayFromMap(d.data()),
    ];
    return FirestoreMappers.planFromMap(uid, header.data()!, days);
  }

  /// Guarda un día completo (marcar comida o cambiar platillo).
  @override
  Future<void> saveDay(DayPlan day) async {
    final DocumentReference<Map<String, dynamic>> ref = FirestorePaths.days(uid)
        .doc(FirestoreMappers.dayId(day.date));
    final DocumentSnapshot<Map<String, dynamic>> current = await ref.get();
    if (!current.exists) throw const NotFoundError('Day not found');
    await ref.set(FirestoreMappers.dayToMap(day));
  }

  /// Opciones equivalentes del tiempo de comida [slot].
  @override
  Future<List<EquivalentOption>> loadOptions(MealSlot slot) async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await FirestorePaths.optionsCollection()
            .where('slot', isEqualTo: slot.name)
            .get();
    final List<EquivalentOption> out = <EquivalentOption>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs)
        FirestoreMappers.optionFromMap(d.id, d.data()),
    ];
    out.sort((EquivalentOption a, EquivalentOption b) => a.id.compareTo(b.id));
    return out;
  }
}
