/// Un grupo de alimentos del sistema de equivalentes.
/// Ejemplo: "Cereales y tubérculos", 70 kcal por equivalente.
class FoodGroup {
  const FoodGroup({required this.key, required this.name, required this.kcalPerPortion});

  final String key; // nombre corto que usan las comidas: "Cereal"
  final String name; // nombre largo: "Cereales y tubérculos"
  final int kcalPerPortion; // kcal promedio de un equivalente
}
