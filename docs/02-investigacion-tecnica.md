# NutriPlan: Investigación Técnica

| Campo | Valor |
|---|---|
| Versión | 1.6 |
| Fecha | 2026-10-04 |
| Documento previo | `01-requerimientos.md` |
| Documento siguiente | `03-hld.md` |

## 1. Propósito

Este documento recoge las decisiones técnicas tomadas antes de diseñar, como ADRs (Architecture Decision Records): contexto, opciones, decisión y consecuencias. La regla que gobierna todas es RNF-12: mínimo de paquetes externos, cada uno justificado y confirmado con el profesor.

## 2. Resumen de decisiones

| Área | Decisión | ADR |
|---|---|---|
| Plataforma | iOS principal (simulador y iPhone con perfil gratuito), Android secundario | ADR-01 |
| Arquitectura | Capas: presentación, aplicación, dominio, datos | ADR-02 |
| Estado | `ChangeNotifier` + `ListenableBuilder` del SDK; `setState` en pantallas simples | ADR-03 |
| Navegación | `Navigator.push/pop` + `NavigationBar` con índice en `setState` | ADR-04 |
| Persistencia | `sqflite` para todo el dominio incluido el perfil; `shared_preferences` solo para tema y flags | ADR-05 |
| Modelos | Clases inmutables escritas a mano con `fromMap`/`toMap` | ADR-06 |
| Compartir dieta | Texto codificado (`NP1.` + base64url(gzip(JSON))) mostrado como QR y copiable | ADR-07 |
| Catálogo | JSON en assets, 120+ alimentos con alérgenos, valores promedio SMAE, fuente por registro | ADR-08 |
| Plan automático | Motor de reglas con filtros de seguridad y 7 plantillas con reparto fijo por tiempo | ADR-09 |
| Código de barras (C) | `mobile_scanner` + HTTP directo a Open Food Facts con `dart:io` | ADR-10 |
| Notificaciones (C) | `flutter_local_notifications` + `timezone` + `flutter_timezone`; solo agua y comidas | ADR-11 |
| Gráficas | Widgets del SDK (`CircularProgressIndicator`, `Container`) | ADR-12 |
| Foto de alimentos | Fuera de 1.0 | ADR-13 |

## 3. ADRs

### ADR-01 Plataforma y versión mínima

**Contexto.** El equipo desarrolla en macOS con el simulador de iPhone 17. No hay cuenta de desarrollador de Apple de pago. No está confirmado un dispositivo Android.

**Decisión.** iOS 15+ como plataforma principal. Un Apple ID gratuito permite instalar en un iPhone físico con un perfil de desarrollo que expira cada 7 días, suficiente para probar cámara y notificaciones. Android 8.0 (API 26) como secundario: Flutter genera ambos desde el mismo código. Android 8 trae SQLite 3.18, lo que descarta `ON CONFLICT DO UPDATE` (requiere 3.24); los repositorios usan `update` y, si no afectó filas, `insert`.

**Consecuencia.** El simulador no tiene cámara. Toda función que dependa de ella (QR por cámara, código de barras) es S o C y tiene una ruta alterna por texto, que es la que se usa en desarrollo y en la demo.

### ADR-02 Arquitectura por capas

**Contexto.** La lógica que da valor (equivalentes, generador, codec) debe probarse sin interfaz. Dos personas trabajan en paralelo.

**Opciones.**
1. Todo en widgets con `setState`. Rápido, imposible de probar y de dividir.
2. Una carpeta por pantalla con su controlador. Mejor, pero la lógica de dominio queda repartida.
3. Capas con dominio aislado: presentación (widgets), aplicación (controladores), dominio (entidades y servicios puros), datos (repositorios sobre sqflite, JSON, HTTP, notificaciones).

**Decisión.** Opción 3. El dominio no importa Flutter ni sqflite y se prueba con `flutter test test/domain`. Los repositorios se declaran como clases abstractas en dominio y se implementan en datos; en pruebas de widgets se sustituyen por implementaciones en memoria. El cliente de Open Food Facts y el servicio de notificaciones son servicios de infraestructura en la capa de datos que los controladores usan a través de una interfaz mínima declarada en aplicación, no repositorios de dominio.

