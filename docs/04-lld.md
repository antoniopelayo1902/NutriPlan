# NutriPlan: Diseño de Bajo Nivel (LLD)

| Campo | Valor |
|---|---|
| Versión | 1.6 |
| Fecha | 2026-10-04 |
| Documento previo | `03-hld.md` |

## 1. Propósito

Este documento especifica cómo se implementa cada componente del HLD: estructura de carpetas, esquema SQL, entidades, servicios de dominio con su algoritmo, controladores, navegación, formato del código compartido, configuración nativa y plan de pruebas. El código es el contrato; la implementación puede diferir en detalles sintácticos pero no en comportamiento.

Stack: Flutter 3.x, Dart 3.x, sin paquetes de estado ni navegación. Paquetes en producción: `sqflite`, `path`, `shared_preferences`, `qr_flutter`, `share_plus` (M); `mobile_scanner` (S/C); `flutter_local_notifications`, `timezone`, `flutter_timezone` (C). `sqflite_common_ffi` solo en `dev_dependencies`. Detalle y justificación en `02-investigacion-tecnica.md` §4.

## 2. Estructura del proyecto

```
nutriplan/
├── assets/data/
│   ├── subgroups.json          # 18 subgrupos SMAE
│   ├── food_catalog.json       # 120+ alimentos con alérgenos
│   └── diet_templates.json     # 7 plantillas con reparto fijo por tiempo
├── ios/Runner/Info.plist       # NSCameraUsageDescription
├── android/app/src/main/AndroidManifest.xml
├── lib/
│   ├── main.dart               # abre DB, crea repositorios y controladores; runApp(MyApp)
│   ├── my_app.dart             # MaterialApp, tema claro/oscuro, decide Onboarding o RootScreen
│   ├── core/
│   │   ├── strings.dart        # cadenas visibles (RNF-9)
│   │   ├── dates.dart          # dateOnly, dayBefore, isoDate
│   │   ├── ids.dart            # newId()
│   │   └── icons.dart          # Map<String, IconData> de íconos de hábitos
│   ├── domain/                 # sin imports de Flutter ni sqflite
│   │   ├── entities/
│   │   ├── repositories/       # clases abstractas
│   │   ├── services/
│   │   └── errors.dart
│   ├── data/
│   │   ├── db/app_database.dart
│   │   ├── db/schema.dart
│   │   ├── repositories/
│   │   ├── seed/catalog_loader.dart
│   │   ├── remote/off_client.dart
│   │   ├── notifications/notification_service.dart
│   │   └── prefs/settings_store.dart
│   ├── application/
│   │   ├── plan_controller.dart
│   │   ├── habit_controller.dart
│   │   ├── profile_controller.dart
│   │   ├── diet_editor_controller.dart
│   │   ├── generate_plan_use_case.dart
│   │   └── import_diet_use_case.dart
│   └── presentation/
│       ├── root_screen.dart    # NavigationBar + índice
│       ├── onboarding/ home/ plan/ diet_editor/ share/ habits/ progress/
│       ├── shopping/ scanner/ profile/
│       └── widgets/
└── test/
    ├── domain/ data/ presentation/
```

`architecture_test.dart` lee los archivos bajo `lib/domain` y falla si alguno importa `package:flutter`, `package:sqflite` o rutas de `lib/data` o `lib/presentation`.

## 3. Entidades de dominio

Clases inmutables escritas a mano. `Food` se muestra completa como patrón; las demás listan campos.

```dart
enum SubgroupCode {
  ver('ver'), fru('fru'), cerSg('cer_sg'), cerCg('cer_cg'), leg('leg'),
  aoaMbg('aoa_mbg'), aoaBg('aoa_bg'), aoaMg('aoa_mg'), aoaAg('aoa_ag'),
  lecD('lec_d'), lecSd('lec_sd'), lecE('lec_e'), lecA('lec_a'),
  graSp('gra_sp'), graCp('gra_cp'), azuSg('azu_sg'), azuCg('azu_cg'), lib('lib');

  const SubgroupCode(this.code);
  final String code;
  static SubgroupCode fromCode(String c) =>
      values.firstWhere((v) => v.code == c, orElse: () => throw MalformedData('subgroup $c'));
}

enum Allergen { gluten, dairy, egg, peanut, treeNut, shellfish, soy, fish }

class Food {
  const Food({
    required this.id, required this.subgroup, required this.name,
    required this.quantity, required this.unit, required this.grams,
    required this.kcal, required this.proteinG, required this.lipidG, required this.carbG,
    required this.source, this.allergens = const {}, this.isCustom = false,
  });
  final String id;
  final SubgroupCode subgroup;
  final String name;
  final double quantity;
  final String unit;
  final double grams;
  final int kcal;
  final double proteinG, lipidG, carbG;
  final String source;           // "smae_avg" | "usda:170000" | "user"
  final Set<Allergen> allergens;
  final bool isCustom;

  Map<String, Object?> toMap() => {
    'id': id, 'subgroup': subgroup.code, 'name': name, 'quantity': quantity,
    'unit': unit, 'grams': grams, 'kcal': kcal, 'protein_g': proteinG,
    'lipid_g': lipidG, 'carb_g': carbG, 'source': source,
    'allergens': allergens.map((a) => a.name).join(','), 'is_custom': isCustom ? 1 : 0,
  };
  factory Food.fromMap(Map<String, Object?> m) => Food(
    id: m['id'] as String, subgroup: SubgroupCode.fromCode(m['subgroup'] as String),
    name: m['name'] as String, quantity: (m['quantity'] as num).toDouble(),
    unit: m['unit'] as String, grams: (m['grams'] as num).toDouble(),
    kcal: m['kcal'] as int, proteinG: (m['protein_g'] as num).toDouble(),
    lipidG: (m['lipid_g'] as num).toDouble(), carbG: (m['carb_g'] as num).toDouble(),
    source: m['source'] as String,
    allergens: ((m['allergens'] as String?) ?? '').split(',').where((s) => s.isNotEmpty)
        .map((s) => Allergen.values.byName(s)).toSet(),
    isCustom: (m['is_custom'] as int? ?? 0) == 1,
  );
}
```

| Entidad | Campos |
|---|---|
| `Subgroup` | `code`, `name`, `groupName`, `kcal`, `proteinG`, `lipidG`, `carbG` |
| `MealType` (enum) | `breakfast('b')`, `snack1('s1')`, `lunch('l')`, `snack2('s2')`, `dinner('d')`, `snack3('s3')` con `code` y `fromCode` |
| `PrescribedEquivalent` | `subgroup`, `amount` (> 0, múltiplo de 0.5; el constructor lanza si no) |
| `MealSlot` | `id`, `type`, `sortOrder`, `time?`, `equivalents`; `copyWith` manual |
| `DietOrigin` (enum) | `nutritionist` (creada en este dispositivo), `imported`, `generated` |
| `Diet` | `id`, `name`, `patientLabel?`, `origin`, `targetKcal` (kcal reales de la prescripción), `startDate`, `weeks`, `meals`, `excludedFoodIds` (default `const {}`), `isActive` (default `false`), `updatedAt`; `copyWith` manual |
| `DietTemplate` | `kcal` (nominal), `meals` (lista de `MealSlot` con el reparto fijo); `daily` derivado sumando |
| `PlanItem` | `id`, `meal`, `subgroup`, `amount`, `foodId?`, `consumed`, `consumedAt?` |
| `DailyPlan` | `dietId`, `date`, `regenCount`, `materializedAt` (instante en que se construyeron los ítems; se actualiza al regenerar), `items` |
| `ExtraConsumption` | `id`, `date`, `subgroup`, `amount`, `foodId?`, `note?` |
| `Habit` | `id`, `name`, `iconKey` (clave de `core/icons.dart`), `weekdays` (Set<int> 1..7, no vacío; el constructor lanza si no), `active`, `createdAt` |
| `Sex`, `ActivityLevel`, `Goal`, `UserRole` (enums) | `male/female`; `sedentary/light/moderate/veryActive`; `lose/maintain/gain`; `nutritionist/user` |
| `UserProfile` | `name`, `role`, `sex?`, `birthDate?`, `heightCm?`, `weightKg?`, `activity?`, `goal?`, `waterGoalGlasses` (8), `licenseNumber?`, `excludedFoodIds`, `excludedAllergens`; `bool get completeForUser` |

