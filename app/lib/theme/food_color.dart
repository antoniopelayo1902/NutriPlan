import '../domain/models/food_group.dart';
import 'food_palette.dart';
import 'semantic_colors.dart';

/// Maps a [FoodGroup] to its tone.
///
/// The seven budgeted groups map one to one. `azucar` (not budgeted, no token
/// of its own) borrows the cereal tone, the carbohydrate family.
FoodTone foodColor(SemanticColors c, FoodGroup group) {
  final FoodPalette p = c.food;
  switch (group) {
    case FoodGroup.verdura:
      return p.verdura;
    case FoodGroup.fruta:
      return p.fruta;
    case FoodGroup.cereal:
    case FoodGroup.azucar:
      return p.cereal;
    case FoodGroup.aoa:
      return p.aoa;
    case FoodGroup.leguminosa:
      return p.leguminosa;
    case FoodGroup.leche:
      return p.leche;
    case FoodGroup.grasa:
      return p.grasa;
  }
}