**Consecuencia.** Más archivos. A cambio, RNF-10 es alcanzable y los autores se reparten dominio/datos y presentación.

### ADR-03 Manejo de estado

**Contexto.** Hay estado compartido (dieta activa, consumo del día, perfil) y derivado (cumplimiento, racha). El profesor cuestiona paquetes no vistos en clase.

**Opciones.**
1. Riverpod o Provider. Resuelven bien el estado derivado, pero son paquetes externos con un patrón que el profesor no vio.
2. `setState` únicamente. Visto en clase, pero el estado compartido entre pestañas obliga a subir todo a la raíz.
3. `ChangeNotifier` (SDK) por área funcional, pasado por constructor, y `ListenableBuilder` (SDK) para reconstruir.

**Decisión.** Opción 3. Un `ChangeNotifier` por área: `PlanController`, `HabitController`, `ProfileController`, `DietEditorController`. Se crean una vez en `main.dart` con sus repositorios y se pasan por constructor. Viven lo que dura la app, así que no requieren `dispose`. Las pantallas sin estado compartido usan `setState`.

**Consecuencia.** Los controladores se pasan por constructor explícitamente. Las recargas tras una acción (marcar consumido) no muestran indicador de carga para evitar parpadeo; solo la carga inicial de un día lo muestra.

### ADR-04 Navegación

**Decisión.** `Navigator.push`/`pop` con `MaterialPageRoute` para pantallas apiladas y `NavigationBar` con un índice en `setState` para las pestañas. Es lo visto en clase. Las pestañas no conservan su posición de scroll al cambiar; se acepta.

**Alternativa descartada.** go_router: paquete externo con rutas con nombre y `ShellRoute`. Sin deep links (fuera de alcance) no aporta nada necesario.

### ADR-05 Persistencia

**Contexto.** Los datos son relacionales. Hay consultas como "alimentos del subgrupo X no excluidos".

**Opciones.**
1. shared_preferences con JSON. Falla con listas anidadas y consultas.
2. drift. Consultas tipadas y migraciones, pero exige `build_runner` y es un paquete grande.
3. sqflite. SQLite directo con SQL a mano. Es el paquete estándar de SQLite en Flutter.

**Decisión.** sqflite para todo el dominio, incluido el perfil del usuario (tabla `profile` de una sola fila) y sus exclusiones. shared_preferences únicamente para tema (claro/oscuro) y flags de arranque (onboarding completado). El esquema se crea en `onCreate` con SQL y se versiona con `onUpgrade`. Se activa `PRAGMA foreign_keys = ON` en `onConfigure` porque SQLite lo trae apagado.

**Consecuencia.** El SQL se escribe y revisa a mano. Los repositorios se prueban con `sqflite_common_ffi` (solo `dev_dependencies`) en macOS sin simulador, con `singleInstance: false` para una base limpia por prueba.

### ADR-06 Modelos

**Decisión.** Clases inmutables escritas a mano (`final`, constructor `const`, `copyWith`, `toMap`/`fromMap`). Sin freezed ni json_serializable. Los modelos son menos de 15.

### ADR-07 Compartir dieta sin servidor

**Contexto.** RF-4 pide pasar una dieta del nutriólogo al paciente sin servidor y sin red.

**Opciones.**
1. Firebase o Supabase. Cuentas, red, y Supabase pausa tras una semana inactiva.
2. Deep link con esquema propio. Las apps de mensajería no convierten `nutriplan://` en enlace tocable.
3. Texto codificado que viaja como QR y como texto copiable.

**Decisión.** Opción 3. Formato: `NP1.` + base64url sin relleno de gzip(JSON compacto). El QR se genera con `qr_flutter` con `errorCorrectionLevel: QrErrorCorrectLevel.M` (el valor predeterminado del paquete es L); el texto se copia con `Clipboard` (SDK) y se comparte con `share_plus`. La importación acepta texto pegado (M) o QR por cámara (S).

