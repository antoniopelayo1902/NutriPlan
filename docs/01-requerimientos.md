# NutriPlan: Documento de Requerimientos

| Campo | Valor |
|---|---|
| Proyecto | NutriPlan: planificador de alimentación por equivalentes |
| Autores | Andrés Gómez Tagle Azcárraga, Eduardo Antonio Pelayo Carrillo |
| Materia | Desarrollo de Aplicaciones Móviles, ITESO |
| Versión | 1.6 |
| Fecha | 2026-10-04 |
| Estado | Revisado (rondas 1 a 6 de auditoría aplicadas) |

## 1. Propósito

Este documento define qué debe hacer NutriPlan y bajo qué restricciones. Es la referencia contra la que se valida el diseño (HLD, LLD) y la entrega final. Cada requerimiento tiene un identificador que el HLD referencia por componente y el LLD por clase y caso de prueba.

## 2. Problema

Las personas que siguen una dieta reciben el plan de su nutriólogo como una hoja impresa o una foto de una tabla. Cuando no tienen el alimento indicado, no saben qué comer en su lugar y abandonan el plan. Las apps de nutrición más usadas (MyFitnessPal, Yazio, Lifesum, Fitia) cuentan calorías pero no manejan el sistema de equivalentes que usan los nutriólogos en México, y las herramientas que sí lo manejan (Nutrimind, Monitor Nutricional) están hechas para el consultorio, no para el paciente.

Las personas sin nutriólogo tienen el problema inverso: quieren comer mejor pero no tienen un plan de dónde partir.

## 3. Visión del producto

NutriPlan es una aplicación móvil que lleva el Sistema Mexicano de Alimentos Equivalentes (SMAE) al teléfono del paciente. El nutriólogo captura la dieta por equivalentes y la comparte como un código (QR o texto). El paciente ve su plan en medidas caseras, cambia cualquier alimento por un equivalente del mismo grupo con un toque, registra lo que comió y ve su cumplimiento. Quien no tiene nutriólogo recibe un plan generado por la app a partir de su meta calórica, con filtros de seguridad y avisos claros de que es orientativo.

## 4. Usuarios y roles

La aplicación tiene dos roles. Un usuario elige su rol al registrarse y puede cambiarlo desde su perfil.

| Rol | Descripción | Qué hace en la app |
|---|---|---|
| Nutriólogo | Profesional que prescribe dietas | Captura dietas por equivalentes, las comparte como código; carga plantillas por kcal (deseable) |
| Usuario | Persona que sigue un plan de alimentación | Ve su plan, cambia equivalentes, registra comidas, agua y hábitos, ve su progreso |

El usuario tiene dos escenarios según el origen de su plan, pero ambos usan las mismas pantallas:

- **Usuario con nutriólogo:** importa el plan desde el código que le comparte su nutriólogo.
- **Usuario sin nutriólogo:** genera su plan desde la app a partir de sus datos.

## 5. Alcance

### 5.1 Dentro del alcance

- Catálogo local de alimentos clasificados por grupo y subgrupo del SMAE.
- Captura de dietas por equivalentes (rol nutriólogo) con totales en vivo.
- Compartir e importar dietas por código QR o por texto copiable.
- Generación automática de plan por reglas con cuestionario de exclusión y control por IMC.
- Vista del plan diario y semanal en medidas caseras.
- Intercambio de alimentos por equivalentes del mismo subgrupo.
- Registro de comidas consumidas, agua y hábitos.
- Progreso: cumplimiento por subgrupo, exceso, rachas, resumen semanal.
- Lista de compras generada del plan semanal.
- Escaneo de código de barras con consulta a Open Food Facts (opcional).
- Notificaciones locales de agua y comidas (opcional).
- Persistencia local de todos los datos.
- Modo claro y oscuro.

### 5.2 Fuera del alcance (versión 1.0)

- Sincronización en la nube y cuentas remotas.
- Enlaces profundos (deep links): las apps de mensajería no convierten esquemas personalizados en enlaces tocables, así que el valor es bajo. Se comparte texto copiable.
- Chat nutriólogo-paciente.
- Reconocimiento de alimentos por foto y estimación de porciones por imagen.
- Integración con Health Connect o HealthKit.
- Planes para condiciones médicas.
- Pagos o suscripciones.

## 6. Requerimientos funcionales

Formato: "CUANDO <condición>, el sistema DEBERÁ <comportamiento>" o "El sistema DEBERÁ <comportamiento>". Prioridad: **M** = obligatorio para la entrega, **S** = deseable, **C** = opcional.

