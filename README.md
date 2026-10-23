# NutriPlan

App móvil en Flutter para llevar un plan de alimentación por equivalentes. La
nutrióloga arma el plan de su paciente y lo comparte con un código QR. El
paciente lo importa y ve qué le toca comer cada día, marca lo que ya comió,
cambia platillos por otros equivalentes y sigue su progreso.

Proyecto para la materia de Desarrollo de Aplicaciones Móviles, ITESO.

## Autores

- Andrés Gómez Tagle Azcárraga
- Eduardo Antonio Pelayo Carrillo

## Qué hace la app

Al iniciar sesión eliges si entras como paciente o como nutrióloga.

**Paciente** (barra de navegación inferior con 5 secciones):

- **Semana:** las comidas de cada día. Puedes cambiar de día y marcar lo que ya comiste.
- **Hoy:** cuántas porciones llevas de cada grupo de alimentos.
- **Cambiar:** cambia un platillo por otro con los mismos equivalentes.
- **Actividad:** registro de ejercicio con los minutos de la semana.
- **Progreso:** evolución por semana y mes con mes, con filtros por peso, % de grasa y masa muscular.

Desde el menú lateral se entra a Mi perfil, Ajustes (con modo oscuro), Importar plan y Cerrar sesión.

**Nutrióloga:**

- Lista de pacientes.
- Medidas, IMC e historial de cada paciente.
- Ajuste de porciones por grupo, con las calorías recalculadas al momento.
- Publicar el plan como código QR o como texto para copiar.

## Paquetes

| Paquete | Para qué se usa |
|---|---|
| `provider` | Modo oscuro y estado del plan compartido entre pantallas |
| `google_fonts` | Tipografías |
| `qr_flutter` | Generar el QR del plan |
| `flutter_launcher_icons` | Ícono de la app |

## Estructura

```
app/lib/
  data/       datos de ejemplo
  models/     clases de datos
  providers/  estado de la app
  screens/    pantallas
  theme/      colores y estilos de texto
  widgets/    componentes reutilizables
```

## Cómo correrla

```bash
cd app
flutter pub get
flutter run
```

Probada en el simulador de iOS (iPhone 17 Pro).

## Estado

Entrega 1: pantallas y navegación completas, con datos de ejemplo. Los botones
que todavía no tienen funcionalidad muestran un aviso de lo que harán.

## Documentación de diseño

Los documentos de requerimientos, investigación técnica y diseño están en [docs/](docs/README.md).