**Compresión.** `dart:io` incluye `gzip` (`GZipCodec`), disponible en iOS, Android y pruebas. No se agrega el paquete `archive`.

**Tamaño.** El ejemplo de dieta de 1800 kcal con 5 tiempos y 2 exclusiones ocupa 433 bytes de JSON y 294 caracteres codificados. Un QR de 800 caracteres en modo byte con corrección M requiere versión 23 (109×109 módulos), que aún se lee desde una pantalla de teléfono; por encima de eso la lectura se vuelve poco confiable. Se fija el límite de diseño en 800 caracteres codificados.

**Decodificación.** `base64Url.decode` falla sin relleno; se usa `base64Url.normalize` antes.

**Consecuencia.** El formato se versiona. Las exclusiones pueden referir alimentos personalizados inexistentes en el receptor; el importador las descarta (RF-4.7). Las dietas importadas se marcan con origen `imported` para que el rol nutriólogo no las mezcle con las propias.

### ADR-08 Catálogo de alimentos y licencias

**Contexto.** El SMAE tiene derechos reservados (Fomento de Nutrición y Salud). No hay dataset abierto.

**Decisión.** Tres niveles:

1. **Subgrupos** con valores promedio por equivalente: 18 registros de uso pedagógico. El SMAE también define "bebidas alcohólicas" (~140 kcal, 20 g de alcohol), excluido de la app.
2. **Alimentos** capturados por los autores: al menos 120 registros con cantidad por equivalente, unidad casera, peso, etiquetas de alérgenos y fuente (`smae_avg` o `usda:<fdcId>`). Cada subgrupo usado por las plantillas tiene al menos 3 alimentos sin alérgenos comunes para que un usuario con exclusiones amplias tenga opciones.
3. **Platillos compuestos** (extensión futura).

Validación en pruebas: todo alimento referencia un subgrupo existente; los registros USDA deben estar dentro de ±25 % de kcal del promedio de su subgrupo. La validación corre en pruebas, no en el arranque.

**Valores promedio por subgrupo (SMAE 4ª edición, Pérez Lizaur et al.):**

| Subgrupo | Código | kcal | Prot (g) | Líp (g) | HC (g) |
|---|---|---|---|---|---|
| Verduras | VER | 25 | 2 | 0 | 4 |
| Frutas | FRU | 60 | 0 | 0 | 15 |
| Cereales sin grasa | CER_SG | 70 | 2 | 0 | 15 |
| Cereales con grasa | CER_CG | 115 | 2 | 5 | 15 |
| Leguminosas | LEG | 120 | 8 | 1 | 20 |
| Origen animal muy bajo en grasa | AOA_MBG | 40 | 7 | 1 | 0 |
| Origen animal bajo en grasa | AOA_BG | 55 | 7 | 3 | 0 |
| Origen animal moderado en grasa | AOA_MG | 75 | 7 | 5 | 0 |
| Origen animal alto en grasa | AOA_AG | 100 | 7 | 8 | 0 |
| Leche descremada | LEC_D | 95 | 9 | 2 | 12 |
| Leche semidescremada | LEC_SD | 110 | 9 | 4 | 12 |
| Leche entera | LEC_E | 150 | 9 | 8 | 12 |
| Leche con azúcar | LEC_A | 200 | 8 | 5 | 30 |
| Grasas sin proteína | GRA_SP | 45 | 0 | 5 | 0 |
| Grasas con proteína | GRA_CP | 70 | 3 | 5 | 3 |
| Azúcares sin grasa | AZU_SG | 40 | 0 | 0 | 10 |
| Azúcares con grasa | AZU_CG | 85 | 0 | 5 | 10 |
| Libres de energía | LIB | 0 | 0 | 0 | 0 |

### ADR-09 Generación automática de plan

**Contexto.** RF-5 pide un plan determinista, auditable y seguro. En la ronda 1 se propuso un algoritmo de reparto por porcentajes con redondeo; al trazarlo a mano producía colaciones vacías y comidas sin leguminosa. Se reemplaza por repartos fijos escritos a mano y verificados.

**Decisión.** Motor de reglas en el dominio, en este orden:

1. **Edad** desde la fecha de nacimiento. Menor de 18 o 65 o más detiene (RF-5.2). No se pregunta la edad: ya está en el perfil.
2. **Cuestionario de exclusión** (RF-5.1). Cualquier afirmativa detiene.
3. **IMC** = peso / talla². IMC < 18.5 con objetivo bajar, o IMC ≥ 40, detiene. IMC < 18.5 con otro objetivo muestra aviso y continúa (RF-5.3).
4. **Gasto basal (Mifflin-St Jeor):** `10·peso + 6.25·talla − 5·edad + 5` hombres, `− 161` mujeres.
5. **Gasto total (GET)** = basal × factor: sedentario 1.2, ligero 1.375, moderado 1.55, muy activo 1.725.
6. **Piso:** 1200 mujeres, 1500 hombres. Si objetivo es bajar y piso ≥ GET, detiene (RF-5.5): no hay déficit posible.
7. **Meta:** bajar = GET − min(500, 0.25·GET); mantener = GET; subir = GET + 300. Luego máx(meta, piso). El piso gana sobre el tope de déficit: con GET 1400 la meta es 1200 (déficit real 14 %).
8. **Plantilla:** candidatas = plantillas cuyas kcal reales (suma de promedios por subgrupo) sean ≥ máx(0.95·piso, 0.75·GET). El factor 0.95 sobre el piso aplica la misma tolerancia de ±5 % con que se aceptan las plantillas: sin él la de 1200 (1165 reales) nunca sería candidata y toda mujer con GET entre 1227 y 1553 que quisiera bajar quedaría bloqueada. Se elige la más cercana a la meta por kcal real; en empate, la menor si el objetivo es bajar y la mayor si es mantener o subir. Sin candidatas (GET > 4066): `noTemplate`. Con objetivo mantener o subir y meta > 3200 (3050 + 5 %): `noTemplate`. Con objetivo bajar no hay tope superior: el límite inferior y la regla siguiente bastan, así un hombre con GET 3800 recibe la plantilla 3000 (3050 reales, déficit 20 %). Si el objetivo es bajar y las kcal reales de la plantilla elegida son ≥ 0.95·GET: `noDeficit` (un déficit menor al 5 % es mantenimiento en la práctica; la pantalla sugiere el objetivo mantener). Se comparan kcal reales y no nominales porque la de 1800 vale 1775 y la de 1500 vale 1535. Casos de referencia (plantilla nominal, kcal reales entre paréntesis): mujer GET 1330 bajar → 1200 (1165, déficit 12 %); mujer GET 1350 mantener → 1500 (1535; empate resuelto hacia la mayor); mujer GET 1800 bajar → 1500 (1535); mujer GET 2400 bajar → 2000 (2035); hombre GET 1520 bajar → `noDeficit`; hombre GET 1600 bajar → `noDeficit`; hombre GET 1700 bajar → 1500 (1535, déficit 10 %); hombre GET 3800 bajar → 3000 (3050, déficit 20 %); hombre GET 3300 mantener → `noTemplate`; hombre GET 2950 subir → `noTemplate` (3250 > 3200; ofrecer 3050 sería un superávit de 100 kcal, mantenimiento en la práctica). Zonas muertas conocidas con objetivo bajar, todas con salida segura `noDeficit` que redirige a mantener (en GET igual al piso aplica antes `floorAboveTdee`): hombres con GET mayor a 1500 y hasta 1615 (el piso masculino es 1500 y la plantilla más baja que lo respeta vale 1535); mujeres con GET mayor a 1200 y hasta 1226 (la de 1165 no deja 5 % de déficit) y entre 1554 y 1615 (0.75·GET supera 1165 y la de 1535 no deja déficit). Para mantener, el salto entre 1165 y 1535 hace que GET 1340 reciba 1165 (−13 %) y GET 1350 reciba 1535 (+14 %); no hay plantilla intermedia y se acepta. La dieta guarda como `targetKcal` las kcal reales de la plantilla.
9. **Disponibilidad:** para cada subgrupo de la plantilla se verifica que exista al menos un alimento no excluido. Si alguno queda vacío, detiene informando el subgrupo (RF-5.7).
10. **Asignación de alimentos** al materializar cada día: aleatorio sembrado por fecha y contador de regeneración; regenerar conserva los ítems ya consumidos (RF-5.8).

