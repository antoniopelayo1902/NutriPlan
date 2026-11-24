import 'package:nutriplan/core/clock.dart';
import 'package:nutriplan/domain/models/activity.dart';
import 'package:nutriplan/domain/models/equivalent_option.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/measurement.dart';
import 'package:nutriplan/domain/models/patient.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/domain/models/portions.dart';

/// Clearly fictional seed data for the local mock. Dates are relative to the
/// injected clock's current Mon-Sun week.
class SeedData {
  SeedData._({
    required this.patient,
    required this.nutritionist,
    required this.plan,
    required this.options,
    required this.logs,
    required this.goal,
    required this.measurements,
  });

  final Patient patient;
  final Nutritionist nutritionist;
  final Plan plan;
  final Map<MealSlot, List<EquivalentOption>> options;
  final List<ActivityLog> logs;
  final ActivityGoal goal;
  final List<Measurement> measurements;

  static const String patientId = 'pat-1';
  static const String nutritionistId = 'nut-1';

  /// Adherence of the week before the seeded one.
  static const int previousWeekAdherence = 68;

  static Portions _p(Map<FoodGroup, double> m) => Portions(m);

  static final Portions dailyTargets = _p(<FoodGroup, double>{
    FoodGroup.verdura: 5,
    FoodGroup.fruta: 3,
    FoodGroup.cereal: 8,
    FoodGroup.aoa: 6,
    FoodGroup.leguminosa: 1,
    FoodGroup.leche: 2,
    FoodGroup.grasa: 5,
    FoodGroup.azucar: 1,
  });

  static final Map<MealSlot, Portions> _slotPortions = <MealSlot, Portions>{
    MealSlot.desayuno: _p(<FoodGroup, double>{
      FoodGroup.verdura: 1,
      FoodGroup.cereal: 2,
      FoodGroup.aoa: 1,
      FoodGroup.fruta: 1,
      FoodGroup.grasa: 1,
      FoodGroup.leche: 1,
    }),
    MealSlot.colacion: _p(<FoodGroup, double>{
      FoodGroup.fruta: 1,
      FoodGroup.grasa: 1,
    }),
    MealSlot.comida: _p(<FoodGroup, double>{
      FoodGroup.verdura: 2,
      FoodGroup.cereal: 3,
      FoodGroup.aoa: 3,
      FoodGroup.leguminosa: 1,
      FoodGroup.grasa: 2,
      FoodGroup.fruta: 1,
    }),
    MealSlot.cena: _p(<FoodGroup, double>{
      FoodGroup.verdura: 2,
      FoodGroup.cereal: 2,
      FoodGroup.aoa: 2,
      FoodGroup.grasa: 1,
      FoodGroup.leche: 1,
    }),
  };

  /// Porciones originales de un tiempo de comida.
  static Portions slotPortions(MealSlot slot) => _slotPortions[slot]!;

  static const Map<MealSlot, String> _times = <MealSlot, String>{
    MealSlot.desayuno: '08:00',
    MealSlot.colacion: '11:00',
    MealSlot.comida: '14:30',
    MealSlot.cena: '20:00',
  };

  static const Map<MealSlot, List<String>> _dishes = <MealSlot, List<String>>{
    MealSlot.desayuno: <String>[
      'Huevo a la mexicana con tortillas y papaya',
      'Omelette de espinaca con pan integral y melón',
      'Yogurt natural con avena, fresas y nueces',
    ],
    MealSlot.colacion: <String>[
      'Manzana con crema de cacahuate',
      'Pera con almendras',
      'Mandarinas con nueces',
    ],
    MealSlot.comida: <String>[
      'Pechuga a la plancha con arroz, frijoles y ensalada',
      'Tinga de pollo con arroz rojo y frijoles',
      'Pescado al ajillo con arroz y ensalada de nopales',
    ],
    MealSlot.cena: <String>[
      'Quesadillas de champiñón con ensalada',
      'Sándwich de pavo con jitomate y lechuga',
      'Tostadas de frijol con queso panela',
    ],
  };

  /// Done pattern for days before today: partial, complete, complete,
  /// pending, complete, complete.
  static const List<int> _pastPattern = <int>[1, 2, 2, 0, 2, 2];

  static String mealId(int dayIndex, MealSlot slot) =>
      'd$dayIndex-${slot.name}';