### RF-1 Registro y perfil

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-1.1 | Al abrir la app por primera vez, el sistema DEBERÁ mostrar un flujo de bienvenida que permita elegir el rol (nutriólogo o usuario). | M |
| RF-1.2 | CUANDO el usuario elige el rol usuario, el sistema DEBERÁ capturar nombre, sexo, fecha de nacimiento, peso (kg), talla (cm), nivel de actividad y objetivo (bajar, mantener, subir peso). | M |
| RF-1.3 | CUANDO el usuario elige el rol nutriólogo, el sistema DEBERÁ capturar nombre y, opcionalmente, cédula profesional. | M |
| RF-1.4 | El sistema DEBERÁ permitir editar los datos del perfil y cambiar de rol en cualquier momento. CUANDO el rol cambia a usuario y faltan datos (sexo, peso, talla, actividad, objetivo), el sistema DEBERÁ pedirlos con el mismo formulario del registro. | M |
| RF-1.5 | CUANDO el usuario cambia su peso, el sistema DEBERÁ guardar el valor con fecha para construir el historial de peso. | S |
| RF-1.6 | El sistema DEBERÁ permitir configurar la meta diaria de agua en vasos (predeterminado 8). | M |
| RF-1.7 | El sistema DEBERÁ permitir al usuario registrar alimentos que no consume (alergias, intolerancias, preferencias), que se aplican como exclusiones a cualquier plan. | M |

### RF-2 Catálogo de alimentos

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-2.1 | El sistema DEBERÁ incluir un catálogo local de al menos 120 alimentos, cada uno con grupo SMAE, subgrupo, cantidad por equivalente, unidad casera, peso en gramos, kcal, proteína, lípidos, carbohidratos, fuente y etiquetas de alérgenos (gluten, lácteo, huevo, cacahuate, nuez, mariscos, soya, pescado). | M |
| RF-2.2 | El sistema DEBERÁ incluir los valores promedio por subgrupo del SMAE (kcal y macronutrientes por equivalente). | M |
| RF-2.3 | El sistema DEBERÁ permitir buscar alimentos por nombre con filtro por grupo. | M |
| RF-2.4 | El sistema DEBERÁ permitir al usuario agregar alimentos personalizados indicando subgrupo y cantidad por equivalente. | C |
| RF-2.5 | CUANDO el usuario escanea un código de barras o lo escribe a mano, el sistema DEBERÁ consultar Open Food Facts y mostrar nombre, kcal y macronutrientes por 100 g, proponiendo el subgrupo SMAE más cercano. | C |
| RF-2.6 | CUANDO la consulta a Open Food Facts falla por falta de red o producto inexistente, el sistema DEBERÁ informarlo y permitir capturar el alimento a mano. | C |

### RF-3 Captura de dieta (rol nutriólogo)

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-3.1 | El sistema DEBERÁ permitir crear una dieta con nombre, etiqueta de paciente, meta calórica, fecha de inicio y vigencia en semanas. | M |
| RF-3.2 | El sistema DEBERÁ permitir definir de 3 a 6 tiempos de comida por día (desayuno, colación 1, comida, colación 2, cena, colación 3). | M |
| RF-3.3 | El sistema DEBERÁ permitir asignar a cada tiempo de comida una cantidad de equivalentes por subgrupo, en incrementos de 0.5. | M |
| RF-3.4 | MIENTRAS el nutriólogo edita la dieta, el sistema DEBERÁ mostrar en vivo el total de kcal, proteína, lípidos y carbohidratos del día y su porcentaje respecto a la meta. | M |
| RF-3.5 | El sistema DEBERÁ ofrecer plantillas precargadas de 1200, 1500, 1800, 2000, 2300, 2600 y 3000 kcal que se puedan cargar y editar. | S |
| RF-3.6 | El sistema DEBERÁ permitir marcar alimentos excluidos para una dieta. | S |
| RF-3.7 | El sistema DEBERÁ permitir guardar varias dietas y listarlas por etiqueta de paciente. | M |