**Matriz de subgrupos permitidos por tiempo** (criterio con el que se construyeron los repartos; también la aplica el editor como advertencia, no como bloqueo):

| Subgrupo | Desayuno | Colación 1 | Comida | Colación 2 | Cena |
|---|---|---|---|---|---|
| VER, FRU, CER_SG, GRA_CP | sí | sí | sí | sí | sí |
| LEG, AOA_BG, GRA_SP | sí | no | sí | no | sí |
| LEC_D | sí | sí | no | sí | sí |

**Plantillas con reparto fijo por tiempo.** Totales diarios y kcal reales (suma de promedios por subgrupo):

| kcal | VER | FRU | CER_SG | LEG | AOA_BG | LEC_D | GRA_SP | GRA_CP | kcal reales | %HC | %P | %L |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1200 | 4 | 2 | 4 | 1 | 4 | 2 | 3 | 0 | 1165 | 51.4 | 24.0 | 24.7 |
| 1500 | 4 | 3 | 6 | 1 | 5 | 2 | 4 | 1 | 1535 | 51.7 | 21.9 | 26.4 |
| 1800 | 4 | 3 | 8 | 1 | 6 | 2 | 5 | 1 | 1775 | 51.6 | 21.5 | 27.0 |
| 2000 | 5 | 4 | 8 | 2 | 7 | 2 | 5 | 1 | 2035 | 52.6 | 22.1 | 25.3 |
| 2300 | 5 | 4 | 11 | 2 | 8 | 2 | 6 | 1 | 2345 | 53.5 | 21.4 | 25.1 |
| 2600 | 5 | 5 | 12 | 2 | 10 | 2 | 7 | 1 | 2630 | 52.3 | 21.6 | 26.1 |
| 3000 | 5 | 6 | 13 | 3 | 11 | 2 | 8 | 2 | 3050 | 52.1 | 21.2 | 26.7 |

Porcentajes con factores de Atwater (4/9/4). Todas dentro de ±5 % del nominal (−2.9 % a +2.3 %), 51 a 55 % de carbohidratos y 21 a 24 % de proteína. La de 1200 queda 35 kcal bajo el piso femenino, dentro del ±5 %.

Reparto por tiempo (D desayuno, C1 colación 1, Co comida, C2 colación 2, Ce cena), con kcal y porcentaje del día:

| kcal | D | C1 | Co | C2 | Ce |
|---|---|---|---|---|---|
| 1200 | CER 1, AOA 1, LEC 1, GRA_SP 1 (265, 23 %) | FRU 1 (60, 5 %) | VER 2, CER 2, LEG 1, AOA 2, GRA_SP 1 (465, 40 %) | FRU 1, VER 1 (85, 7 %) | VER 1, CER 1, AOA 1, LEC 1, GRA_SP 1 (290, 25 %) |
| 1500 | CER 2, AOA 1, LEC 1, GRA_SP 1 (335, 22 %) | FRU 1, GRA_CP 1 (130, 8 %) | VER 2, CER 2, LEG 1, AOA 3, GRA_SP 2 (565, 37 %) | FRU 1, VER 1 (85, 6 %) | VER 1, FRU 1, CER 2, AOA 1, LEC 1, GRA_SP 1 (420, 27 %) |
| 1800 | FRU 1, CER 2, AOA 2, LEC 1, GRA_SP 1 (450, 25 %) | FRU 1, GRA_CP 1 (130, 7 %) | VER 2, CER 3, LEG 1, AOA 3, GRA_SP 2 (635, 36 %) | FRU 1, CER 1 (130, 7 %) | VER 2, CER 2, AOA 1, LEC 1, GRA_SP 2 (430, 24 %) |
| 2000 | FRU 1, CER 2, LEG 1, AOA 2, LEC 1, GRA_SP 1 (570, 28 %) | FRU 1, GRA_CP 1 (130, 6 %) | VER 3, CER 3, LEG 1, AOA 3, GRA_SP 2 (660, 32 %) | FRU 1, VER 1, CER 1 (155, 8 %) | VER 1, FRU 1, CER 2, AOA 2, LEC 1, GRA_SP 2 (520, 26 %) |
| 2300 | FRU 1, CER 3, LEG 1, AOA 2, LEC 1, GRA_SP 1 (640, 27 %) | FRU 1, CER 1, GRA_CP 1 (200, 9 %) | VER 3, CER 4, LEG 1, AOA 4, GRA_SP 3 (830, 35 %) | FRU 1, VER 1, CER 1 (155, 7 %) | VER 1, FRU 1, CER 2, AOA 2, LEC 1, GRA_SP 2 (520, 22 %) |
| 2600 | FRU 1, CER 3, LEG 1, AOA 3, LEC 1, GRA_SP 2 (740, 28 %) | FRU 1, CER 1, GRA_CP 1 (200, 8 %) | VER 3, CER 4, LEG 1, AOA 4, GRA_SP 3 (830, 32 %) | FRU 2, VER 1, CER 1 (215, 8 %) | VER 1, FRU 1, CER 3, AOA 3, LEC 1, GRA_SP 2 (645, 24.5 %) |
| 3000 | FRU 1, CER 4, LEG 1, AOA 3, LEC 1, GRA_SP 2 (810, 27 %) | FRU 2, CER 1, GRA_CP 1 (260, 9 %) | VER 3, CER 4, LEG 1, AOA 5, GRA_SP 3 (885, 29 %) | FRU 2, VER 1, CER 1, GRA_CP 1 (285, 9 %) | VER 1, FRU 1, CER 3, LEG 1, AOA 3, LEC 1, GRA_SP 3 (810, 27 %) |

Cada reparto cumple siete propiedades: suma exactamente la plantilla, respeta la matriz, usa solo enteros, deja los 5 tiempos no vacíos, mantiene cada tiempo dentro de ±10 puntos del objetivo 25/10/35/10/20, cada colación lleva fruta o lácteo, y la comida lleva leguminosa. Una prueba unitaria verifica las siete para las 7 plantillas. Los repartos viven en `diet_templates.json` con horas predeterminadas por tiempo (08:00, 11:00, 14:00, 17:00, 20:00); el generador no calcula el reparto, lo copia.

**Consecuencia.** Determinista, sin red y sin costo. Cada paso es un método con su prueba. Agregar una plantilla es agregar una entrada al JSON que pase la prueba.

### ADR-10 Código de barras (C)

**Decisión.** `mobile_scanner` ≥ 7 (Apple Vision en iOS, ML Kit en Android; versiones anteriores fallaban al compilar para simulador arm64). La consulta a Open Food Facts se hace con `HttpClient` de `dart:io` contra `https://world.openfoodfacts.org/api/v2/product/<barcode>.json` con `User-Agent: NutriPlan/1.0 (ITESO; estudiantes)`. Los productos se guardan en sqflite. No hay forma de detectar la cámara antes de arrancar `MobileScanner`; la pantalla muestra siempre el campo de texto y usa `errorBuilder` para explicar cuando la cámara falla (simulador).

### ADR-11 Notificaciones locales (C)

**Decisión.** `flutter_local_notifications` (fijar `^19.x`) con `timezone` y `flutter_timezone` para la zona local. Solo recordatorios de agua (hasta 12 horas fijas diarias) y de comidas (uno por tiempo con hora). Los recordatorios de hábitos quedan fuera de 1.0. Programación con `zonedSchedule` y `matchDateTimeComponents: DateTimeComponents.time`; Android con `AndroidScheduleMode.inexactAllowWhileIdle`; iOS con `requestPermissions`. Máximo 18 pendientes (12 + 6), lejos del límite de 64 de iOS. `flutter_timezone` desde la versión 5 devuelve `TimezoneInfo`; se usa `.identifier`. Se importa `package:timezone/data/latest_all.dart` (no `latest.dart`) porque Android puede devolver alias de zona que la base reducida no contiene. En Android, `coreLibraryDesugaringEnabled` requiere la dependencia `com.android.tools:desugar_jdk_libs` en `build.gradle`.