  static SeedData build(Clock clock) {
    final DateTime today = dateOnly(clock());
    final DateTime monday = mondayOf(today);
    final int todayIdx = today.weekday - DateTime.monday;

    final List<DayPlan> days = <DayPlan>[];
    for (int i = 0; i < 7; i++) {
      final DateTime date = DateTime(monday.year, monday.month, monday.day + i);
      days.add(
        DayPlan(
          date: date,
          meals: <Meal>[
            for (final MealSlot slot in MealSlot.values)
              _meal(i, slot, todayIdx),
          ],
        ),
      );
    }

    final List<ActivityType> types = <ActivityType>[
      ActivityType(kind: ActivityKind.caminata, defaultMin: 30, kcalPerMin: 4),
      ActivityType(kind: ActivityKind.fuerza, defaultMin: 45, kcalPerMin: 5),
      ActivityType(kind: ActivityKind.bici, defaultMin: 40, kcalPerMin: 7),
      ActivityType(kind: ActivityKind.yoga, defaultMin: 30, kcalPerMin: 3),
    ];
    final ActivityGoal goal = ActivityGoal(
      sessions: 5,
      minutes: 150,
      types: types,
    );

    DateTime logDay(int idx) => DateTime(
      monday.year,
      monday.month,
      monday.day + (idx < todayIdx ? idx : todayIdx),
    );
    final List<ActivityLog> logs = <ActivityLog>[
      _log('log-1', logDay(0), types[0], 30),
      _log('log-2', logDay(2), types[1], 45),
      _log('log-3', logDay(3), types[2], 40),
    ];

    return SeedData._(
      patient: Patient(
        id: patientId,
        name: 'Laura Méndez',
        birthDate: DateTime(1991, 5, 14),
        sex: 'F',
        objective: 'Bajar grasa corporal',
        nutritionistId: nutritionistId,
      ),
      nutritionist: Nutritionist(id: nutritionistId, name: 'Nut. Ana Rivas'),
      plan: Plan(
        id: 'plan-1',
        patientId: patientId,
        nutritionistId: nutritionistId,
        publishedAt: DateTime(monday.year, monday.month, monday.day - 2),
        weeks: 4,
        dailyTargets: dailyTargets,
        days: days,
        activityGoal: goal,
        previousWeekAdherence: previousWeekAdherence,
      ),
      options: _buildOptions(),
      logs: logs,
      goal: goal,
      measurements: _buildMeasurements(),
    );
  }

  static ActivityLog _log(
    String id,
    DateTime date,
    ActivityType type,
    int minutes,
  ) {
    return ActivityLog(
      id: id,
      patientId: patientId,
      date: date,
      kind: type.kind,
      minutes: minutes,
      kcal: type.kcalFor(minutes),
    );
  }

  static Meal _meal(int dayIdx, MealSlot slot, int todayIdx) {
    bool done;
    if (dayIdx > todayIdx) {
      done = false;
    } else if (dayIdx == todayIdx) {
      done = slot == MealSlot.desayuno || slot == MealSlot.colacion;
    } else {
      final int level = _pastPattern[dayIdx % _pastPattern.length];
      done =
          level == 2 ||
          (level == 1 &&
              (slot == MealSlot.desayuno || slot == MealSlot.colacion));
    }
    String dish = _dishes[slot]![dayIdx % 3];
    Portions portions = _slotPortions[slot]!;
    String? swappedFrom;
    if (dayIdx == todayIdx && slot == MealSlot.colacion) {
      swappedFrom = dish;
      dish = 'Papaya con granola';
      portions = _p(<FoodGroup, double>{
        FoodGroup.fruta: 1,
        FoodGroup.cereal: 1,
      });
    }
    return Meal(
      id: mealId(dayIdx, slot),
      slot: slot,
      time: _times[slot]!,
      dish: dish,
      portions: portions,
      done: done,
      swappedFrom: swappedFrom,
    );
  }

  static EquivalentOption _opt(
    int n,
    MealSlot slot,
    String dish,
    Map<FoodGroup, double> p,
  ) {
    return EquivalentOption(
      id: 'opt-${slot.name}-$n',
      slot: slot,
      dish: dish,
      portions: _p(p),
    );
  }

