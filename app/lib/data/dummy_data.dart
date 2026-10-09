import '../models/activity_entry.dart';
import '../models/food_group.dart';
import '../models/meal.dart';
import '../models/measures.dart';

// Datos "hardcodeados" para la Entrega 1, igual que dummy_data en
// Las Recetas de la Abuela. Después vendrán de la base de datos.

// ---------------------------------------------------------------------------
// Usuario y nutrióloga
// ---------------------------------------------------------------------------

const String userName = 'Laura Méndez';
const String userInitials = 'LM';
const String userEmail = 'laura.mendez@correo.com';
const String nutritionistName = 'Ana';
const String nutritionistFullName = 'Ana García';
const String nutritionistInitials = 'AG';

// ---------------------------------------------------------------------------
// Grupos de equivalentes y porciones diarias de la dieta
// ---------------------------------------------------------------------------

const List<FoodGroup> foodGroups = [
  FoodGroup(key: 'Verdura', name: 'Verduras', kcalPerPortion: 25),
  FoodGroup(key: 'Fruta', name: 'Frutas', kcalPerPortion: 60),
  FoodGroup(key: 'Cereal', name: 'Cereales y tubérculos', kcalPerPortion: 70),
  FoodGroup(key: 'AOA', name: 'Origen animal', kcalPerPortion: 75),
  FoodGroup(key: 'Leguminosa', name: 'Leguminosas', kcalPerPortion: 120),
  FoodGroup(key: 'Leche', name: 'Leche', kcalPerPortion: 95),
  FoodGroup(key: 'Grasa', name: 'Aceites y grasas', kcalPerPortion: 45),
];

/// Equivalentes por día que indicó la nutrióloga (clave = FoodGroup.key).
const Map<String, int> dailyTargets = {
  'Verdura': 4,
  'Fruta': 3,
  'Cereal': 5,
  'AOA': 5,
  'Leguminosa': 1,
  'Leche': 2,
  'Grasa': 3,
};

// ---------------------------------------------------------------------------
// Semana: lunes 12 a domingo 18 de septiembre. "Hoy" es el viernes.
// ---------------------------------------------------------------------------

const List<String> weekDayLetters = ['L', 'M', 'MI', 'J', 'V', 'S', 'D'];
const List<String> weekDayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
const List<int> weekDayNumbers = [12, 13, 14, 15, 16, 17, 18];
const int todayIndex = 4;
const String monthName = 'septiembre';

/// Cómo le fue cada día anterior: 'ok' (cumplió), 'partial' (a medias), 'future'.
const List<String> dayStatus = ['ok', 'partial', 'ok', 'partial', 'today', 'future', 'future'];

/// Las cuatro comidas base del plan (las del mock).
const List<Meal> baseMeals = [
  Meal(
    id: 'desayuno',
    mealTime: 'Desayuno',
    hour: '8:00',
    name: 'Tostadas de aguacate y huevo',
    portions: {'Cereal': 2, 'Grasa': 1, 'AOA': 1, 'Leche': 1},
  ),
  Meal(id: 'colacion', mealTime: 'Colación', hour: '11:00', name: 'Uvas', portions: {'Fruta': 1}),
  Meal(
    id: 'comida',
    mealTime: 'Comida',
    hour: '14:30',
    name: 'Pescado empapelado con verduras',
    portions: {'AOA': 3, 'Verdura': 2, 'Cereal': 2, 'Grasa': 1, 'Fruta': 1},
  ),
  Meal(
    id: 'cena',
    mealTime: 'Cena',
    hour: '20:00',
    name: 'Crema de calabaza y queso panela',
    portions: {'Verdura': 2, 'AOA': 1, 'Cereal': 1, 'Leguminosa': 1, 'Leche': 1, 'Grasa': 1, 'Fruta': 1},
  ),
];

/// Platillos alternativos con los mismos equivalentes, por tiempo de comida.
/// Son las opciones que aparecen al presionar "Cambiar".
const Map<String, List<String>> swapOptions = {
  'desayuno': [
    'Molletes con frijol y pico de gallo',
    'Avena con fruta y huevo cocido',
    'Sincronizada de jamón de pavo',
  ],
  'colacion': ['Manzana', 'Mango en cubos', 'Fresas con yogur natural'],
  'comida': [
    'Pollo a la plancha con arroz y ensalada',
    'Tacos de bistec con nopales',
    'Atún a la mexicana con tostadas',
  ],
  'cena': ['Quesadillas de flor de calabaza', 'Sopa de verduras con queso fresco', 'Ensalada de pollo con frijoles'],
};

/// Arma las comidas de un día. Para que la semana no se vea igual todos
/// los días, cada día toma un platillo distinto de las alternativas.
List<Meal> mealsForDay(int day) {
  final List<Meal> meals = [];
  for (final Meal meal in baseMeals) {
    final List<String> options = swapOptions[meal.id]!;
    // El viernes (hoy) y el lunes usan el platillo original del mock.
    final int pick = day % 4;
    String name = meal.name;
    if (pick > 0) {
      name = options[pick - 1];
    }
    meals.add(Meal(id: meal.id, mealTime: meal.mealTime, hour: meal.hour, name: name, portions: meal.portions));
  }
  return meals;
}

// ---------------------------------------------------------------------------
// Actividad física
// ---------------------------------------------------------------------------