### RF-4 Compartir e importar dieta

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-4.1 | CUANDO el nutriólogo elige compartir una dieta, el sistema DEBERÁ generar un texto codificado que contenga la dieta completa (tiempos de comida, equivalentes por subgrupo, exclusiones y metadatos) y mostrarlo como código QR. | M |
| RF-4.2 | El sistema DEBERÁ permitir copiar el texto codificado al portapapeles y compartirlo con la hoja de compartir del sistema. | M |
| RF-4.3 | El sistema DEBERÁ permitir importar una dieta pegando el texto codificado. | M |
| RF-4.4 | El sistema DEBERÁ permitir importar una dieta escaneando el QR con la cámara. | S |
| RF-4.5 | CUANDO el texto o QR es válido, el sistema DEBERÁ mostrar un resumen de la dieta y pedir confirmación antes de reemplazar el plan activo. | M |
| RF-4.6 | CUANDO el texto o QR no es de NutriPlan, su versión no es compatible o está corrupto, el sistema DEBERÁ mostrar un mensaje de error claro sin modificar el plan actual. | M |
| RF-4.7 | CUANDO la dieta importada excluye alimentos que no existen en el catálogo del dispositivo receptor, el sistema DEBERÁ ignorar esas exclusiones sin fallar. | M |
| RF-4.8 | El sistema DEBERÁ conservar el plan anterior como historial al importar uno nuevo. | S |

### RF-5 Generación automática de plan

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-5.1 | CUANDO el usuario sin nutriólogo solicita un plan, el sistema DEBERÁ aplicar un cuestionario de exclusión: embarazo o lactancia, diabetes, enfermedad renal, enfermedad hepática o cardiovascular, cirugía bariátrica, trastorno de la conducta alimentaria, medicamentos que afectan glucosa o apetito, otra condición médica bajo tratamiento. | M |
| RF-5.2 | CUANDO alguna respuesta del cuestionario es afirmativa, o CUANDO la edad calculada desde la fecha de nacimiento es menor a 18 o de 65 o más, el sistema DEBERÁ negarse a generar el plan y recomendar acudir con un nutriólogo. | M |
| RF-5.3 | El sistema DEBERÁ calcular el IMC del usuario. CUANDO el IMC es menor a 18.5 y el objetivo es bajar, o CUANDO el IMC es 40 o mayor, el sistema DEBERÁ negarse a generar el plan y recomendar acudir con un nutriólogo. CUANDO el IMC es menor a 18.5 con otro objetivo, el sistema DEBERÁ mostrar una recomendación de valoración profesional antes de continuar. | M |
| RF-5.4 | El sistema DEBERÁ calcular el gasto energético total con Mifflin-St Jeor por el factor de actividad, ajustando −500 kcal para bajar (sin exceder un déficit del 25 % del gasto total) y +300 kcal para subir. | M |
| RF-5.5 | El sistema DEBERÁ aplicar un piso de 1200 kcal para mujeres y 1500 kcal para hombres. CUANDO el objetivo es bajar y el piso es igual o mayor al gasto total, el sistema DEBERÁ negarse a generar el plan y recomendar acudir con un nutriólogo. | M |
| RF-5.6 | El sistema DEBERÁ seleccionar, entre las plantillas cuyas kcal reales sean iguales o mayores al máximo entre el 95 % del piso y el 75 % del gasto total, la más cercana a la meta calórica; en empate, la menor si el objetivo es bajar y la mayor en otro caso. Las plantillas van de 1200 a 3000 kcal y cada una define el reparto fijo en 5 tiempos de comida. CUANDO no hay candidatas, o CUANDO el objetivo es mantener o subir y la meta excede 3200 kcal, el sistema DEBERÁ informar que no hay plantilla y recomendar un nutriólogo. CUANDO el objetivo es bajar y las kcal reales de la plantilla elegida son iguales o mayores al 95 % del gasto total, el sistema DEBERÁ informar que no hay un déficit seguro posible y sugerir el objetivo mantener. | M |
| RF-5.7 | ANTES de guardar un plan generado, el sistema DEBERÁ verificar que cada subgrupo prescrito tenga al menos un alimento disponible tras aplicar las exclusiones del usuario. CUANDO alguno no lo tenga, el sistema DEBERÁ informar qué subgrupo queda vacío y recomendar un nutriólogo. | M |
| RF-5.8 | El sistema DEBERÁ proponer alimentos concretos para cada equivalente respetando las exclusiones del usuario (RF-1.7) y permitir regenerar la propuesta de un día conservando los alimentos ya marcados como consumidos. | M |
| RF-5.9 | ANTES de guardar un plan generado, el sistema DEBERÁ mostrar el aviso legal y requerir aceptación explícita en cada generación. El aviso también es accesible desde el perfil. | M |

