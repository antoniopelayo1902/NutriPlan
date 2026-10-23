/// Copy for status, summary and navigation hints added in the UX pass.
class SFlow {
  const SFlow._();

  static const String loadingLabel = 'Cargando';
  static const String pickAnother = 'Elegir otra comida';
  static const String pickMealHint =
      'Elige una comida de hoy para ver equivalentes del mismo grupo.';
  static const String pickMealAllDoneTitle =
      'Ya completaste las comidas de hoy';
  static const String pickMealAllDoneBody = 'No quedan comidas por cambiar.';

  static String daySummary(String date, int done, int total) =>
      '$date · $done de $total ${total == 1 ? 'comida' : 'comidas'}';
}
