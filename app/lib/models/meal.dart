/// Una comida del plan: "Desayuno 8:00 - Tostadas de aguacate y huevo".
class Meal {
  const Meal({
    required this.id,
    required this.mealTime,
    required this.hour,
    required this.name,
    required this.portions,
  });

  final String id; // identificador del tiempo de comida (desayuno, colacion...)
  final String mealTime; // nombre visible: "Desayuno"
  final String hour; // hora sugerida: "8:00"
  final String name; // platillo: "Tostadas de aguacate y huevo"

  /// Equivalentes que cubre el platillo, por grupo.
  /// Ejemplo: {'Cereal': 1, 'Grasa': 1, 'AOA': 1}
  final Map<String, int> portions;

  /// Texto corto para mostrar: "1 Cereal · 1 Grasa · 1 AOA".
  String get portionsText {
    final List<String> parts = [];
    portions.forEach((group, amount) {
      parts.add('$amount $group');
    });
    return parts.join(' · ');
  }
}
