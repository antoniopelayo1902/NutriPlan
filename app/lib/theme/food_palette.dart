import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'primitives.dart';

/// One food group's colors: [solid] for dots, bars and strips, [soft] for pill
/// and track backgrounds, [ink] for text on [soft].
@immutable
class FoodTone {
  const FoodTone({required this.solid, required this.soft, required this.ink});

  final Color solid;
  final Color soft;
  final Color ink;

  static FoodTone lerp(FoodTone a, FoodTone b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t) ?? y;
    return FoodTone(
      solid: l(a.solid, b.solid),
      soft: l(a.soft, b.soft),
      ink: l(a.ink, b.ink),
    );
  }
}

/// The seven food-group tones (tokens.json food-*).
@immutable
class FoodPalette {
  const FoodPalette({
    required this.verdura,
    required this.fruta,
    required this.cereal,
    required this.aoa,
    required this.leguminosa,
    required this.leche,
    required this.grasa,
  });

  static const FoodPalette base = FoodPalette(
    verdura: FoodTone(
      solid: FoodHue.verdura500,
      soft: Prim.foodVerduraSoft,
      ink: FoodHue.verdura800,
    ),
    fruta: FoodTone(
      solid: FoodHue.fruta500,
      soft: Prim.foodFrutaSoft,
      ink: FoodHue.fruta800,
    ),
    cereal: FoodTone(
      solid: FoodHue.cereal500,
      soft: Prim.foodCerealSoft,
      ink: FoodHue.cereal800,
    ),
    aoa: FoodTone(
      solid: FoodHue.aoa500,
      soft: Prim.foodAoaSoft,
      ink: FoodHue.aoa800,
    ),
    leguminosa: FoodTone(
      solid: FoodHue.leguminosa500,
      soft: Prim.foodLeguminosaSoft,
      ink: FoodHue.leguminosa800,
    ),
    leche: FoodTone(
      solid: FoodHue.leche500,
      soft: Prim.foodLecheSoft,
      ink: FoodHue.leche800,
    ),
    grasa: FoodTone(
      solid: FoodHue.grasa500,
      soft: Prim.foodGrasaSoft,
      ink: FoodHue.grasa800,
    ),
  );

  final FoodTone verdura;
  final FoodTone fruta;
  final FoodTone cereal;
  final FoodTone aoa;
  final FoodTone leguminosa;
  final FoodTone leche;
  final FoodTone grasa;

  static FoodPalette lerp(FoodPalette a, FoodPalette b, double t) {
    FoodTone l(FoodTone x, FoodTone y) => FoodTone.lerp(x, y, t);
    return FoodPalette(
      verdura: l(a.verdura, b.verdura),
      fruta: l(a.fruta, b.fruta),
      cereal: l(a.cereal, b.cereal),
      aoa: l(a.aoa, b.aoa),
      leguminosa: l(a.leguminosa, b.leguminosa),
      leche: l(a.leche, b.leche),
      grasa: l(a.grasa, b.grasa),
    );
  }
}
