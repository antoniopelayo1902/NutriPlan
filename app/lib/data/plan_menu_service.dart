import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/clock.dart';
import '../domain/models/activity.dart';
import '../domain/models/equivalent_option.dart';
import '../domain/models/food_group.dart';
import '../domain/models/plan.dart';
import '../domain/models/portions.dart';
import '../domain/models/week_menu.dart';
import 'firestore/firestore_mappers.dart';
import 'firestore/firestore_paths.dart';

/// El plan que arma el nutriólogo con platillos del catálogo de Firestore.
abstract final class PlanMenuService {
  /// Catálogo de platillos (colección options), agrupado por tiempo.
  static Future<Map<MealSlot, List<EquivalentOption>>> loadCatalog() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await FirestorePaths.optionsCollection().get();
    final Map<MealSlot, List<EquivalentOption>> out =
        <MealSlot, List<EquivalentOption>>{
          for (final MealSlot s in MealSlot.values) s: <EquivalentOption>[],
        };
    for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
      final EquivalentOption o = FirestoreMappers.optionFromMap(d.id, d.data());
      out[o.slot]!.add(o);
    }
    for (final List<EquivalentOption> list in out.values) {
      list.sort(
        (EquivalentOption a, EquivalentOption b) => a.dish.compareTo(b.dish),
      );
    }
    return out;
  }

  /// Menú guardado del paciente, o null si todavía no tiene plan.
  static Future<WeekMenu?> loadMenu(String patientUid) async {
    final DocumentSnapshot<Map<String, dynamic>> plan =
        await FirestorePaths.plan(patientUid).get();
    if (!plan.exists) return null;
    return FirestoreMappers.menuFromMap(plan.data()!['menu']);
  }

  /// Guarda el menú y rehace los días desde esta semana. Si es el primer
  /// plan, también pone las porciones y la meta de actividad iniciales.
  static Future<void> publish({
    required String patientUid,
    required String nutriUid,
    required WeekMenu menu,
    Clock clock = DateTime.now,
  }) async {
    final DocumentReference<Map<String, dynamic>> planRef = FirestorePaths.plan(
      patientUid,
    );
    final DocumentSnapshot<Map<String, dynamic>> plan = await planRef.get();
    final Portions minimums = menu.minimumTargets;
    final WriteBatch batch = FirestorePaths.db.batch();
    if (plan.exists) {
      final Portions old = FirestoreMappers.portionsFromMap(
        plan.data()!['dailyTargets'],
      );
      batch.update(planRef, <String, dynamic>{
        'menu': FirestoreMappers.menuToMap(menu),
        'nutritionistId': nutriUid,
        'publishedAt': Timestamp.now(),
        'dailyTargets': FirestoreMappers.portionsToMap(_atLeast(old, minimums)),
      });
    } else {
      batch.set(planRef, <String, dynamic>{
        'id': 'plan-$patientUid',
        'nutritionistId': nutriUid,
        'publishedAt': Timestamp.now(),
        'weeks': 4,
        'dailyTargets': FirestoreMappers.portionsToMap(minimums),
        'activityGoal': FirestoreMappers.goalToMap(ActivityGoal.recommended()),
        'previousWeekAdherence': 0,
        'menu': FirestoreMappers.menuToMap(menu),
      });
    }
    final DateTime monday = mondayOf(clock());
    final QuerySnapshot<Map<String, dynamic>> saved = await FirestorePaths.days(
      patientUid,
    ).where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monday)).get();
    final Map<String, DayPlan> current = <String, DayPlan>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in saved.docs)
        d.id: FirestoreMappers.dayFromMap(d.data()),
    };
    // Esta semana siempre; las siguientes solo si ya existían.
    final Set<String> ids = <String>{
      for (int i = 0; i < WeekMenu.days; i++)
        FirestoreMappers.dayId(
          DateTime(monday.year, monday.month, monday.day + i),
        ),
      ...current.keys,
    };
    for (final String id in ids) {
      final DateTime date = current[id]?.date ?? DateTime.parse(id);
      batch.set(
        FirestorePaths.days(patientUid).doc(id),
        FirestoreMappers.dayToMap(menu.dayFor(date, current: current[id])),
      );
    }
    await batch.commit();
  }

  /// Al empezar una semana nueva, crea sus días a partir del menú.
  static Future<void> ensureWeek(
    String uid, {
    Clock clock = DateTime.now,
  }) async {
    final DateTime monday = mondayOf(clock());
    final DocumentSnapshot<Map<String, dynamic>> first =
        await FirestorePaths.days(uid)
            .doc(FirestoreMappers.dayId(monday))
            .get();
    if (first.exists) return;
    final WeekMenu? menu = await loadMenu(uid);
    if (menu == null || !menu.complete) return;
    final WriteBatch batch = FirestorePaths.db.batch();
    for (int i = 0; i < WeekMenu.days; i++) {
      final DateTime date = DateTime(monday.year, monday.month, monday.day + i);
      batch.set(
        FirestorePaths.days(uid).doc(FirestoreMappers.dayId(date)),
        FirestoreMappers.dayToMap(menu.dayFor(date)),
      );
    }
    await batch.commit();
  }

  /// Lo mayor de las dos porciones en cada grupo.
  static Portions _atLeast(Portions a, Portions b) =>
      Portions(<FoodGroup, double>{
        for (final FoodGroup g in FoodGroup.values)
          if (a[g] > 0 || b[g] > 0) g: a[g] > b[g] ? a[g] : b[g],
      });
}
