/// Una sesión de actividad física registrada: "Caminata, lunes, 35 min".
class ActivityEntry {
  const ActivityEntry({
    required this.type,
    required this.day,
    required this.dayIndex,
    required this.minutes,
    required this.kcal,
  });

  final String type; // "Caminata", "Fuerza"...
  final String day; // día corto visible: "Lun"
  final int dayIndex; // 0 = lunes ... 6 = domingo (para la gráfica)
  final int minutes;
  final int kcal;
}

/// Una opción de "Registrar en un toque": tipo + duración típica.
class QuickActivity {
  const QuickActivity({required this.type, required this.minutes, required this.kcalPerMinute});

  final String type;
  final int minutes;
  final int kcalPerMinute;
}