`iconKey` se guarda como clave de un `Map<String, IconData>` constante y no como `codePoint`: un `IconData` construido en tiempo de ejecución rompe el tree-shaking de íconos en el build de release.

## 4. Esquema de base de datos (sqflite)

Versión 1. Fechas como texto ISO `YYYY-MM-DD`. Booleanos como `INTEGER` 0/1.

```dart
// data/db/app_database.dart
Future<Database> openAppDatabase({DatabaseFactory? factory, String? path, bool singleInstance = true}) {
  final f = factory ?? databaseFactory;
  return f.openDatabase(path ?? 'nutriplan.db', options: OpenDatabaseOptions(
    version: 1, singleInstance: singleInstance,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),   // SQLite lo trae apagado
    onCreate: (db, v) async {
      for (final s in schemaV1) await db.execute(s);
      await CatalogLoader.seed(db);                                // usa Batch, no transaction
    },
    onUpgrade: (db, from, to) async { /* switch (from) { case 1: ... } */ },
  ));
}
```

Aceptar `DatabaseFactory` permite inyectar `databaseFactoryFfi` en pruebas.

```sql
CREATE TABLE subgroups (
  code TEXT PRIMARY KEY, name TEXT NOT NULL, group_name TEXT NOT NULL,
  kcal INTEGER NOT NULL, protein_g REAL NOT NULL, lipid_g REAL NOT NULL, carb_g REAL NOT NULL);

CREATE TABLE foods (
  id TEXT PRIMARY KEY, subgroup TEXT NOT NULL REFERENCES subgroups(code),
  name TEXT NOT NULL, quantity REAL NOT NULL, unit TEXT NOT NULL, grams REAL NOT NULL,
  kcal INTEGER NOT NULL, protein_g REAL NOT NULL, lipid_g REAL NOT NULL, carb_g REAL NOT NULL,
  source TEXT NOT NULL, allergens TEXT NOT NULL DEFAULT '', is_custom INTEGER NOT NULL DEFAULT 0);
CREATE INDEX idx_foods_subgroup_name ON foods(subgroup, name);

CREATE TABLE profile (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  name TEXT NOT NULL, role TEXT NOT NULL, sex TEXT, birth_date TEXT, height_cm REAL,
  weight_kg REAL, activity TEXT, goal TEXT, water_goal INTEGER NOT NULL DEFAULT 8,
  license_number TEXT, excluded_allergens TEXT NOT NULL DEFAULT '',
  disclaimer_accepted_at TEXT);

CREATE TABLE user_exclusions (
  food_id TEXT PRIMARY KEY REFERENCES foods(id) ON DELETE CASCADE);

CREATE TABLE diets (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, patient_label TEXT, origin TEXT NOT NULL,
  target_kcal INTEGER NOT NULL, start_date TEXT NOT NULL, weeks INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
CREATE UNIQUE INDEX idx_diets_single_active ON diets(is_active) WHERE is_active = 1;

CREATE TABLE meal_slots (
  id TEXT PRIMARY KEY, diet_id TEXT NOT NULL REFERENCES diets(id) ON DELETE CASCADE,
  type TEXT NOT NULL, sort_order INTEGER NOT NULL, time TEXT);

CREATE TABLE prescribed_equivalents (
  meal_slot_id TEXT NOT NULL REFERENCES meal_slots(id) ON DELETE CASCADE,
  subgroup TEXT NOT NULL REFERENCES subgroups(code), amount REAL NOT NULL,
  PRIMARY KEY (meal_slot_id, subgroup));

CREATE TABLE diet_exclusions (
  diet_id TEXT NOT NULL REFERENCES diets(id) ON DELETE CASCADE,
  food_id TEXT NOT NULL REFERENCES foods(id) ON DELETE CASCADE,
  PRIMARY KEY (diet_id, food_id));

CREATE TABLE daily_plans (
  diet_id TEXT NOT NULL REFERENCES diets(id) ON DELETE CASCADE,
  date TEXT NOT NULL, regen_count INTEGER NOT NULL DEFAULT 0, materialized_at TEXT NOT NULL,
  PRIMARY KEY (diet_id, date));

CREATE TABLE plan_items (
  id TEXT PRIMARY KEY, diet_id TEXT NOT NULL, date TEXT NOT NULL,
  meal TEXT NOT NULL, subgroup TEXT NOT NULL REFERENCES subgroups(code),
  amount REAL NOT NULL, food_id TEXT REFERENCES foods(id) ON DELETE SET NULL,
  consumed INTEGER NOT NULL DEFAULT 0, consumed_at TEXT,
  FOREIGN KEY (diet_id, date) REFERENCES daily_plans(diet_id, date) ON DELETE CASCADE);
CREATE INDEX idx_plan_items_date ON plan_items(diet_id, date);

CREATE TABLE extra_consumptions (
  id TEXT PRIMARY KEY, date TEXT NOT NULL, subgroup TEXT NOT NULL REFERENCES subgroups(code),
  amount REAL NOT NULL, food_id TEXT REFERENCES foods(id) ON DELETE SET NULL, note TEXT);
CREATE INDEX idx_extra_date ON extra_consumptions(date);

CREATE TABLE habits (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, icon_key TEXT NOT NULL,
  weekdays TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL);

CREATE TABLE habit_logs (
  habit_id TEXT NOT NULL REFERENCES habits(id) ON DELETE CASCADE, date TEXT NOT NULL,
  PRIMARY KEY (habit_id, date));

CREATE TABLE water_logs (date TEXT PRIMARY KEY, glasses INTEGER NOT NULL);
CREATE TABLE weight_logs (date TEXT PRIMARY KEY, kg REAL NOT NULL);

CREATE TABLE shopping_items (
  id TEXT PRIMARY KEY, week_start TEXT NOT NULL, food_id TEXT REFERENCES foods(id) ON DELETE SET NULL,
  label TEXT NOT NULL, quantity REAL NOT NULL, unit TEXT NOT NULL,
  checked INTEGER NOT NULL DEFAULT 0, manual INTEGER NOT NULL DEFAULT 0);

CREATE TABLE scanned_products (
  barcode TEXT PRIMARY KEY, name TEXT NOT NULL, kcal100 REAL NOT NULL,
  protein100 REAL NOT NULL, lipid100 REAL NOT NULL, carb100 REAL NOT NULL, fetched_at TEXT NOT NULL);
```

**Dónde vive cada dato.** Todo lo anterior en SQLite. shared_preferences guarda únicamente `theme_mode` ("light"/"dark"/"system") y `onboarding_done` (bool).

**Invariantes garantizadas por la capa de datos:**
- Una sola dieta activa: el índice único parcial lo impone; `activate()` hace `UPDATE diets SET is_active = 0` y luego `= 1` para la nueva, en una transacción.
- `DietRepository.save` nunca usa `INSERT OR REPLACE` (con `foreign_keys` activo borraría la fila y la cascada arrasaría planes e ítems) ni `ON CONFLICT DO UPDATE` (requiere SQLite 3.24; Android 8 trae 3.18). Hace `update(...)` y, si devolvió 0 filas, `insert(...)`. Los hijos (tiempos, equivalentes, exclusiones) se borran y reinsertan dentro de la misma transacción. Si la dieta guardada es la activa, se borran sus `daily_plans` con `date > hoy` (los ítems caen por cascada) para que se materialicen con la prescripción nueva; hoy y los pasados se conservan. `PlanRepository.save` sigue la misma regla update/insert para `daily_plans` y reemplaza los `plan_items` del día.
- `plan_items.amount` coincide con el equivalente del que se materializó; `swapFood` cambia solo `food_id` y verifica el subgrupo antes de escribir.
- Borrar un alimento personalizado en uso pone `food_id` en NULL en vez de fallar (`ON DELETE SET NULL`), coherente con `foodId` nulable.

**Migraciones.** `version: 1`. `onUpgrade` con `switch (from)` vacío listo para versiones futuras.

## 5. Servicios de dominio

