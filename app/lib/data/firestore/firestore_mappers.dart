import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/clock.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/equivalent_option.dart';
import '../../domain/models/food_group.dart';
import '../../domain/models/measurement.dart';
import '../../domain/models/patient.dart';
import '../../domain/models/plan.dart';
import '../../domain/models/portions.dart';

/// Convierte los modelos a mapas de Firestore y de regreso.
abstract final class FirestoreMappers {
  static double _num(Object? v) => (v as num).toDouble();

  static double? _numOrNull(Object? v) => v == null ? null : _num(v);

  static DateTime _date(Object? v) => (v as Timestamp).toDate();

  /// Id del documento de un día, por ejemplo 2026-11-12.
  static String dayId(DateTime d) {
    final String m = d.month.toString().padLeft(2, '0');
    final String day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  // Porciones: {grupo: cantidad}
  static Map<String, double> portionsToMap(Portions p) => <String, double>{
    for (final MapEntry<FoodGroup, double> e in p.entries) e.key.name: e.value,
  };

  static Portions portionsFromMap(Object? raw) {
    final Map<String, dynamic> m = (raw as Map<String, dynamic>?) ?? {};
    return Portions(<FoodGroup, double>{
      for (final FoodGroup g in FoodGroup.values)
        if (m[g.name] != null) g: _num(m[g.name]),
    });
  }

  // Comidas y días
  static Map<String, dynamic> mealToMap(Meal m) => <String, dynamic>{
    'id': m.id,
    'slot': m.slot.name,
    'time': m.time,
    'dish': m.dish,
    'portions': portionsToMap(m.portions),
    'done': m.done,
    'swappedFrom': m.swappedFrom,
  };

  static Meal mealFromMap(Map<String, dynamic> m) => Meal(
    id: m['id'] as String,
    slot: MealSlot.values.byName(m['slot'] as String),
    time: m['time'] as String,
    dish: m['dish'] as String,
    portions: portionsFromMap(m['portions']),
    done: (m['done'] as bool?) ?? false,
    swappedFrom: m['swappedFrom'] as String?,
  );

  static Map<String, dynamic> dayToMap(DayPlan d) => <String, dynamic>{
    'date': Timestamp.fromDate(dateOnly(d.date)),
    'meals': <Map<String, dynamic>>[for (final Meal m in d.meals) mealToMap(m)],
  };

  static DayPlan dayFromMap(Map<String, dynamic> m) => DayPlan(
    date: _date(m['date']),
    meals: <Meal>[
      for (final Object? meal in m['meals'] as List<dynamic>)
        mealFromMap(meal as Map<String, dynamic>),
    ],
  );

  // Actividad
  static Map<String, dynamic> goalToMap(ActivityGoal g) => <String, dynamic>{
    'sessions': g.sessions,
    'minutes': g.minutes,
    'types': <Map<String, dynamic>>[
      for (final ActivityType t in g.types)
        <String, dynamic>{
          'kind': t.kind.name,
          'defaultMin': t.defaultMin,
          'kcalPerMin': t.kcalPerMin,
        },
    ],
  };

  static ActivityGoal goalFromMap(Map<String, dynamic> m) => ActivityGoal(
    sessions: m['sessions'] as int,
    minutes: m['minutes'] as int,
    types: <ActivityType>[
      for (final Object? raw in m['types'] as List<dynamic>)
        ActivityType(
          kind: ActivityKind.values.byName(
            (raw as Map<String, dynamic>)['kind'] as String,
          ),
          defaultMin: raw['defaultMin'] as int,
          kcalPerMin: _num(raw['kcalPerMin']),
        ),
    ],
  );

  static Map<String, dynamic> logToMap(ActivityLog l) => <String, dynamic>{
    'patientId': l.patientId,
    'date': Timestamp.fromDate(dateOnly(l.date)),
    'kind': l.kind.name,
    'minutes': l.minutes,
    'kcal': l.kcal,
  };

  static ActivityLog logFromMap(String id, Map<String, dynamic> m) =>
      ActivityLog(
        id: id,
        patientId: m['patientId'] as String,
        date: _date(m['date']),
        kind: ActivityKind.values.byName(m['kind'] as String),
        minutes: m['minutes'] as int,
        kcal: m['kcal'] as int,
      );

  // Datos generales del plan (los días van en su propia colección)
  static Map<String, dynamic> planToMap(Plan p) => <String, dynamic>{
    'id': p.id,
    'nutritionistId': p.nutritionistId,
    'publishedAt': Timestamp.fromDate(p.publishedAt),
    'weeks': p.weeks,
    'dailyTargets': portionsToMap(p.dailyTargets),
    'activityGoal': goalToMap(p.activityGoal),
    'previousWeekAdherence': p.previousWeekAdherence,
  };

  static Plan planFromMap(
    String patientId,
    Map<String, dynamic> m,
    List<DayPlan> days,
  ) => Plan(
    id: m['id'] as String,
    patientId: patientId,
    nutritionistId: (m['nutritionistId'] as String?) ?? '',
    publishedAt: _date(m['publishedAt']),
    weeks: m['weeks'] as int,
    dailyTargets: portionsFromMap(m['dailyTargets']),
    days: days,
    activityGoal: goalFromMap(m['activityGoal'] as Map<String, dynamic>),
    previousWeekAdherence: m['previousWeekAdherence'] as int,
  );

  // Opciones equivalentes (catálogo compartido)
  static Map<String, dynamic> optionToMap(EquivalentOption o) =>
      <String, dynamic>{
        'slot': o.slot.name,
        'dish': o.dish,
        'portions': portionsToMap(o.portions),
      };

  static EquivalentOption optionFromMap(String id, Map<String, dynamic> m) =>
      EquivalentOption(
        id: id,
        slot: MealSlot.values.byName(m['slot'] as String),
        dish: m['dish'] as String,
        portions: portionsFromMap(m['portions']),
      );

  // Medidas
  static Map<String, dynamic> measurementToMap(Measurement m) =>
      <String, dynamic>{
        'patientId': m.patientId,
        'date': Timestamp.fromDate(m.date),
        'weightKg': m.weightKg,
        'heightM': m.heightM,
        'bodyFatPct': m.bodyFatPct,
        'muscleKg': m.muscleKg,
        'skinfolds': <String, double?>{
          'tricipital': m.skinfolds.tricipital,
          'bicipital': m.skinfolds.bicipital,
          'subescapular': m.skinfolds.subescapular,
          'suprailiaco': m.skinfolds.suprailiaco,
        },
        'circumferences': <String, double?>{
          'brazo': m.circumferences.brazo,
          'cintura': m.circumferences.cintura,
          'cadera': m.circumferences.cadera,
          'muslo': m.circumferences.muslo,
          'pantorrilla': m.circumferences.pantorrilla,
        },
      };

  static Measurement measurementFromMap(String id, Map<String, dynamic> m) {
    final Map<String, dynamic> s = m['skinfolds'] as Map<String, dynamic>;
    final Map<String, dynamic> c = m['circumferences'] as Map<String, dynamic>;
    return Measurement(
      id: id,
      patientId: m['patientId'] as String,
      date: _date(m['date']),
      weightKg: _num(m['weightKg']),
      heightM: _num(m['heightM']),
      bodyFatPct: _num(m['bodyFatPct']),
      muscleKg: _num(m['muscleKg']),
      skinfolds: Skinfolds(
        tricipital: _numOrNull(s['tricipital']),
        bicipital: _numOrNull(s['bicipital']),
        subescapular: _numOrNull(s['subescapular']),
        suprailiaco: _numOrNull(s['suprailiaco']),
      ),
      circumferences: Circumferences(
        brazo: _numOrNull(c['brazo']),
        cintura: _numOrNull(c['cintura']),
        cadera: _numOrNull(c['cadera']),
        muslo: _numOrNull(c['muslo']),
        pantorrilla: _numOrNull(c['pantorrilla']),
      ),
    );
  }

  // Paciente (documento del usuario) y nutriólogo
  static Patient patientFromMap(String uid, Map<String, dynamic> m) => Patient(
    id: uid,
    name: m['name'] as String,
    birthDate: _date(m['birthDate']),
    sex: m['sex'] as String,
    objective: m['objective'] as String,
    nutritionistId: _idOrNull(m['nutritionistId']),
    profileComplete: m['profileComplete'] != false,
  );

  static String? _idOrNull(Object? v) =>
      (v is String && v.isNotEmpty) ? v : null;

  static Nutritionist nutritionistFromMap(String id, Map<String, dynamic> m) =>
      Nutritionist(id: id, name: m['name'] as String);
}
