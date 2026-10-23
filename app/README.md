# NutriPlan (patient app)

Flutter patient app for an equivalents-based meal plan: 5 tabs (Semana, Hoy, Cambiar, Movimiento, Progreso) on in-memory, clearly fictional mock data. Light theme, iOS first. Zero runtime packages beyond `flutter` and `cupertino_icons`.

## Architecture

```
lib/
  core/         i18n (only file with visible copy), es-MX formatters, flags, clock, scenario
  theme/        primitives (only hex colors) -> tokens (ThemeExtension) -> theme, accent
  domain/       pure Dart: models with validation, services (computeFit, budget, adherence...), repository interfaces
  data/         in-memory repositories + seed (relative to the injected clock)
  application/  ChangeNotifier controllers (plan, activity, progress, profile, shell, toast)
  ui/           components (primitives, actions, data_display, domain), shell, screens
```

State is `ChangeNotifier` + `ListenableBuilder`; navigation is one `AppShell` with an `IndexedStack`. Controller actions never throw: failures revert optimistic updates and set `error`; the UI shows generic copy only.

## Token flow

primitive (`theme/primitives.dart`) -> semantic (`theme/tokens.dart`, `AppTokens` via `context.tokens`) -> component. Components read semantic tokens only; `test/architecture_test.dart` fails on raw colors, font sizes, numeric paddings/radii/sizes in `lib/ui`, Spanish copy outside `core/i18n/strings_es_mx.dart`, Flutter imports in the domain, and logging calls.

The accent is runtime themeable: set `AccentController.value`; the text accent is re-derived (24% darker, then darker until contrast >= 4.5:1).

### Add a token
Add the raw value to `Prim` (colors only), expose a semantic name in `tokens.dart` (and `copyWith`/`lerp` for colors), use it through `context.tokens`.

### Add a component
One public widget per `snake_case.dart` file under `ui/components/<layer>/`, built only from lower layers (primitives -> actions -> data_display -> domain), tokens for every value, strings from `S`. Interactive parts use `Pressable` (44x44 hit area, focus ring, semantics).

## Run

```
cd app
flutter run                                   # normal scenario
flutter run --dart-define=MOCK_SCENARIO=noPlan  # nutritionist has not published a plan
flutter run --dart-define=MOCK_SCENARIO=error   # first load fails, Reintentar recovers
flutter analyze
flutter test                                  # add --coverage for lcov
```

Unknown `MOCK_SCENARIO` values fall back to `normal`.

## Security notes

Data stays in memory (nothing written to disk, no network, no analytics). No health data in logs (enforced by test and `avoid_print`). Error UI never shows exception text. `android:allowBackup="false"`; INTERNET only in debug/profile manifests. Domain constructors reject invalid input with typed errors. Future work: app-switcher blur, real auth, encrypted storage.

## Deviations from LLD

Status of every module in `docs/04-lld.md` section 2 against this app.

| LLD module | Status | Notes |
|---|---|---|
| `assets/data/` (subgroups, food_catalog, diet_templates JSON) | different | No SMAE catalog; mock data seeded in code (`data/mock/seed.dart`); only fonts under `assets/` |
| `ios/Runner/Info.plist` (NSCameraUsageDescription) | different | No camera/scanner; Info.plist carries name, locale and orientation keys |
| `android/app/src/main/AndroidManifest.xml` | done | Present; backup disabled, INTERNET only in debug/profile |
| `lib/main.dart` | different | Calls `bootstrap.dart`; no DB, in-memory repositories |
| `lib/my_app.dart` | different | `lib/app.dart` (`NutriPlanApp`), light theme only, no onboarding |
| `core/strings.dart` | different | `core/i18n/strings_es_mx.dart` |
| `core/dates.dart` | different | `core/clock.dart` (clock and `dateOnly`) plus `core/format/` |
| `core/ids.dart` | not started | No id generation needed with mock data |
| `core/icons.dart` | not started | Habits are not implemented |
| `domain/entities/` | different | `domain/models/` (Plan, DayPlan, Meal, EquivalentOption, Fit) |
| `domain/repositories/` | done | Abstract interfaces for plan, activity, measurement, patient |
| `domain/services/` | different | Fit, portion budget, adherence, progress (patient-app logic, not diet generation) |
| `domain/errors.dart` | done | Typed domain errors |
| `data/db/` (app_database, schema) | not started | No sqflite; in-memory only |
| `data/repositories/` | different | `data/in_memory_*_repository.dart` |
| `data/seed/catalog_loader.dart` | different | `data/mock/seed.dart` |
| `data/remote/off_client.dart` | not started | No network |
| `data/notifications/notification_service.dart` | not started |  |
| `data/prefs/settings_store.dart` | not started |  |
| `application/plan_controller.dart` | done | Optimistic writes, serialized saves, load generation guard |
| `application/habit_controller.dart` | not started | Replaced by `activity_controller.dart` |
| `application/profile_controller.dart` | done |  |
| `application/diet_editor_controller.dart` | not started | Nutritionist features out of scope |
| `application/generate_plan_use_case.dart` | not started |  |
| `application/import_diet_use_case.dart` | not started |  |
| `presentation/` (root_screen, onboarding, home, plan, diet_editor, share, habits, progress, shopping, scanner, profile, widgets) | different | `ui/` with shell, 5 tab screens (Semana, Hoy, Cambiar, Movimiento, Progreso) and layered components; onboarding, diet editor, share, habits, shopping, scanner not started |
| `test/` (domain, data, presentation) | different | `test/domain`, `test/ui`, controller, architecture and security tests; no `test/data` |

### Product name

The product is named NutriPlan on every surface: docs, Dart package, `S.appName`, Android label and iOS display name.

## Fonts

Newsreader and Work Sans (variable TTFs from the Google Fonts repository) are bundled in `assets/fonts/` under the SIL Open Font License (`OFL-Newsreader.txt`, `OFL-WorkSans.txt`).