Convenciones: `import 'dart:math';` donde se usa `max`, `min`, `pow` o `Random`. `dateOnly(d) => DateTime(d.year, d.month, d.day)`; `dayBefore(d) => DateTime(d.year, d.month, d.day - 1)`; nunca `subtract(Duration)`.

### 5.1 EnergyCalculator

```dart
class EnergyCalculator {
  static const activityFactor = {
    ActivityLevel.sedentary: 1.2, ActivityLevel.light: 1.375,
    ActivityLevel.moderate: 1.55, ActivityLevel.veryActive: 1.725,
  };
  static const floorKcal = {Sex.female: 1200, Sex.male: 1500};
  static const maxDeficitRatio = 0.25;

  int ageYears(DateTime birth, DateTime today) {
    var age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
    return age;
  }

  double bmi(double weightKg, double heightCm) => weightKg / pow(heightCm / 100, 2);

  double bmr(Sex sex, int age, double weightKg, double heightCm) =>
      10 * weightKg + 6.25 * heightCm - 5 * age + (sex == Sex.male ? 5 : -161);

  double tdee(Sex sex, int age, double weightKg, double heightCm, ActivityLevel a) =>
      bmr(sex, age, weightKg, heightCm) * activityFactor[a]!;

  /// Meta con tope de déficit y piso. El piso gana sobre el tope.
  int targetKcal(double tdee, Sex sex, Goal goal) {
    final adjust = switch (goal) {
      Goal.lose => -min(500.0, tdee * maxDeficitRatio),
      Goal.maintain => 0.0,
      Goal.gain => 300.0,
    };
    return max((tdee + adjust).round(), floorKcal[sex]!);
  }
}
```

### 5.2 PlanGenerator

```dart
class ExclusionAnswers {
  const ExclusionAnswers({required this.pregnantOrLactating, required this.diabetes,
      required this.kidneyDisease, required this.liverOrHeartDisease, required this.bariatricSurgery,
      required this.eatingDisorder, required this.glucoseOrAppetiteMeds, required this.otherCondition});
  final bool pregnantOrLactating, diabetes, kidneyDisease, liverOrHeartDisease,
      bariatricSurgery, eatingDisorder, glucoseOrAppetiteMeds, otherCondition;
  bool get disqualifies => pregnantOrLactating || diabetes || kidneyDisease || liverOrHeartDisease ||
      bariatricSurgery || eatingDisorder || glucoseOrAppetiteMeds || otherCondition;
}

class GenerationResult {
  const GenerationResult(this.diet, {this.underweightWarning = false});
  final Diet diet;
  final bool underweightWarning;   // IMC < 18.5 con objetivo distinto de bajar (RF-5.3)
}

class PlanGenerator {
  PlanGenerator(this._templates, this._calc, this._subgroups);
  final List<DietTemplate> _templates;   // ordenadas por kcal nominal ascendente
  final EnergyCalculator _calc;
  final Map<SubgroupCode, Subgroup> _subgroups;

  static const maxTargetKcal = 3200;

  /// Se llama al abrir la pantalla Generar, antes de mostrar el cuestionario (RF-5.2).
  void checkAge(UserProfile p, DateTime today) {
    final age = _calc.ageYears(p.birthDate!, today);
    if (age < 18 || age >= 65) throw const PlanGenerationBlocked(BlockReason.age);
  }

  int realKcal(DietTemplate t) => NutritionTotals(_subgroups).forEquivalents(
      [for (final m in t.meals) ...m.equivalents]).kcal.round();

  /// Lanza PlanGenerationBlocked(reason). No verifica disponibilidad de alimentos:
  /// eso lo hace GeneratePlanUseCase con el repositorio (RF-5.7).
  GenerationResult generate(UserProfile p, ExclusionAnswers a, DateTime today) {
    checkAge(p, today);
    if (a.disqualifies) throw const PlanGenerationBlocked(BlockReason.questionnaire);

    final bmi = _calc.bmi(p.weightKg!, p.heightCm!);
    if (bmi < 18.5 && p.goal == Goal.lose) throw const PlanGenerationBlocked(BlockReason.underweightLose);
    if (bmi >= 40) throw const PlanGenerationBlocked(BlockReason.bmiOver40);

    final age = _calc.ageYears(p.birthDate!, today);
    final tdee = _calc.tdee(p.sex!, age, p.weightKg!, p.heightCm!, p.activity!);
    final floor = EnergyCalculator.floorKcal[p.sex!]!;
    if (p.goal == Goal.lose && floor >= tdee) throw const PlanGenerationBlocked(BlockReason.floorAboveTdee);

    final target = _calc.targetKcal(tdee, p.sex!, p.goal!);
    if (p.goal != Goal.lose && target > maxTargetKcal) throw const PlanGenerationBlocked(BlockReason.noTemplate);

    final lowerBound = max((floor * 0.95).round(), (tdee * (1 - EnergyCalculator.maxDeficitRatio)).round());
    final candidates = _templates.where((t) => realKcal(t) >= lowerBound).toList();
    if (candidates.isEmpty) throw const PlanGenerationBlocked(BlockReason.noTemplate);
    final preferLower = p.goal == Goal.lose;
    final t = candidates.reduce((lo, hi) {
      final dLo = (realKcal(lo) - target).abs(), dHi = (realKcal(hi) - target).abs();
      if (dHi < dLo) return hi;
      if (dHi > dLo) return lo;
      return preferLower ? lo : hi;        // empate: menor al bajar, mayor al mantener o subir
    });
    if (p.goal == Goal.lose && realKcal(t) >= tdee * 0.95) throw const PlanGenerationBlocked(BlockReason.noDeficit);

    final diet = Diet(id: newId(), name: 'Plan ${t.kcal} kcal', origin: DietOrigin.generated,
        targetKcal: realKcal(t), startDate: dateOnly(today), weeks: 4, updatedAt: today,
        meals: [for (final m in t.meals) m.copyWith(id: newId())]);
    return GenerationResult(diet, underweightWarning: bmi < 18.5);
  }
}
```

La lista va ascendente, así que en el `reduce` el acumulador `lo` es siempre la menor y `hi` la mayor. Los snippets de §5 asumen `import 'dart:math';` y los helpers `newId()` (`core/ids.dart`) y `dateOnly`/`dayBefore` (`core/dates.dart`). Se comparan kcal reales (1775 para la plantilla "1800") y no nominales para que el tope del 25 % y la existencia de déficit se evalúen sobre lo que el usuario realmente comerá. El piso se compara con tolerancia de 5 % (`floor * 0.95`), la misma con que se aceptan las plantillas; sin ella la de 1200 (1165 reales) nunca sería candidata. El tope de 3200 aplica solo a mantener y subir; al bajar, el límite inferior y `noDeficit` bastan. `noDeficit` salta cuando la plantilla deja menos de 5 % de déficit, porque eso es mantenimiento en la práctica. `targetKcal` guarda las kcal reales, base del umbral de exceso (RF-8.2). El reparto por tiempo viene en `DietTemplate.meals` desde `diet_templates.json`. `BlockReason` se declara una sola vez, en `errors.dart` (§12).

`GeneratePlanUseCase`: `precheck()` llama `checkAge` al abrir la pantalla; `run(answers)` llama `generate`, calcula las exclusiones efectivas (perfil + alérgenos), y para cada subgrupo de la dieta consulta `FoodRepository.countBySubgroup(s, excluding)`; si alguno es 0 lanza `PlanGenerationBlocked(BlockReason.noFoodForSubgroup, subgroup: s)` (RF-5.7). Devuelve el resultado para que la pantalla muestre el aviso legal; `confirm()` guarda, activa, registra `disclaimer_accepted_at` y llama `PlanController.onDietChanged()`.

### 5.3 DietCodec (formato compartido)

**Texto:** `NP1.` + base64url sin relleno de gzip(JSON). Límite: 800 caracteres.

**JSON compacto:**

