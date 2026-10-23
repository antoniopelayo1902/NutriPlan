import 'package:flutter/painting.dart';

/// WCAG contrast ratio between two opaque colors (1.0 to 21.0).
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Text-safe version of [accent] for small text on [surface].
///
/// Darkens the accent by 24% in HSL lightness, then keeps darkening in 2%
/// lightness steps until the contrast against [surface] is at least [minRatio]
/// (or the color is black).
Color deriveTextAccent(Color accent, Color surface, {double minRatio = 4.5}) {
  final HSLColor hsl = HSLColor.fromColor(accent);
  double lightness = hsl.lightness * (1 - 0.24);
  Color candidate = hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  while (contrastRatio(candidate, surface) < minRatio && lightness > 0) {
    lightness = (lightness - 0.02).clamp(0.0, 1.0);
    candidate = hsl.withLightness(lightness).toColor();
  }
  return candidate;
}