const int weeklyMovementGoal = 150; // minutos
const int weeklySessionsGoal = 5;

const List<ActivityEntry> initialActivities = [
  ActivityEntry(type: 'Caminata', day: 'Lun', dayIndex: 0, minutes: 35, kcal: 160),
  ActivityEntry(type: 'Fuerza', day: 'Mar', dayIndex: 1, minutes: 45, kcal: 210),
  ActivityEntry(type: 'Caminata', day: 'Mié', dayIndex: 2, minutes: 30, kcal: 140),
  ActivityEntry(type: 'Bici', day: 'Jue', dayIndex: 3, minutes: 40, kcal: 230),
];

const List<QuickActivity> quickActivities = [
  QuickActivity(type: 'Caminata', minutes: 30, kcalPerMinute: 5),
  QuickActivity(type: 'Fuerza', minutes: 45, kcalPerMinute: 5),
  QuickActivity(type: 'Bici', minutes: 40, kcalPerMinute: 6),
  QuickActivity(type: 'Yoga', minutes: 30, kcalPerMinute: 3),
];

const List<String> activityDayLetters = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];

// ---------------------------------------------------------------------------
// Progreso
// ---------------------------------------------------------------------------

/// Apego de cada día de la semana (0 a 1). Viernes a domingo aún sin datos.
const List<double> weekAdherence = [1.0, 0.75, 1.0, 0.75, 0.05, 0.05, 0.05];
const int weekAdherencePercent = 88;
const int adherenceChange = 4;
const int distinctFoods = 26;
const double weightChangeThisWeek = -0.6;
const int streakDays = 12;
const List<String> achievements = ['Semana completa', '5 cambios inteligentes', 'Desayuno siempre'];

const List<MeasureSeries> measureSeries = [
  MeasureSeries(name: 'Peso', unit: 'kg', months: ['Jun', 'Jul', 'Ago', 'Sep'], values: [74.8, 73.4, 72.1, 71.2]),
  MeasureSeries(name: '% de grasa', unit: '%', months: ['Jun', 'Jul', 'Ago', 'Sep'], values: [37.2, 36.4, 35.5, 34.8]),
  MeasureSeries(
    name: 'Masa muscular',
    unit: 'kg',
    months: ['Jun', 'Jul', 'Ago', 'Sep'],
    values: [24.3, 24.6, 24.9, 25.1],
  ),
  MeasureSeries(name: 'Cintura', unit: 'cm', months: ['Jun', 'Jul', 'Ago', 'Sep'], values: [89.0, 87.0, 85.5, 84.0]),
];

/// Resumen de la última medición (encabezado de "Composición corporal").
const Map<String, String> compositionSummary = {
  'Peso': '71,2 kg',
  'Talla': '1,62 m',
  'Grasa': '34,8 %',
  'Músculo': '25,1 kg',
};
const String lastMeasurementDate = '4 de sep';

/// Puntos sobre la silueta. left/top son relativos a una figura de 140 x 380.
const List<BodyPoint> bodyPoints = [
  BodyPoint(label: 'Tricipital', value: '23,5 mm', left: 22, top: 96, labelOnLeft: true),
  BodyPoint(label: 'Subescapular', value: '19,0 mm', left: 50, top: 146, labelOnLeft: true),
  BodyPoint(label: 'Suprailiaco', value: '26,0 mm', left: 52, top: 198, labelOnLeft: true),
  BodyPoint(label: 'Pantorrilla', value: '35,0 cm', left: 52, top: 318, labelOnLeft: true),
  BodyPoint(label: 'Brazo relajado', value: '29,0 cm', left: 117, top: 104, labelOnLeft: false),
  BodyPoint(label: 'Cintura', value: '84,0 cm', left: 92, top: 156, labelOnLeft: false),
  BodyPoint(label: 'Cadera', value: '98,0 cm', left: 98, top: 204, labelOnLeft: false),
  BodyPoint(label: 'Muslo medio', value: '56,0 cm', left: 88, top: 262, labelOnLeft: false),
];

// ---------------------------------------------------------------------------
// Pacientes (vista de la nutrióloga)
// ---------------------------------------------------------------------------

const List<Patient> patients = [
  Patient(
    name: 'Laura Méndez',
    initials: 'LM',
    age: 34,
    followUp: 'seguimiento mensual',
    visit: '3.ª consulta',
    measures: {
      'Peso': '71.2 kg',
      'Talla': '1.62 m',
      'Cintura': '84 cm',
      'Actividad': 'Ligera',
      'Pliegue tricipital': '',
    },
  ),
  Patient(
    name: 'Carlos Ruiz',
    initials: 'CR',
    age: 41,
    followUp: 'seguimiento quincenal',
    visit: '6.ª consulta',
    measures: {
      'Peso': '88.4 kg',
      'Talla': '1.78 m',
      'Cintura': '97 cm',
      'Actividad': 'Moderada',
      'Pliegue tricipital': '14 mm',
    },
  ),
  Patient(
    name: 'Sofía Hernández',
    initials: 'SH',
    age: 27,
    followUp: 'primera vez',
    visit: '1.ª consulta',
    measures: {'Peso': '58.0 kg', 'Talla': '1.60 m', 'Cintura': '70 cm', 'Actividad': 'Alta', 'Pliegue tricipital': ''},
  ),
];