```json
{"v":1,"n":"Plan 1800","k":1800,"s":"2026-10-06","w":4,
 "m":[{"t":"b","h":"08:00","e":[["cer_sg",2],["fru",1],["aoa_bg",1],["lec_d",1]]},
      {"t":"s1","e":[["fru",1],["gra_cp",1]]},
      {"t":"l","h":"14:00","e":[["ver",2],["cer_sg",3],["leg",1],["aoa_bg",3],["gra_sp",2]]},
      {"t":"s2","e":[["ver",1],["fru",1]]},
      {"t":"d","h":"20:00","e":[["ver",1],["cer_sg",3],["aoa_bg",2],["lec_d",1],["gra_sp",3]]}],
 "x":["aoa_bg_camaron","lec_d_leche_light"]}
```

Suma diaria igual a la plantilla de 1800 (1775 kcal). Su reparto (20/7/36/5/32 %) es el de un nutriólogo, distinto al de la plantilla; el codec acepta cualquier dieta.

```dart
import 'dart:convert';
import 'dart:io' show gzip;

class DietCodec {
  static const prefix = 'NP1.';
  static const maxChars = 800;

  String encode(Diet d) {
    final bytes = gzip.encode(utf8.encode(jsonEncode(_toCompact(d))));
    final out = prefix + base64Url.encode(bytes).replaceAll('=', '');
    if (out.length > maxChars) throw DietTooLarge(out.length);
    return out;
  }

  Diet decode(String text) {
    final t = text.trim();
    if (!t.startsWith(prefix)) throw const UnsupportedDietFormat();
    final Map<String, Object?> map;
    try {
      final bytes = base64Url.decode(base64Url.normalize(t.substring(prefix.length)));
      map = jsonDecode(utf8.decode(gzip.decode(bytes))) as Map<String, Object?>;
    } catch (_) { throw const MalformedDiet(); }
    if (map['v'] != 1) throw const UnsupportedDietFormat();
    return _fromCompact(map);   // origin = imported, isActive = false, id = newId()
  }
}
```

`_fromCompact` rechaza `amount` no múltiplo de 0.5, tiempos repetidos, un mismo subgrupo repetido dentro de un tiempo, códigos desconocidos y más de 6 tiempos (`MalformedDiet`). La clave `h` (hora) es opcional, igual que `MealSlot.time`; en el ejemplo las colaciones no la traen. `ImportDietUseCase` filtra `excludedFoodIds` con `FoodRepository.existingIds` (RF-4.7).

### 5.4 NutritionTotals

```dart
class Totals { const Totals({required this.kcal, required this.proteinG, required this.lipidG, required this.carbG});
  final double kcal, proteinG, lipidG, carbG; }

class NutritionTotals {
  NutritionTotals(this._subgroups);
  final Map<SubgroupCode, Subgroup> _subgroups;

  Totals forEquivalents(Iterable<PrescribedEquivalent> eqs) {
    var k = 0.0, p = 0.0, l = 0.0, c = 0.0;
    for (final e in eqs) {
      final s = _subgroups[e.subgroup]!;
      k += s.kcal * e.amount; p += s.proteinG * e.amount; l += s.lipidG * e.amount; c += s.carbG * e.amount;
    }
    return Totals(kcal: k, proteinG: p, lipidG: l, carbG: c);
  }

  Totals forDiet(Diet d) => forEquivalents([for (final m in d.meals) ...m.equivalents]);

  /// Porcentaje de energía por macronutriente con factores de Atwater 4/9/4.
  (double hc, double prot, double lip) macroPercent(Totals t) {
    final e = t.carbG * 4 + t.proteinG * 4 + t.lipidG * 9;
    if (e == 0) return (0, 0, 0);
    return (t.carbG * 4 / e * 100, t.proteinG * 4 / e * 100, t.lipidG * 9 / e * 100);
  }
}
```

### 5.5 DailyPlanMaterializer

```dart
class DailyPlanMaterializer {
  DailyPlanMaterializer(this._foods);
  final FoodRepository _foods;

  /// Determinista por (fecha, regenCount). [keep] son ítems ya consumidos que se conservan (RF-5.8).
  /// Si la prescripción cambió, la diferencia se agrega como ítems nuevos y los consumidos
  /// cuyo (tiempo, subgrupo) ya no existe se anexan al final para no perder el registro.
  Future<DailyPlan> materialize(Diet diet, DateTime date, Set<String> excluded,
      {int regenCount = 0, List<PlanItem> keep = const [], DateTime? now}) async {
    final d = dateOnly(date);
    final stamp = now ?? DateTime.now();
    final rng = Random(d.year * 10000 + d.month * 100 + d.day + regenCount * 1000003);
    final items = <PlanItem>[];
    final kept = <(MealType, SubgroupCode), List<PlanItem>>{};
    for (final k in keep) (kept[(k.meal, k.subgroup)] ??= []).add(k);

    for (final slot in diet.meals) {
      for (final eq in slot.equivalents) {
        final reuse = kept.remove((slot.type, eq.subgroup)) ?? const [];
        final keptAmount = reuse.fold(0.0, (s, i) => s + i.amount);
        items.addAll(reuse);
        final missing = eq.amount - keptAmount;
        if (missing <= 0) continue;                       // ya consumido igual o más
        final candidates = await _foods.bySubgroup(eq.subgroup, excluding: excluded); // ORDER BY id
        final food = candidates.isEmpty ? null : candidates[rng.nextInt(candidates.length)];
        items.add(PlanItem(id: newId(), meal: slot.type, subgroup: eq.subgroup,
            amount: missing, foodId: food?.id));
      }
    }
    for (final orphans in kept.values) items.addAll(orphans);   // consumidos sin equivalente actual
    return DailyPlan(dietId: diet.id, date: d, regenCount: regenCount, materializedAt: stamp, items: items);
  }
}
```

`excluded` = `profile.excludedFoodIds` ∪ alimentos cuyo `allergens` interseca `profile.excludedAllergens` ∪ `diet.excludedFoodIds`. Lo calcula `PlanController`. La invariante "amount del ítem = equivalente" se relaja a "la suma de los ítems de un (tiempo, subgrupo) = equivalente" cuando hay ítems conservados; `ComplianceService` suma por subgrupo, así que no le afecta. `now` se inyecta en pruebas para que `materializedAt` sea determinista. Cuando se guarda la dieta activa editada, `DietRepository.save` borra los `daily_plans` con fecha posterior a hoy para que se materialicen de nuevo con la prescripción actual; hoy y los días pasados se conservan. El plan de hoy sigue la prescripción anterior hasta que el usuario pulse regenerar (que conserva lo consumido, rehace el resto con la nueva y actualiza `materializedAt`); mientras tanto, el cumplimiento se calcula contra la prescripción nueva, así que `PlanController` expone `dietChanged = diet.updatedAt.isAfter(day.materializedAt)` y la pantalla muestra "tu dieta cambió, regenera el día" cuando es verdadero.

### 5.6 ComplianceService

```dart
class SubgroupCompliance {
  const SubgroupCompliance(this.subgroup, this.prescribed, this.consumed);
  final SubgroupCode subgroup; final double prescribed, consumed;
  double get ratio => prescribed == 0 ? 0 : min(consumed / prescribed, 1.0);
}

class DayCompliance {
  const DayCompliance(this.bySubgroup, this.excessEquivalents, this.excessKcal);
  final List<SubgroupCompliance> bySubgroup;          // solo subgrupos prescritos
  final Map<SubgroupCode, double> excessEquivalents;  // todos los subgrupos con exceso
  final double excessKcal;
  double get overall {
    final total = bySubgroup.fold(0.0, (s, c) => s + c.prescribed);
    if (total == 0) return 0;
    return bySubgroup.fold(0.0, (s, c) => s + min(c.consumed, c.prescribed)) / total;
  }
}

class ComplianceService {
  ComplianceService(this._subgroups);
  final Map<SubgroupCode, Subgroup> _subgroups;

  DayCompliance forDay(Diet diet, DailyPlan plan, List<ExtraConsumption> extras) {
    final prescribed = <SubgroupCode, double>{};
    for (final m in diet.meals) for (final e in m.equivalents) {
      prescribed.update(e.subgroup, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    final consumed = <SubgroupCode, double>{};
    for (final i in plan.items.where((i) => i.consumed)) {
      consumed.update(i.subgroup, (v) => v + i.amount, ifAbsent: () => i.amount);
    }
    for (final x in extras) consumed.update(x.subgroup, (v) => v + x.amount, ifAbsent: () => x.amount);

    final excess = <SubgroupCode, double>{};
    var excessKcal = 0.0;
    for (final e in consumed.entries) {
      final over = e.value - (prescribed[e.key] ?? 0);
      if (over > 0) { excess[e.key] = over; excessKcal += over * _subgroups[e.key]!.kcal; }
    }
    return DayCompliance(
      [for (final s in prescribed.keys) SubgroupCompliance(s, prescribed[s]!, consumed[s] ?? 0)],
      excess, excessKcal);
  }
}
```