### ADR-12 Gráficas

**Decisión.** Sin paquete de gráficas. Cumplimiento por subgrupo con `CircularProgressIndicator(value:)` dentro de un `Stack` con el porcentaje encima, dispuestos en un `GridView` de 4 columnas para que hasta 8 anillos quepan en un iPhone. Resumen semanal con `Row` de `Container` de altura proporcional. Historial de peso como lista.

### ADR-13 Reconocimiento de alimentos por foto

**Decisión.** Fuera de la versión 1.0. Los modelos preentrenados no cubren comida mexicana; `tflite_flutter` migró recientemente a LiteRT; la porción por imagen requiere segmentación.

## 4. Paquetes

| Paquete | Para qué | Prioridad | Justificación |
|---|---|---|---|
| `sqflite` + `path` | Base de datos | M | Paquete estándar de SQLite en Flutter |
| `shared_preferences` | Tema y flags | M | Paquete estándar de preferencias |
| `qr_flutter` | Dibujar el QR | M | No hay QR en el SDK |
| `share_plus` | Hoja de compartir | M | Única forma de abrir la hoja nativa |
| `mobile_scanner` | Leer QR y código de barras | S / C | Única forma de leer códigos con la cámara |
| `flutter_local_notifications` + `timezone` + `flutter_timezone` | Recordatorios | C | No hay notificaciones locales en el SDK; `timezone` es necesario para `TZDateTime` |
| `sqflite_common_ffi` | Pruebas de repositorios en macOS | dev | Solo en `dev_dependencies` |

Nueve paquetes en producción si se implementan todas las prioridades; cinco para los requisitos M (`sqflite`, `path`, `shared_preferences`, `qr_flutter`, `share_plus`). Si el profesor rechaza `share_plus`, se muestra solo el texto para copiar; si rechaza `qr_flutter`, se muestra solo texto. Descartados: Riverpod, go_router, drift, freezed, json_serializable, build_runner, fl_chart, archive, uuid, app_links, confetti, image_picker.

**Widgets fuera del inventario visto en clase** (se confirman con el profesor en la semana 1):

| Widget | Uso |
|---|---|
| `CircularProgressIndicator`, `LinearProgressIndicator` | Cumplimiento |
| `Checkbox`, `Switch`, `DropdownButton`, `Slider` | Formularios |
| `ElevatedButton`, `TextButton`, `IconButton`, `FloatingActionButton` | Acciones |
| `SnackBar` vía `ScaffoldMessenger` | Errores y confirmaciones |
| `showModalBottomSheet` | Intercambio de alimento |
| `ListenableBuilder` | Reconstruir al cambiar un controlador |
| `SelectableText` | Texto codificado copiable |
| `ThemeData`, `themeMode` | Modo claro y oscuro |
| `Semantics` | Etiquetas para lectores de pantalla (RNF-8) |

## 5. Permisos de plataforma

| Permiso | Plataforma | Uso | Momento |
|---|---|---|---|
| `NSCameraUsageDescription` | iOS (Info.plist) | QR y código de barras | Al abrir el escáner |
| `CAMERA` | Android | Igual | Al abrir el escáner |
| Notificaciones | iOS (`requestPermissions`), Android 13+ (`POST_NOTIFICATIONS`) | Recordatorios | Al activar el primero, tras pantalla explicativa |
| `INTERNET` | Android | Open Food Facts | Declarado |

Sin `NSCameraUsageDescription` la app se cierra al abrir la cámara; se agrega en la semana 1 aunque el escáner sea S.

## 6. Esfuerzo

Disponibilidad: 2 personas × 2 días-persona/semana × 12 semanas = 48 días-persona (dp). Las semanas 11 y 12 (8 dp) se reservan para corrección final, pruebas manuales en iPhone y documentación. Quedan 40 dp para construir.

