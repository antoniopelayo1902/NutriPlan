# NutriPlan: documentación de diseño

Planificador de alimentación por equivalentes (SMAE) en Flutter. Plataforma principal iOS (simulador y iPhone con perfil de desarrollo gratuito), Android secundario.
Proyecto de la materia Desarrollo de Aplicaciones Móviles, ITESO.

Autores: Andrés Gómez Tagle Azcárraga, Eduardo Antonio Pelayo Carrillo.

## Documentos

Leer en orden. Cada documento referencia al anterior y los identificadores (RF-x, RNF-x, ADR-x) se usan en todos.

| # | Documento | Qué responde |
|---|---|---|
| 1 | [Requerimientos](01-requerimientos.md) | Qué debe hacer la app y bajo qué restricciones |
| 2 | [Investigación técnica](02-investigacion-tecnica.md) | Qué tecnologías se eligieron y por qué (ADRs) |
| 3 | [Diseño de alto nivel](03-hld.md) | Qué componentes hay, qué hace cada uno y cómo fluye la información |
| 4 | [Diseño de bajo nivel](04-lld.md) | Cómo se implementa: estructura, esquema, clases, algoritmos, pruebas, calendario |

## Estado

| Documento | Versión | Estado |
|---|---|---|
| Requerimientos | 1.6 | Rondas 1 a 6 de auditoría aplicadas |
| Investigación técnica | 1.6 | Rondas 1 a 6 de auditoría aplicadas |
| HLD | 1.6 | Rondas 1 a 6 de auditoría aplicadas |
| LLD | 1.6 | Rondas 1 a 6 de auditoría aplicadas |

Ronda 1: iOS principal, demo en un dispositivo, stack mínimo, cuestionario con IMC y alergias, plantillas corregidas, exceso, peso en perfil, totales en vivo, QR a 800 caracteres, correcciones de código, calendario, trazabilidad por ID.

Ronda 2: repartos por tiempo fijos y verificados por plantilla, edad calculada del perfil, bloqueo cuando el piso iguala el gasto, selección de plantilla acotada al tope de déficit, verificación de alimentos disponibles antes de guardar, regenerar conservando consumidos, tabla `profile` en SQLite, origen `imported`, `update`+`insert`, `Batch` en la semilla, `timezone` declarado, notificaciones solo agua y comidas, código de barras y notificaciones a C, esfuerzo balanceado, QR nivel M, GridView para anillos.

Ronda 3: colación 2 de la plantilla 1800 con fruta, selección de plantilla por kcal reales con bloqueo si no hay déficit, comprobación de edad antes del cuestionario, `loadDay` serializado (sin unir peticiones), `keep` con diferencias de cantidad y huérfanos, borrado de planes futuros al editar la dieta activa, `BlockReason` declarado una sola vez, `singleInstance` en pruebas, `ensureInitialized` en `main`, horas en plantillas, umbral de exceso en RF-8.2, alerta de pérdida de peso como RF-8.7 (C), pruebas de plantilla con siete propiedades.

Ronda 4: piso con tolerancia de 5 % en la selección de plantilla (sin ella la de 1200 nunca era candidata y las mujeres con gasto entre 1227 y 1553 quedaban bloqueadas), razón `noDeficit` separada de `noTemplate`, `targetKcal` guarda kcal reales, `loadDay` con `Completer` que espera toda la cadena y refresco por `_requestedDate`, RF-2.4 y RF-6.6 a C, `NutritionTotals` en semana 3, ramas faltantes en el diagrama de generación, subgrupo repetido rechazado por el codec, `updatedAt` en dieta y `createdAt` en plan del día para avisar "tu dieta cambió", RF-8.7 con definición de medición.

Ronda 5: tope de 3200 solo para mantener y subir (al bajar bastan el límite inferior y `noDeficit`), `noDeficit` cuando el déficit es menor al 5 %, empate de plantillas resuelto por objetivo, `materializedAt` en el plan del día con `dietChanged` en el controlador y pruebas, `_load` con `try/catch/finally` que deja el error en el controlador en vez de propagarlo, `copyWith` y valores por defecto declarados en `Diet` y `MealSlot`, RF-8.7 con semanas ISO, RF-8.4 en la fila correcta del esfuerzo, plan de respaldo para la semana 3.

Ronda 6 (consistencia y técnica APROBADAS; dominio pidió documentar zonas muertas): zonas muertas femeninas (GET 1200-1226 y 1554-1615 al bajar) documentadas con salida `noDeficit` y casos de prueba, casos de referencia con plantilla nominal y kcal reales entre paréntesis, RF-8.7 con semanas ISO 8601 y dos intervalos explícitos, acciones del controlador envueltas en `_act` para no propagar errores, reloj inyectable en el controlador, parámetros del `reduce` renombrados, imports declarados.

Ronda 7 (final): los tres auditores (consistencia, técnica Flutter/Dart, dominio nutricional) dieron VEREDICTO: APROBADO sin hallazgos bloqueantes ni importantes. Diseño listo para iniciar implementación.

## Pendientes antes de iniciar implementación

- Confirmar con el profesor la lista de paquetes y los widgets fuera del inventario de clase (02 §4).
- Fijar versiones exactas en `pubspec.yaml`.
- Capturar `subgroups.json`, `diet_templates.json` (repartos en 02 ADR-09) y las primeras 60 entradas de `food_catalog.json`.
- Revisar el aviso legal con el profesor o con un nutriólogo.
- Mover esta carpeta al repositorio del proyecto.