Umbral de exceso para marcar el día: `max(150, 0.075 * diet.targetKcal)` kcal.

### 5.7 StreakService

```dart
class StreakService {
  static const maxLookbackDays = 366;

  int planStreak(Map<DateTime, double> byDay, DateTime upTo, {double threshold = 0.8}) {
    assert(threshold > 0);
    var streak = 0;
    var d = dateOnly(upTo);
    while (streak < maxLookbackDays && (byDay[d] ?? 0) >= threshold) { streak++; d = dayBefore(d); }
    return streak;
  }

  int habitStreak(Habit h, Set<DateTime> done, DateTime upTo) {
    if (h.weekdays.isEmpty) return 0;
    var streak = 0;
    var d = dateOnly(upTo);
    final floor = dateOnly(h.createdAt);
    var guard = 0;
    while (!d.isBefore(floor) && guard++ < maxLookbackDays) {
      if (h.weekdays.contains(d.weekday)) {
        if (!done.contains(d)) break;
        streak++;
      }
      d = dayBefore(d);
    }
    return streak;
  }
}
```

Hoy sin marcar no rompe la racha de ayer: la pantalla llama con `upTo = hoy` si hoy está cumplido y con `upTo = ayer` si no, mostrando "hoy pendiente".

### 5.8 ShoppingListBuilder

Agrupa `PlanItem` con `foodId != null` de los 7 días por `foodId`, suma `amount × food.quantity`, emite un `ShoppingItem` por alimento. Al regenerar conserva filas `manual = 1` y el `checked` de las filas cuyo `foodId` sigue presente.

### 5.9 SubgroupMatcher (C)

Normaliza macros a 100 kcal, distancia euclidiana contra cada subgrupo sobre (proteína, lípidos, carbohidratos), devuelve los 3 más cercanos excluyendo `lib`.

## 6. Repositorios

```dart
abstract class FoodRepository {
  Future<List<Food>> search(String query, {SubgroupCode? subgroup});
  Future<List<Food>> bySubgroup(SubgroupCode s, {Set<String> excluding = const {}});  // ORDER BY id
  Future<int> countBySubgroup(SubgroupCode s, {Set<String> excluding = const {}});
  Future<Set<String>> idsWithAllergens(Set<Allergen> a);
  Future<Food?> byId(String id);
  Future<Set<String>> existingIds(Iterable<String> ids);
  Future<void> upsertCustom(Food f);
  Future<Map<SubgroupCode, Subgroup>> subgroups();
}

abstract class DietRepository {
  Future<Diet?> active();
  Future<List<Diet>> all({DietOrigin? origin});
  Future<void> save(Diet d);                // update, luego insert si 0 filas; hijos borrar+insertar; si es la activa, borra daily_plans futuros
  Future<void> activate(String dietId);
  Future<void> delete(String dietId);
}

abstract class PlanRepository {
  Future<DailyPlan?> forDate(String dietId, DateTime date);
  Future<void> save(DailyPlan p);           // update/insert de daily_plans (incluye materialized_at); reemplaza ítems del día; extras no se tocan
  Future<void> swapFood(String planItemId, String newFoodId);
  Future<void> setConsumed(String planItemId, bool consumed, DateTime at);
  Future<void> addExtra(ExtraConsumption x);
  Future<List<ExtraConsumption>> extrasFor(DateTime date);
  Future<Map<DateTime, DailyPlan>> forWeek(String dietId, DateTime monday);
}

abstract class HabitRepository {
  Future<List<Habit>> all();
  Future<void> save(Habit h);
  Future<void> delete(String id);
  Future<void> toggleDone(String habitId, DateTime date);
  Future<Set<DateTime>> doneDates(String habitId);
  Future<int> water(DateTime date);
  Future<void> addWater(DateTime date, int delta);
}

abstract class ProfileRepository {
  Future<UserProfile?> load();              // null antes del onboarding
  Future<void> save(UserProfile p);         // tabla profile fila 1 + user_exclusions
  Future<void> markDisclaimerAccepted(DateTime at);
  Future<void> logWeight(DateTime date, double kg);
  Future<List<(DateTime, double)>> weightHistory();
}
```

## 7. Controladores (ChangeNotifier)

```dart
class PlanController extends ChangeNotifier {
  PlanController(this._diets, this._plans, this._foods, this._profile, this._materializer, this._compliance,
      {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;
  // repositorios y servicios finales
  final DateTime Function() _clock;          // inyectable en pruebas para materializedAt y consumedAt

  Diet? diet; DailyPlan? day; DayCompliance? compliance;
  bool loading = false;
  Object? error;                                        // último fallo; la UI lo muestra y ofrece reintentar
  DateTime _requestedDate = dateOnly(DateTime.now());   // último día que la UI pidió ver
  Completer<void>? _done;                               // se completa cuando no queda nada pendiente
  (DateTime, bool)? _pending;

  bool get dietChanged =>
      diet != null && day != null && diet!.updatedAt.isAfter(day!.materializedAt);

  /// Carga un día. Si hay una carga en curso, la petición queda pendiente y se ejecuta
  /// al terminar con la ÚLTIMA fecha pedida. El Future devuelto se completa (nunca con error)
  /// cuando la cadena entera terminó; los fallos quedan en [error] y se notifican.
  Future<void> loadDay(DateTime date, {bool showLoading = true}) {
    _requestedDate = dateOnly(date);
    if (_done != null) { _pending = (_requestedDate, showLoading); return _done!.future; }
    final done = _done = Completer<void>();
    _drain(_requestedDate, showLoading).whenComplete(done.complete);
    return done.future;
  }

  Future<void> _drain(DateTime date, bool showLoading) async {
    try {
      var next = (date, showLoading);
      while (true) {
        await _load(next.$1, next.$2);
        final p = _pending;
        if (p == null) break;
        _pending = null; next = p;
      }
    } finally { _pending = null; _done = null; }
  }

  Future<void> _refresh() => loadDay(_requestedDate, showLoading: false);

  Future<void> _load(DateTime date, bool showLoading) async {
    if (showLoading) { loading = true; notifyListeners(); }
    try {
      error = null;
      diet = await _diets.active();
      if (diet == null) { day = null; compliance = null; return; }
      var plan = await _plans.forDate(diet!.id, date);
      if (plan == null) {
        plan = await _materializer.materialize(diet!, date, await _excluded(), now: _clock());
        await _plans.save(plan);
      }
      day = plan;
      compliance = _compliance.forDay(diet!, plan, await _plans.extrasFor(date));
    } catch (e) {
      error = e;                       // nunca se propaga: la UI muestra el error y un botón reintentar
    } finally {
      loading = false; notifyListeners();
    }
  }

  /// Toda acción de escritura pasa por aquí: un fallo queda en [error] y se notifica,
  /// nunca se propaga, así la UI puede llamarlas sin `await`.
  Future<void> _act(Future<void> Function() body) async {
    try { await body(); } catch (e) { error = e; notifyListeners(); return; }
    await _refresh();
  }

  Future<void> toggleConsumed(PlanItem item) =>
      _act(() => _plans.setConsumed(item.id, !item.consumed, _clock()));

  Future<void> swap(PlanItem item, Food f) => _act(() => _plans.swapFood(item.id, f.id));

  /// Regenera solo los ítems no consumidos del día en pantalla (RF-5.8).
  Future<void> regenerate() => _act(() async {
    final current = day!;
    final keep = current.items.where((i) => i.consumed).toList();
    final plan = await _materializer.materialize(diet!, current.date, await _excluded(),
        regenCount: current.regenCount + 1, keep: keep, now: _clock());
    await _plans.save(plan);
  });

  /// Llamado por ImportDietUseCase.confirm y GeneratePlanUseCase.confirm.
  Future<void> onDietChanged() => loadDay(dateOnly(_clock()));

  Future<Set<String>> _excluded() async {
    final p = (await _profile.load())!;
    return {...p.excludedFoodIds, ...await _foods.idsWithAllergens(p.excludedAllergens), ...?diet?.excludedFoodIds};
  }
}
```

