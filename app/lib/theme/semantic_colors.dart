import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'accent.dart';
import 'fit_palette.dart';
import 'food_palette.dart';
import 'huerta_colors.dart';
import 'primitives.dart';

/// Semantic colors (purpose-named). Components read only these.
///
/// Aliases for older names (bgInverse, textInverse, success*, info*, fit* and
/// food* getters) live in `semantic_aliases.dart`.
@immutable
class SemanticColors {
  const SemanticColors({
    required this.bgApp,
    required this.bgSurface,
    required this.bgSurfaceSubtle,
    required this.bgTrack,
    required this.bgEmpty,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.primaryInk,
    required this.textAccent,
    required this.borderDefault,
    required this.borderStrong,
    required this.divider,
    required this.primary,
    required this.accent,
    required this.accentSoft,
    required this.accentMuted,
    required this.secondary,
    required this.secondarySoft,
    required this.secondaryInk,
    required this.highlight,
    required this.highlightSoft,
    required this.highlightInk,
    required this.message,
    required this.messageSoft,
    required this.messageInk,
    required this.dayComplete,
    required this.dayPartial,
    required this.dayPending,
    required this.pressOverlay,
    required this.glass,
    required this.transparent,
    required this.fit,
    required this.food,
  });

  /// Default Huerta palette.
  factory SemanticColors.base() => huertaColors;

  final Color bgApp;
  final Color bgSurface;
  final Color bgSurfaceSubtle;
  final Color bgTrack;
  final Color bgEmpty;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color primaryInk;
  final Color textAccent;
  final Color borderDefault;
  final Color borderStrong;
  final Color divider;
  final Color primary;
  final Color accent;
  final Color accentSoft;
  final Color accentMuted;
  final Color secondary;
  final Color secondarySoft;
  final Color secondaryInk;
  final Color highlight;
  final Color highlightSoft;
  final Color highlightInk;
  final Color message;
  final Color messageSoft;
  final Color messageInk;
  final Color dayComplete;
  final Color dayPartial;
  final Color dayPending;
  final Color pressOverlay;
  final Color glass;
  final Color transparent;
  final FitPalette fit;
  final FoodPalette food;

  /// Re-derives the accent family from [accent]. The default terracotta keeps
  /// the exact palette values from the tokens.
  SemanticColors withAccent(Color accent) {
    if (accent == Hue.accent500) return huertaColors;
    return SemanticColors(
      bgApp: bgApp,
      bgSurface: bgSurface,
      bgSurfaceSubtle: bgSurfaceSubtle,
      bgTrack: bgTrack,
      bgEmpty: bgEmpty,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textMuted: textMuted,
      textFaint: textFaint,
      primaryInk: primaryInk,
      textAccent: deriveTextAccent(accent, bgSurface),
      borderDefault: borderDefault,
      borderStrong: borderStrong,
      divider: divider,
      primary: primary,
      accent: accent,
      accentSoft: Color.lerp(accent, bgSurface, 0.9) ?? accentSoft,
      accentMuted: Color.lerp(accent, bgSurface, 0.6) ?? accentMuted,
      secondary: secondary,
      secondarySoft: secondarySoft,
      secondaryInk: secondaryInk,
      highlight: highlight,
      highlightSoft: highlightSoft,
      highlightInk: highlightInk,
      message: message,
      messageSoft: messageSoft,
      messageInk: messageInk,
      dayComplete: dayComplete,
      dayPartial: dayPartial,
      dayPending: dayPending,
      pressOverlay: pressOverlay,
      glass: glass,
      transparent: transparent,
      fit: fit,
      food: food,
    );
  }
}