  static Map<MealSlot, List<EquivalentOption>> _buildOptions() {
    const FoodGroup v = FoodGroup.verdura;
    const FoodGroup f = FoodGroup.fruta;
    const FoodGroup c = FoodGroup.cereal;
    const FoodGroup a = FoodGroup.aoa;
    const FoodGroup lg = FoodGroup.leguminosa;
    const FoodGroup l = FoodGroup.leche;
    const FoodGroup g = FoodGroup.grasa;
    const FoodGroup z = FoodGroup.azucar;
    return <MealSlot, List<EquivalentOption>>{
      MealSlot.desayuno: <EquivalentOption>[
        _opt(
          1,
          MealSlot.desayuno,
          'Avena con fruta y nueces',
          <FoodGroup, double>{c: 2, f: 1, g: 1, l: 1},
        ),
        _opt(
          2,
          MealSlot.desayuno,
          'Chilaquiles verdes con huevo',
          <FoodGroup, double>{c: 3, a: 1, g: 1, v: 1},
        ),
        _opt(3, MealSlot.desayuno, 'Molletes con queso', <FoodGroup, double>{
          c: 3,
          a: 2,
          g: 1,
        }),
        _opt(
          4,
          MealSlot.desayuno,
          'Pan dulce con café con leche',
          <FoodGroup, double>{c: 4, z: 1, l: 1},
        ),
        _opt(
          5,
          MealSlot.desayuno,
          'Hot cakes con miel y plátano',
          <FoodGroup, double>{c: 3, f: 1, z: 2},
        ),
      ],
      MealSlot.colacion: <EquivalentOption>[
        _opt(1, MealSlot.colacion, 'Papaya con granola', <FoodGroup, double>{
          f: 1,
          c: 1,
        }),
        _opt(2, MealSlot.colacion, 'Naranja con nueces', <FoodGroup, double>{
          f: 1,
          g: 1,
        }),
        _opt(
          3,
          MealSlot.colacion,
          'Pepino con limón y tostadas',
          <FoodGroup, double>{v: 1, c: 1},
        ),
        _opt(
          4,
          MealSlot.colacion,
          'Yogurt natural con fresas',
          <FoodGroup, double>{l: 1, f: 1},
        ),
        _opt(
          5,
          MealSlot.colacion,
          'Galletas con chocolate',
          <FoodGroup, double>{c: 2, z: 2, g: 1},
        ),
      ],
      MealSlot.comida: <EquivalentOption>[
        _opt(
          1,
          MealSlot.comida,
          'Caldo de pollo con verduras y arroz',
          <FoodGroup, double>{v: 2, c: 2, a: 3, lg: 1, g: 2, f: 1},
        ),
        _opt(
          2,
          MealSlot.comida,
          'Sopa de lentejas con tostadas',
          <FoodGroup, double>{v: 1, c: 2, lg: 1, a: 2, g: 1, f: 1},
        ),
        _opt(
          3,
          MealSlot.comida,
          'Hamburguesa de res con papas al horno',
          <FoodGroup, double>{v: 1, c: 3, a: 3.5, g: 2},
        ),
        _opt(
          4,
          MealSlot.comida,
          'Pizza de pepperoni (3 rebanadas)',
          <FoodGroup, double>{c: 4, a: 3, g: 5},
        ),
        _opt(5, MealSlot.comida, 'Pasta Alfredo con pollo', <FoodGroup, double>{
          c: 5,
          a: 2,
          l: 2,
          g: 4,
        }),
      ],
      MealSlot.cena: <EquivalentOption>[
        _opt(
          1,
          MealSlot.cena,
          'Sincronizadas de jamón y queso con ensalada',
          <FoodGroup, double>{v: 2, c: 2, a: 2, l: 1, g: 1},
        ),
        _opt(
          2,
          MealSlot.cena,
          'Crema de calabacita con tostadas',
          <FoodGroup, double>{v: 2, c: 2, a: 1, l: 1, g: 1},
        ),
        _opt(3, MealSlot.cena, 'Tostadas de tinga', <FoodGroup, double>{
          v: 1,
          c: 3,
          a: 2,
          g: 2,
        }),
        _opt(4, MealSlot.cena, 'Sopa instantánea con pan', <FoodGroup, double>{
          c: 4,
          a: 1,
          v: 1,
        }),
        _opt(5, MealSlot.cena, 'Pizza de cuatro quesos', <FoodGroup, double>{
          c: 4,
          a: 3,
          g: 3,
        }),
      ],
    };
  }

  static List<Measurement> _buildMeasurements() {
    Measurement m(
      int n,
      DateTime date,
      double weight,
      double fat,
      double muscle,
      List<double> skin,
      List<double> circ,
    ) {
      return Measurement(
        id: 'meas-$n',
        patientId: patientId,
        date: date,
        weightKg: weight,
        heightM: 1.63,
        bodyFatPct: fat,
        muscleKg: muscle,
        skinfolds: Skinfolds(
          tricipital: skin[0],
          bicipital: skin[1],
          subescapular: skin[2],
          suprailiaco: skin[3],
        ),
        circumferences: Circumferences(
          brazo: circ[0],
          cintura: circ[1],
          cadera: circ[2],
          muslo: circ[3],
          pantorrilla: circ[4],
        ),
      );
    }

    return <Measurement>[
      m(
        1,
        DateTime(2026, 6, 12),
        73.0,
        29.5,
        22.1,
        <double>[24, 11, 20, 22],
        <double>[29.5, 84, 102, 58.5, 37],
      ),
      m(
        2,
        DateTime(2026, 7, 10),
        72.4,
        28.4,
        22.4,
        <double>[22.5, 10.5, 19, 20.5],
        <double>[29.2, 82.5, 101.2, 58, 36.8],
      ),
      m(
        3,
        DateTime(2026, 8, 14),
        71.9,
        27.6,
        22.8,
        <double>[21, 10, 18, 19],
        <double>[29, 81, 100.5, 57.5, 36.6],
      ),
      m(
        4,
        DateTime(2026, 9, 11),
        71.2,
        26.7,
        23.0,
        <double>[19.5, 9.5, 17, 18],
        <double>[28.8, 79.5, 99.8, 57, 36.5],
      ),
    ];
  }
}