Una petición que llega durante una carga no se descarta ni se une: queda pendiente y se ejecuta al terminar, con la última fecha pedida; el `Completer` se resuelve solo cuando la cadena terminó, así `await controller.swap(...)` en una prueba ve el estado final. Las acciones refrescan con `_requestedDate` (el día que la UI pidió ver) y no con `day!.date`, para que un intercambio hecho sobre el día A mientras carga el día B no regrese la pantalla a A. Los fallos de `_load` y de las acciones (`_act`) nunca se propagan como excepción: quedan en `error`, `loading` vuelve a `false` en el `finally` (el indicador no se queda girando) y la UI muestra el mensaje con un botón de reintentar; así una llamada sin `await` (carga inicial, `onDietChanged`, un `onTap`) no produce un error asíncrono sin manejar. Si varias peticiones pendientes traen distinto `showLoading`, gana la última; es inocuo. Las pantallas envuelven lo dependiente en `ListenableBuilder(listenable: controller, builder: ...)`. Los controladores se crean en `main.dart` (tras `WidgetsFlutterBinding.ensureInitialized()`, necesario porque se abre la base y se leen assets antes de `runApp`), viven toda la app y se pasan por constructor a `RootScreen` y de ahí a cada pestaña. `ImportDietUseCase` y `GeneratePlanUseCase` no son controladores: son casos de uso sin estado que reciben los repositorios y el `PlanController` para notificarle al confirmar.

## 8. Navegación

`RootScreen` tiene `int _index` y una `NavigationBar` con `NavigationDestination` por pestaña; el `body` es la pantalla de la pestaña activa. Las pantallas apiladas se abren con `Navigator.push(context, MaterialPageRoute(builder: ...))`.

| Pestañas rol usuario | Pestañas rol nutriólogo |
|---|---|
| Inicio, Plan, Hábitos, Progreso, Perfil | Dietas, Catálogo, Perfil |

Apiladas: Semana (desde Plan), Lista de compras (desde Semana), Importar (desde Plan o Perfil), Generar plan (desde Plan cuando no hay dieta), Editor de dieta (desde Dietas; lista solo `origin = nutritionist`), Compartir (desde Editor), Escáner (desde Catálogo), Notificaciones y Aviso legal (desde Perfil), Onboarding (raíz cuando `ProfileRepository.load()` es null). El intercambio es un `showModalBottomSheet`.

## 9. Pantallas

| Pantalla | Widgets | Controlador o caso de uso | Acciones |
|---|---|---|---|
| Inicio | Stack (fondo + Cards); `GridView` de 4 columnas con `CircularProgressIndicator` por subgrupo y % encima; contador de agua; ListView de hábitos de hoy | Plan, Habit | +1 vaso, marcar hábito |
| Plan del día | ListView por tiempo; ListTile por alimento con `Checkbox`; ítem sin alimento con botón elegir; botón regenerar; aviso "tu dieta cambió" cuando `dietChanged`; mensaje de `error` con reintentar | Plan | consumido, intercambiar, regenerar (registro fuera del plan es C) |
| Intercambio | `showModalBottomSheet` con GridView | Plan | elegir |
| Semana | Row de 7 Containers con altura por cumplimiento | Plan | abrir día, compras |
| Editor de dieta | Form por tiempo; botones +/− de 0.5 por subgrupo; barra de totales; advertencia si un subgrupo va fuera de la matriz | DietEditor | guardar, plantilla, exclusiones, compartir |
| Compartir | `QrImageView(errorCorrectionLevel: QrErrorCorrectLevel.M)`; `SelectableText`; Copiar (`Clipboard`), Compartir (`share_plus`) | DietEditor | copiar, compartir |
| Importar | `TextField` multilínea; botón Escanear (abre `MobileScanner`; su `errorBuilder` explica cuando no hay cámara y remite al texto); resumen con totales; Confirmar | Import, Plan | pegar, escanear, confirmar |
| Generar plan | Páginas: cuestionario (`Switch`), resultado o bloqueo por `BlockReason`, aviso de bajo peso si aplica, aviso legal con `Checkbox` | GeneratePlan, Plan | generar, aceptar |
| Hábitos | ListView + ListTile con racha; `FloatingActionButton` | Habit | CRUD, marcar |
| Progreso | Row de Containers semanal; exceso del día; lista de pesos | Plan, Profile | registrar peso (compartir logro es C) |
| Compras | ListView agrupado con `Checkbox` | Plan | marcar, agregar, regenerar |
| Escáner (C) | `MobileScanner` con `errorBuilder`; `TextField` de código siempre visible; tarjeta; `DropdownButton` de subgrupo | — | guardar alimento |
| Perfil | Form; `Switch` tema; meta de agua; exclusiones (alérgenos con `Checkbox` + búsqueda); rol; notificaciones; aviso legal | Profile | guardar |
| Onboarding | Páginas con Navigator; rol; Form de perfil (reutilizado al cambiar de rol) | Profile | continuar |

Todo control interactivo lleva `Semantics(label:)` o `tooltip` (RNF-8).

## 10. Notificaciones (C)

| Recordatorio | Programación | ID |
|---|---|---|
| Agua | Hasta 12 `zonedSchedule` diarios a horas fijas, `matchDateTimeComponents: DateTimeComponents.time` | 1000 + índice |
| Comida | Un `zonedSchedule` diario por `MealSlot.time` definido | 2000 + sortOrder |

Al cambiar ajustes se cancela el rango correspondiente (`cancel` por cada ID) y se reprograma. Máximo 18 pendientes. Android: `androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle`. iOS: `requestPermissions(alert: true, badge: true, sound: true)`. Al arrancar, `getNotificationAppLaunchDetails()` lee el payload y `RootScreen` cambia a la pestaña indicada.

```dart
import 'package:timezone/data/latest_all.dart' as tz;   // latest_all: incluye alias que Android puede devolver
import 'package:timezone/timezone.dart' as tz;
tz.initializeTimeZones();
final info = await FlutterTimezone.getLocalTimezone();  // TimezoneInfo en v5+
tz.setLocalLocation(tz.getLocation(info.identifier));
```

**Configuración nativa.** iOS `Info.plist`: `NSCameraUsageDescription`. `AppDelegate`: `UNUserNotificationCenter.current().delegate = self`. Android: `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `CAMERA`, `INTERNET`; receivers `ScheduledNotificationReceiver` y `ScheduledNotificationBootReceiver`; `coreLibraryDesugaringEnabled true` con `coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'` (versión a confirmar).

## 11. Carga del catálogo

`CatalogLoader.seed(db)` corre dentro de `onCreate`, que ya es una transacción, así que usa `Batch`:

```dart
static Future<void> seed(DatabaseExecutor db) async {
  final b = db.batch();
  for (final s in await _readJson('assets/data/subgroups.json')) b.insert('subgroups', s);
  for (final f in await _readJson('assets/data/food_catalog.json')) b.insert('foods', _foodRow(f));
  await b.commit(noResult: true);
}
```

`diet_templates.json` se lee en memoria al arrancar. Validaciones (subgrupo existe, USDA ±25 %, alérgenos válidos, plantillas ±5 % y 21-24 % proteína, repartos íntegros) corren en `catalog_test.dart`.

Esquema de `diet_templates.json`:

```json
[{"kcal":1200,"meals":[
   {"t":"b","h":"08:00","e":[["cer_sg",1],["aoa_bg",1],["lec_d",1],["gra_sp",1]]},
   {"t":"s1","h":"11:00","e":[["fru",1]]},
   {"t":"l","h":"14:00","e":[["ver",2],["cer_sg",2],["leg",1],["aoa_bg",2],["gra_sp",1]]},
   {"t":"s2","h":"17:00","e":[["fru",1],["ver",1]]},
   {"t":"d","h":"20:00","e":[["ver",1],["cer_sg",1],["aoa_bg",1],["lec_d",1],["gra_sp",1]]}]}]
```