| Función | RF | Prioridad | dp |
|---|---|---|---|
| Base: capas, sqflite con FK, controladores, navegación, tema, `Info.plist` | — | M | 3 |
| Subgrupos + catálogo de 120 alimentos con alérgenos + loader | RF-2.1, 2.2 | M | 4 |
| Perfil, rol, exclusiones del usuario, onboarding | RF-1.1 a 1.4, 1.6, 1.7 | M | 3 |
| Búsqueda de alimentos | RF-2.3 | M | 1 |
| Editor de dietas con totales en vivo | RF-3.1 a 3.4, 3.7 | M | 3 |
| Codec, QR, copiar, pegar, importar con validación y filtro | RF-4.1 a 4.3, 4.5 a 4.7 | M | 3 |
| Generador: edad, cuestionario, IMC, GET, piso, plantillas, disponibilidad, aviso | RF-5.1 a 5.7, 5.9 | M | 3 |
| Plan del día y semana, intercambio, consumido, sin alimento, regenerar | RF-6.1 a 6.5, 6.7, 5.8 | M | 4 |
| Agua y hábitos | RF-7.1 a 7.3 | M | 2 |
| Cumplimiento en inicio | RF-8.1 | M | 2 |
| **Subtotal M (construcción)** | | | **28** |
| Pruebas de datos y de widgets para los M, y cobertura final de dominio | RNF-10 | M | 4 |
| **Subtotal M** | | | **32** |
| Plantillas precargadas, exclusiones de dieta | RF-3.5, 3.6 | S | 1 |
| Escaneo de QR con cámara | RF-4.4 | S | 1 |
| Historial de peso, historial de dietas | RF-1.5, 4.8, 8.4 | S | 1 |
| Rachas, exceso, resumen semanal | RF-7.4, 8.2, 8.3 | S | 3 |
| Lista de compras | RF-9 | S | 2 |
| **Subtotal S** | | | **8** |
| Alimentos personalizados, registro fuera del plan | RF-2.4, 6.6 | C | 1 |
| Código de barras + Open Food Facts | RF-2.5, 2.6 | C | 3 |
| Notificaciones de agua y comidas | RF-10 | C | 3 |
| Celebración, compartir logro, alerta de pérdida de peso | RF-8.5, 8.6, 8.7 | C | 1 |
| **Subtotal C** | | | **8** |

Las pruebas unitarias de cada servicio de dominio se escriben junto con el servicio y están incluidas en la fila de su función; los 4 dp de la fila de pruebas cubren las pruebas de repositorios con `sqflite_common_ffi`, las de widgets y la verificación de cobertura.

Suma comprometida: M 32 + S 8 = 40 dp, igual a los 40 disponibles para construir. Los C (8 dp) no están presupuestados: se hacen solo si los M cierran antes de la semana 8. Si en la semana 6 los M van atrasados, se recortan los S empezando por lista de compras.

## 7. Riesgos técnicos

| Riesgo | Mitigación |
|---|---|
| Catálogo con errores | Revisión cruzada, prueba de desviación para registros USDA, fuente por alimento |
| QR ilegible | Límite de 800 caracteres verificado por prueba con la dieta máxima; corrección M explícita |
| Sin cámara en simulador | Importación por texto es M; QR por cámara es S y se prueba en iPhone físico |
| Permisos de notificación | Funciona sin ellos; explicación previa |
| Profesor rechaza un paquete | Lista confirmada en semana 1; alternativas por paquete en §4 |
| Horario de verano en rachas | Aritmética de fechas con `DateTime(y, m, d - 1)`, nunca con `Duration` |
| `INSERT OR REPLACE` borra hijos por cascada | Los repositorios hacen `update` y luego `insert` si no afectó filas |
| Transacción anidada en `onCreate` | La semilla usa `Batch`, no `transaction` |

## 8. Herramientas de desarrollo

- Git con ramas por feature y revisión entre los dos autores antes de integrar a `main`.
- `flutter analyze` con `flutter_lints` y `dart format` antes de cada commit.
- `flutter test --coverage`; umbral de 80 % en los cuatro servicios críticos de RNF-10, verificado con `lcov` antes de cada entrega. Sin CI.
- Simulador: `xcrun simctl boot <UDID>` y `flutter run -d <UDID>`.
