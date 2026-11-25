# NutriPlan

App móvil en Flutter para llevar un plan de alimentación por equivalentes. La
nutrióloga ve a sus pacientes, registra sus medidas y ajusta las porciones de
su plan. El paciente ve qué le toca comer cada día, marca lo que ya comió,
cambia platillos por otros equivalentes, registra su actividad y sigue su
progreso. Toda la información vive en Firebase.

Proyecto para la materia de Desarrollo de Aplicaciones Móviles, ITESO.

## Autores

- Andrés Gómez Tagle Azcárraga
- Eduardo Antonio Pelayo Carrillo

## Qué hace la app

Al crear tu cuenta (con correo o con Google) eliges si eres paciente o
nutrióloga.

**Paciente** (barra de navegación inferior con 5 secciones):

- **Semana:** las comidas de cada día. Puedes cambiar de día y marcar lo que ya comiste.
- **Hoy:** cuántas porciones llevas de cada grupo de alimentos y tu siguiente comida.
- **Cambiar:** cambia un platillo por otro equivalente; la app avisa si cabe, si hay que ajustar o si no cabe.
- **Movimiento:** registro de actividad. Se pueden crear, editar y eliminar sesiones.
- **Progreso:** adherencia de la semana, racha y medidas mes con mes.

Al tocar tu círculo de iniciales entras a **Mi perfil**: foto desde la
galería, nombre, tu nutrióloga, cerrar sesión, eliminar cuenta y el código QR.

**Nutrióloga:**

- Lista de pacientes vinculados.
- Por paciente: medidas (crear, editar y eliminar), historial con gráficas,
  el plan de comidas y las porciones diarias por grupo, con las calorías
  recalculadas.
- Arma el plan de comidas: elige un platillo del catálogo para cada comida de
  la semana (o copia un día a toda la semana) y lo publica. El paciente lo ve
  al refrescar y el plan se repite cada semana.
- Su código QR para que los pacientes se vinculen con ella.

En todas las listas se puede jalar hacia abajo para recargar desde Firebase.

## Factor WOW: códigos QR

- La nutrióloga muestra su QR y el paciente lo escanea con la cámara para
  vincularse con ella.
- Un paciente puede compartir su plan con un QR y otro paciente lo importa.
- En el simulador, que no tiene cámara, el código también se puede copiar y
  pegar.

## Tecnologías

- Flutter y Dart
- Firebase Authentication (correo y Google)
- Cloud Firestore
- Firebase Cloud Messaging (token del dispositivo)

## Paquetes

| Paquete | Para qué se usa |
|---|---|
| `firebase_core` | Conectar la app con Firebase |
| `firebase_auth` | Login con correo y contraseña |
| `google_sign_in` | Login con Google |
| `cloud_firestore` | Base de datos |
| `firebase_messaging` | Permiso de notificaciones y token del dispositivo |
| `provider` | Compartir el estado entre pantallas |
| `image_picker` | Elegir la foto de perfil de la galería |
| `path_provider` | Guardar la foto de perfil en el teléfono |
| `qr_flutter` | Dibujar los códigos QR |
| `mobile_scanner` | Escanear códigos QR con la cámara |
| `flutter_launcher_icons` | Ícono de la app |

## Base de datos (Firestore)

```
users/{uid}                 perfil, rol (patient o nutritionist), token
users/{uid}/plan/current    menú de la semana, porciones diarias y meta de actividad
users/{uid}/days/{fecha}    comidas de cada día
users/{uid}/activityLogs    sesiones de actividad
users/{uid}/measurements    medidas de cada consulta
nutritionists/{id}          nombre de cada nutrióloga
options                     catálogo de platillos por tiempo de comida
```

Una cuenta de paciente nueva empieza sin plan. Su nutrióloga se lo arma con
platillos del catálogo, que vive en Firestore. Para cargar el catálogo la
primera vez (o agregar platillos) se edita `app/tool/catalogo_platillos.json`
y se corre:

```bash
python3 app/tool/cargar_catalogo.py correo@ejemplo.com contraseña
```

## Estructura

```
app/lib/
  application/  controllers (estado con ChangeNotifier)
  core/         textos, formatos y utilidades
  data/         Firebase, Firestore y servicios
  domain/       modelos y reglas del plan
  theme/        colores, tipografía y medidas
  ui/           pantallas y componentes
app/test/
  fakes/        datos de ejemplo y repositorios en memoria, solo para pruebas
```

## Cómo correrla

1. En la consola de Firebase del proyecto, crea **Firestore Database** en
   modo de prueba.
2. Carga el catálogo de platillos (ver arriba).
3. Corre la app:

```bash
cd app
flutter pub get
flutter run
```

Probada en el simulador de iOS (iPhone 17 Pro).

## Estado

Entrega 2: la información viene de Firebase, el login guarda al usuario y su
token, hay CRUD de sesiones y de medidas, foto de perfil, recarga de listas
jalando hacia abajo, cuentas de paciente y nutrióloga, y el Factor WOW con QR.

Entrega 3: el nutriólogo arma el plan de comidas desde la app o la web con el
catálogo de Firestore, y los datos de ejemplo quedaron solo en las pruebas.

## Documentación de diseño

Los documentos de requerimientos, investigación técnica y diseño están en [docs/](docs/README.md).