### RF-6 Plan diario y semanal

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-6.1 | El sistema DEBERÁ mostrar el plan del día con sus tiempos de comida, los alimentos propuestos y su cantidad en medida casera. | M |
| RF-6.2 | El sistema DEBERÁ mostrar una vista semanal con los 7 días y permitir navegar entre ellos. | M |
| RF-6.3 | CUANDO el usuario toca un alimento del plan, el sistema DEBERÁ ofrecer alternativas del mismo subgrupo con la misma cantidad de equivalentes, sin incluir alimentos excluidos. | M |
| RF-6.4 | CUANDO el usuario elige una alternativa, el sistema DEBERÁ reemplazar el alimento solo para ese día y tiempo de comida, sin alterar la prescripción. | M |
| RF-6.5 | El sistema DEBERÁ permitir marcar cada alimento como consumido con un toque y deshacerlo. | M |
| RF-6.6 | El sistema DEBERÁ permitir registrar un alimento fuera del plan indicando subgrupo y equivalentes. | C |
| RF-6.7 | CUANDO un subgrupo no tiene alimentos disponibles por las exclusiones, el sistema DEBERÁ mostrar el equivalente sin alimento asignado y permitir elegirlo a mano. | M |

### RF-7 Agua y hábitos

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-7.1 | El sistema DEBERÁ permitir registrar vasos de agua con un toque y mostrar el avance contra la meta diaria. | M |
| RF-7.2 | El sistema DEBERÁ permitir crear, editar y eliminar hábitos con nombre, ícono y al menos un día de la semana en que aplican. | M |
| RF-7.3 | El sistema DEBERÁ permitir marcar un hábito como cumplido para el día actual. | M |
| RF-7.4 | El sistema DEBERÁ calcular la racha de días consecutivos cumplidos por hábito y la racha global del plan. | S |

### RF-8 Progreso

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-8.1 | El sistema DEBERÁ mostrar en la pantalla de inicio el cumplimiento del día por subgrupo (consumidos contra prescritos) y el global. | M |
| RF-8.2 | El sistema DEBERÁ mostrar el exceso del día: equivalentes consumidos por encima de lo prescrito, incluyendo subgrupos no prescritos, y su estimado en kcal. CUANDO el exceso supera el máximo entre 150 kcal y el 7.5 % de la meta calórica, el sistema DEBERÁ marcar el día. | S |
| RF-8.3 | El sistema DEBERÁ mostrar un resumen semanal de porcentaje de cumplimiento por día. | S |
| RF-8.4 | El sistema DEBERÁ mostrar el historial de peso cuando exista. | S |
| RF-8.5 | CUANDO el usuario completa el 100 % del plan del día, el sistema DEBERÁ mostrar un mensaje de celebración. | C |
| RF-8.6 | El sistema DEBERÁ permitir compartir un texto con el logro de racha mediante la hoja de compartir del sistema. | C |
| RF-8.7 | CUANDO, con un plan generado activo durante todo el periodo, el último registro de peso de tres semanas ISO 8601 consecutivas (lunes a domingo, en fecha local; al menos un registro por semana) muestra una pérdida mayor a 1 kg en cada uno de los dos intervalos entre semanas, el sistema DEBERÁ recomendar suspender el plan y acudir con un nutriólogo. | C |

### RF-9 Lista de compras

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-9.1 | El sistema DEBERÁ generar la lista de compras de la semana sumando los alimentos del plan semanal y agrupándolos por grupo SMAE. | S |
| RF-9.2 | El sistema DEBERÁ permitir marcar artículos como comprados y agregar artículos manuales, conservándolos al regenerar. | S |

### RF-10 Notificaciones

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF-10.1 | El sistema DEBERÁ permitir activar recordatorios de agua a horas fijas dentro de un horario de vigilia configurable, con un máximo de 12 por día. | C |
| RF-10.2 | El sistema DEBERÁ permitir activar un recordatorio por tiempo de comida a la hora configurada. | C |
| RF-10.3 | CUANDO el permiso de notificaciones no está otorgado, el sistema DEBERÁ explicar para qué se usa antes de solicitarlo y funcionar sin él si se niega. | C |

Los recordatorios de hábitos quedan fuera de la versión 1.0.

## 7. Requerimientos no funcionales