Las horas predeterminadas permiten programar recordatorios de comida (C) en planes generados; el usuario puede cambiarlas desde el plan.

Esquema de `food_catalog.json`:

```json
[{"id":"cer_sg_tortilla_maiz","subgroup":"cer_sg","name":"Tortilla de maíz",
  "quantity":1,"unit":"pieza","grams":30,"kcal":70,"protein_g":2,"lipid_g":0,"carb_g":15,
  "source":"smae_avg","allergens":[]}]
```

## 12. Manejo de errores

```dart
sealed class NutriPlanError implements Exception { const NutriPlanError(); }
class UnsupportedDietFormat extends NutriPlanError { const UnsupportedDietFormat(); }
class MalformedDiet extends NutriPlanError { const MalformedDiet(); }
class MalformedData extends NutriPlanError { const MalformedData(this.what); final String what; }
class DietTooLarge extends NutriPlanError { const DietTooLarge(this.chars); final int chars; }
enum BlockReason { age, questionnaire, underweightLose, bmiOver40, floorAboveTdee, noTemplate, noDeficit, noFoodForSubgroup }
class PlanGenerationBlocked extends NutriPlanError {
  const PlanGenerationBlocked(this.reason, {this.subgroup}); final BlockReason reason; final SubgroupCode? subgroup; }
class OffUnavailable extends NutriPlanError { const OffUnavailable(); }
class ProductNotFound extends NutriPlanError { const ProductNotFound(); }
```

| Situación | Error | Comportamiento |
|---|---|---|
| Texto sin prefijo o versión ≠ 1 | `UnsupportedDietFormat` | SnackBar; nada cambia |
| Texto corrupto | `MalformedDiet` | SnackBar |
| Dieta excede 800 caracteres | `DietTooLarge` | Editor muestra tamaño; Compartir deshabilitado |
| Filtro del generador | `PlanGenerationBlocked(reason)` | Pantalla con mensaje por `reason` (y subgrupo si aplica); `noDeficit` sugiere cambiar el objetivo a mantener |
| Subgrupo sin alimentos en dieta importada | `foodId == null` | Ítem "sin alimento disponible" con botón elegir |
| OFF sin red o producto inexistente | `OffUnavailable` / `ProductNotFound` | "Capturar a mano" |
| Cámara falla o no existe | `MobileScanner.errorBuilder` | Texto explicativo; ruta por texto siempre visible |
| Notificaciones denegadas | — | Interruptores apagados con motivo |

## 13. Plan de pruebas

### 13.1 Unitarias de dominio (`flutter test test/domain`; 80 % en 5.1, 5.2, 5.3, 5.6)

| Archivo | Casos |
|---|---|
| `energy_calculator_test` | Edad con cumpleaños antes y después de hoy; BMR hombre y mujer; cada factor; déficit recortado a 25 %; piso gana sobre tope (GET 1400 → 1200); IMC |
| `plan_generator_test` | `checkAge` con 17 y 65 bloquea; cada pregunta bloquea; IMC 18.0 con bajar bloquea, con mantener devuelve `underweightWarning`; IMC 40 bloquea; mujer GET 1150 bajar → `floorAboveTdee`; mujer GET 1330 bajar → 1200 (1165 real); mujer GET 1350 mantener → 1500 (empate hacia la mayor); mujer GET 1800 bajar → 1500; mujer GET 2400 bajar → 2000; hombre GET 1520 bajar → `noDeficit`; hombre GET 1600 bajar → `noDeficit`; hombre GET 1700 bajar → 1500; mujer GET 1210 bajar → `noDeficit`; mujer GET 1580 bajar → `noDeficit`; mujer GET 1650 bajar → 1500; hombre GET 2500 mantener → 2600; hombre GET 3800 bajar → 3000; hombre GET 3300 mantener → `noTemplate`; hombre GET 4100 bajar → `noTemplate` (sin candidatas); cada una de las 7 plantillas es alcanzable por algún perfil válido; la dieta devuelta copia el reparto con ids nuevos, `targetKcal` = kcal reales y `updatedAt` = hoy |
| `materializer_test` | Misma fecha y regenCount → misma propuesta; regenCount distinto puede cambiar; exclusiones respetadas; subgrupo vacío → foodId nulo; `keep` conserva consumidos en su tiempo y subgrupo; equivalente mayor que lo consumido agrega ítem por la diferencia; consumido huérfano se anexa; `materializedAt` toma el `now` inyectado |
| `diet_codec_test` | Ida y vuelta mínima y de una dieta máxima realista (6 tiempos, 10 subgrupos por tiempo, 20 exclusiones) bajo 800; una dieta de 6 tiempos × 18 subgrupos × 60 exclusiones lanza `DietTooLarge`; prefijo inválido; `v: 2`; truncado; subgrupo repetido en un tiempo → `MalformedDiet`; espacios tolerados; `h` ausente aceptado; `origin == imported` |
| `nutrition_totals_test` | 1800 = 1775 kcal; las 7 plantillas dentro de ±5 % y 51-55 / 21-24; `macroPercent` de totales en cero devuelve ceros |
| `templates_test` | Para cada plantilla: suma de repartos = totales declarados; solo enteros; 5 tiempos no vacíos; cada tiempo dentro de ±10 puntos de 25/10/35/10/20; matriz respetada; cada colación tiene FRU o LEC_D; la comida tiene LEG; cada tiempo tiene hora |
| `compliance_service_test` | Sin consumo 0; todo 1; doble → overall 1 y exceso; extra no prescrito en exceso con kcal; prescrito 0 ignorado |
| `streak_service_test` | Umbral; fin de semana no rompe; weekdays vacío → 0; se detiene en createdAt; ≤ 366; cruce de horario de verano |
| `shopping_list_builder_test` | Suma por alimento; ignora sin alimento; conserva manuales y checked |
| `catalog_test` | Subgrupo existe; USDA ±25 %; alérgenos válidos; ≥ 120 alimentos; cada subgrupo de plantillas con ≥ 3 alimentos sin alérgenos comunes |
| `architecture_test` | `lib/domain` sin imports prohibidos |

### 13.2 Datos (`sqflite_common_ffi`)

```dart
TestWidgetsFlutterBinding.ensureInitialized();   // la semilla lee assets con rootBundle
setUpAll(sqfliteFfiInit);
setUp(() async => db = await openAppDatabase(
    factory: databaseFactoryFfi, path: inMemoryDatabasePath, singleInstance: false));
tearDown(() => db.close());
```

Se usa `test()`, no `testWidgets()`: el `FakeAsync` de `testWidgets` se cuelga con las llamadas nativas de ffi. `singleInstance: false` da una base limpia por caso.

- `activate` deja una sola activa; dos activas violan el índice.
- `save` dos veces la misma dieta no borra `daily_plans` ni `plan_items` de hoy ni de días pasados; sí borra los futuros cuando la dieta es la activa y actualiza `updated_at`.
- `PlanRepository.save` sobre un día existente actualiza `materialized_at` y `regen_count`.
- `swapFood` rechaza otro subgrupo.
- Borrar dieta cascada a tiempos, equivalentes, exclusiones, planes e ítems.
- Borrar alimento personalizado en uso deja `food_id` NULL.
- `existingIds`, `countBySubgroup`, `idsWithAllergens`.
- Semilla: 18 subgrupos, ≥ 120 alimentos.

### 13.3 Widgets (repositorios en memoria)

- Inicio muestra un anillo por subgrupo prescrito.
- Plan: `Checkbox` llama `setConsumed`; regenerar conserva consumidos; `await controller.swap(...)` disparado mientras la carga inicial está en curso termina con el alimento nuevo en `day` (el `Completer` espera la cadena); un `swap` sobre el día A mientras carga el día B deja la pantalla en B; tras editar la dieta activa aparece el aviso "tu dieta cambió" y desaparece al regenerar; si el repositorio lanza, `loading` queda en false, `error` se muestra con botón reintentar y `loadDay` no lanza.
- Importar: inválido → SnackBar sin `save`; válido → resumen y Confirmar guarda y el Plan se recarga.
- Generar: perfil con 17 años bloquea al abrir la pantalla, antes del cuestionario (`precheck`); `Switch` afirmativo bloquea tras el cuestionario.

