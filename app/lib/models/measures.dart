/// Una serie de mediciones mes con mes (peso, % de grasa...).
class MeasureSeries {
  const MeasureSeries({required this.name, required this.unit, required this.months, required this.values});

  final String name; // "Peso"
  final String unit; // "kg"
  final List<String> months; // ["Jun", "Jul", "Ago", "Sep"]
  final List<double> values; // [74.8, 73.4, 72.1, 71.2]

  double get latest => values.last;
  double get changeSinceStart => values.last - values.first;
}

/// Un punto de medición sobre la silueta del cuerpo ("Cintura 84,0 cm").
class BodyPoint {
  const BodyPoint({
    required this.label,
    required this.value,
    required this.left,
    required this.top,
    required this.labelOnLeft,
  });

  final String label;
  final String value;
  final double left; // posición del punto dentro de la silueta
  final double top;
  final bool labelOnLeft; // si la etiqueta va del lado izquierdo
}

/// Un paciente del nutriólogo.
class Patient {
  const Patient({
    required this.name,
    required this.initials,
    required this.age,
    required this.followUp,
    required this.visit,
    required this.measures,
  });

  final String name;
  final String initials;
  final int age;
  final String followUp; // "seguimiento mensual"
  final String visit; // "3.ª consulta"

  /// Filas de la pestaña "Medidas": etiqueta -> valor ("" = por llenar).
  final Map<String, String> measures;
}