| ID | Requerimiento |
|---|---|
| RNF-1 | **Plataformas.** iOS 15 o superior como plataforma principal (desarrollo en simulador de iPhone y prueba en iPhone físico con perfil de desarrollo gratuito). Android 8.0 (API 26) o superior como plataforma secundaria si hay dispositivo. |
| RNF-2 | **Operación sin red.** Todas las funciones M funcionan sin conexión. Solo la consulta a Open Food Facts requiere red. |
| RNF-3 | **Rendimiento.** La pantalla de inicio se muestra en menos de 1 segundo tras abrir la app. La búsqueda en el catálogo responde en menos de 200 ms. |
| RNF-4 | **Persistencia.** Los datos sobreviven al cierre de la app y al reinicio del dispositivo. La base de datos tiene número de versión y mecanismo de migración desde la versión 1. |
| RNF-5 | **Tamaño.** La app instalada no excede 40 MB. |
| RNF-6 | **Privacidad.** Ningún dato del usuario sale del dispositivo salvo el código de barras enviado a Open Food Facts. Las respuestas del cuestionario de exclusión no se guardan. No hay telemetría. |
| RNF-7 | **Aviso legal.** Se muestra y se acepta en cada generación automática de plan y es accesible desde el perfil. |
| RNF-8 | **Accesibilidad.** Los controles tienen etiquetas semánticas. El contraste cumple WCAG AA en ambos temas. |
| RNF-9 | **Idioma.** Interfaz en español de México. Las cadenas visibles se concentran en un archivo para facilitar cambios. |
| RNF-10 | **Calidad.** Pruebas unitarias con cobertura de al menos 80 % en los servicios de dominio críticos: cálculo energético, generador de plan, codificador de dieta y servicio de cumplimiento. |
| RNF-11 | **Licencias.** El catálogo no reproduce el libro del SMAE. Los alimentos se capturan con los valores promedio por subgrupo o desde USDA FoodData Central (dominio público) y cada registro cita su fuente. |
| RNF-12 | **Dependencias.** Se minimizan los paquetes externos. Cada paquete fuera del SDK de Flutter se justifica en el documento de investigación técnica y se confirma con el profesor antes de usarlo. |

## 8. Restricciones

- Equipo de dos personas, un semestre, con otras materias en paralelo: se estiman 2 días-persona por semana por integrante, unos 48 días-persona en 12 semanas.
- Sin presupuesto para servicios de pago, APIs comerciales ni cuenta de desarrollador de Apple de pago.
- Framework obligatorio: Flutter. El profesor cuestiona widgets y paquetes no vistos en clase; cada uno fuera del inventario de clase se justifica.
- Entorno de desarrollo: macOS con simulador de iPhone. El simulador no tiene cámara, por lo que las funciones de escaneo se prueban en dispositivo físico y las rutas de importación por texto deben cubrir la demo.
- La demostración se hace en un solo dispositivo: se cambia de rol nutriólogo a usuario, se copia el código y se importa pegándolo. Si hay un segundo dispositivo, se demuestra también el QR con cámara.

## 9. Aviso legal

Texto que la app muestra antes de guardar un plan automático:

> NutriPlan ofrece información general con fines educativos y no sustituye la valoración de un profesional de la salud. Los planes generados automáticamente no son aptos durante el embarazo o la lactancia, para menores de 18 años o personas de 65 años o más, ni para quienes viven con diabetes, enfermedad renal, hepática o cardiovascular, cirugía bariátrica, trastornos de la conducta alimentaria u otra condición médica bajo tratamiento. Registra tus alergias e intolerancias en tu perfil antes de generar un plan. Si presentas mareo, debilidad o una pérdida de peso mayor a 1 kg por semana de forma sostenida, suspende el plan y consulta a un nutriólogo con cédula profesional.

## 10. Supuestos

- Los valores promedio por subgrupo del SMAE son de uso pedagógico y se pueden incluir citando la fuente.
- Nutriólogo y paciente están juntos al compartir el plan, o intercambian el texto codificado por mensajería. No se requiere servidor.
- Una dieta serializada y comprimida cabe en menos de 800 caracteres, lo que corresponde a un QR de versión 23 o menor (109×109 módulos) con corrección de errores M, legible desde la pantalla de un teléfono.

## 11. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Captura manual del catálogo con errores | Los intercambios propagan el error | Revisión cruzada entre autores, fuente por alimento, prueba de desviación solo para registros con fuente USDA |
| El plan automático se usa por alguien a quien le hace daño | Riesgo de salud y legal | Cuestionario ampliado, control por IMC, exclusiones por alergia, piso y tope de déficit, aviso legal por generación |
| Alcance mayor al tiempo | Entrega incompleta | Solo M es compromiso (28 días-persona más 4 de pruebas, cierre en semana 8); S en semanas 9 y 10 (8 días-persona); C solo si sobra tiempo |
| El profesor rechaza un paquete | Retrabajo | Stack mínimo; confirmar la lista de paquetes en la semana 1 |
| Sin cámara en el simulador | No se prueba QR durante el desarrollo | Importación por texto como ruta M; prueba de QR en iPhone físico |
| Permisos de notificación en iOS y Android 13+ | Recordatorios no llegan | La app funciona sin ellos; se explica antes de pedir el permiso |

## 12. Trazabilidad

La matriz de trazabilidad por requerimiento individual está en la sección 15 del LLD (`04-lld.md`).