### 13.4 Manual en dispositivo

| # | Caso | Dónde |
|---|---|---|
| 1 | Nutriólogo crea dieta 1800, copia texto; cambia rol a usuario (formulario de perfil aparece); importa pegando; confirma | Simulador |
| 2 | Usuario sin nutriólogo: perfil, cuestionario, plan, aviso, ver día | Simulador |
| 3 | Intercambiar alimento; anillo no cambia hasta marcar consumido; regenerar conserva consumidos | Simulador |
| 4 | Modo avión: 1 a 3 funcionan | iPhone físico |
| 5 | QR por cámara desde la pantalla de otro dispositivo | iPhone físico |
| 6 | (C) Notificación de agua dentro de 15 minutos | iPhone físico |

## 14. Reparto de trabajo y calendario

2 días-persona por semana por integrante. M (28 dp construcción + 4 dp pruebas) cierra en la semana 8; S (8 dp) en semanas 9 y 10; semanas 11 y 12 para cierre. C solo si los M cierran antes. La semana 3 del Autor A es la más cargada; si se atrasa, `GeneratePlanUseCase` pasa a la semana 4 y el Autor B prueba el cuestionario contra un `PlanGenerator` con repositorio en memoria.

| Semana | Autor A (dominio y datos) | Autor B (presentación) | Hito |
|---|---|---|---|
| 1 | Proyecto, capas, `openAppDatabase` con FK y factory, esquema v1, `Info.plist`; lista de paquetes al profesor | Tema, `RootScreen`, onboarding con rol y perfil completo | Paquetes confirmados |
| 2 | `subgroups.json`, 60 alimentos, `CatalogLoader` con Batch, `FoodRepository` | Perfil con exclusiones y cambio de rol; búsqueda | |
| 3 | `EnergyCalculator`, `NutritionTotals`, `PlanGenerator`, `GeneratePlanUseCase` (con repositorio en memoria), `diet_templates.json`, `templates_test` | Cuestionario, bloqueos por `BlockReason`, aviso legal, contra el caso de uso real | |
| 4 | `DietRepository` (update/insert, borrado de futuros), `PlanRepository`, `Materializer` con `keep` | Plan del día, intercambio, sin alimento, regenerar | |
| 5 | `DietCodec`, `ImportDietUseCase` | Editor con totales y advertencia de matriz | |
| 6 | `ComplianceService`; 60 alimentos más | Compartir, Importar, Inicio con anillos en GridView | Revisión de avance: recortar S si hace falta |
| 7 | `HabitRepository`, agua; pruebas de datos | Hábitos, agua, semana; pruebas de widgets | |
| 8 | Pruebas de dominio al 80 %; corrección | Corrección; manual 1-3 | **Todos los M listos** |
| 9 | `StreakService`, `ShoppingListBuilder`, historial de peso y dietas | Rachas, exceso, resumen semanal, compras | |
| 10 | Plantillas en editor, exclusiones de dieta | Escaneo de QR con cámara; pulido | S listos |
| 11 | Corrección; manual 4-5 en iPhone | Corrección; accesibilidad | |
| 12 | Documentación de entrega | Guion de demo, video | Entrega |

## 15. Trazabilidad (requerimientos M)

| RF | Componente HLD | Clases y archivos | Pruebas |
|---|---|---|---|
| RF-1.1 | Perfil | `onboarding/`, `ProfileController` | widget onboarding |
| RF-1.2 | Perfil | `UserProfile` con `weightKg`, tabla `profile` | widget onboarding, datos |
| RF-1.3 | Perfil | `UserProfile.licenseNumber` | widget onboarding |
| RF-1.4 | Perfil | `profile/`, `UserProfile.completeForUser`, reutilización del Form | widget perfil, manual 1 |
| RF-1.6 | Perfil | `profile.water_goal` | widget perfil |
| RF-1.7 | Perfil | `user_exclusions`, `profile.excluded_allergens`, `idsWithAllergens` | materializer_test, datos |
| RF-2.1 | Catálogo | `food_catalog.json`, `Food.allergens`, `CatalogLoader` | catalog_test |
| RF-2.2 | Catálogo | `subgroups.json`, `Subgroup` | catalog_test |
| RF-2.3 | Catálogo | `FoodRepository.search`, índice | datos |
| RF-3.1 | Editor | `Diet`, `DietEditorController` | widget editor |
| RF-3.2 | Editor | `MealSlot`, `MealType` | widget editor |
| RF-3.3 | Editor | `PrescribedEquivalent` | entidad |
| RF-3.4 | Editor | `NutritionTotals` | nutrition_totals_test |
| RF-3.7 | Editor | `DietRepository.all(origin: nutritionist)`, `patientLabel` | datos |
| RF-4.1 | Compartir | `DietCodec.encode`, `QrImageView` nivel M | diet_codec_test |
| RF-4.2 | Compartir | `Clipboard`, `share_plus` | manual 1 |
| RF-4.3 | Importar | `ImportDietUseCase`, `TextField` | widget importar |
| RF-4.5 | Importar | `ImportDietUseCase` + `NutritionTotals` | widget importar |
| RF-4.6 | Importar | `DietCodec.decode`, errores | diet_codec_test, widget |
| RF-4.7 | Importar | `FoodRepository.existingIds` | datos |
| RF-5.1 | Generador | `ExclusionAnswers` | plan_generator_test |
| RF-5.2 | Generador | `PlanGenerator.checkAge`, `GeneratePlanUseCase.precheck`, `BlockReason.age`, `questionnaire` | plan_generator_test, widget generar |
| RF-5.3 | Generador | `bmi`, `underweightLose`, `bmiOver40`, `underweightWarning` | plan_generator_test |
| RF-5.4 | Generador | `tdee`, `targetKcal` con `maxDeficitRatio` | energy_calculator_test |
| RF-5.5 | Generador | `floorKcal`, `floorAboveTdee` | energy_calculator_test, plan_generator_test |
| RF-5.6 | Generador | candidatas por `realKcal` ≥ máx(0.95 piso, 0.75 GET), empate por objetivo, `noTemplate` (sin candidatas o mantener/subir > 3200), `noDeficit` (< 5 %), `DietTemplate.meals` | plan_generator_test, templates_test |
| RF-5.7 | Generador | `GeneratePlanUseCase`, `countBySubgroup`, `noFoodForSubgroup` | datos, widget generar |
| RF-5.8 | Plan del día | `Materializer` con `excluded`, `regenCount`, `keep` | materializer_test |
| RF-5.9 | Generador | aviso legal, `markDisclaimerAccepted` | widget generar |
| RF-6.1 | Plan del día | `PlanController.loadDay` | widget plan |
| RF-6.2 | Plan del día | `forWeek`, Semana | widget semana |
| RF-6.3 | Plan del día | `bySubgroup(excluding)`, bottom sheet | widget intercambio |
| RF-6.4 | Plan del día | `swapFood` | datos |
| RF-6.5 | Plan del día | `setConsumed` | widget plan |
| RF-6.7 | Plan del día | `PlanItem.foodId` nulo | materializer_test |
| RF-7.1 | Hábitos | `addWater/water` | widget inicio |
| RF-7.2 | Hábitos | `Habit`, `save/delete` | entidad, datos |
| RF-7.3 | Hábitos | `toggleDone` | widget hábitos |
| RF-8.1 | Cumplimiento | `ComplianceService.forDay`, GridView de anillos | compliance_service_test, widget inicio |
| RNF-2 | Todos | — | manual 4 |
| RNF-4 | Datos | `openAppDatabase` con `version` y `onUpgrade` | datos |
| RNF-7 | Generador | aviso por generación | widget generar |
| RNF-10 | Dominio | 5.1, 5.2, 5.3, 5.6 | lcov |
| RNF-11 | Catálogo | campo `source` | catalog_test |
| RNF-12 | Todos | 9 paquetes en 02 §4 | revisión del profesor |

Los S y C se trazan al iniciar su semana.
