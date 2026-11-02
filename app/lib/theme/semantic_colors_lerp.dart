import 'package:flutter/painting.dart';

import 'fit_palette.dart';
import 'food_palette.dart';
import 'semantic_colors.dart';

/// Linear interpolation between two palettes (theme transitions).
SemanticColors lerpSemanticColors(
  SemanticColors a,
  SemanticColors b,
  double t,
) {
  Color l(Color x, Color y) => Color.lerp(x, y, t) ?? y;
  return SemanticColors(
    bgApp: l(a.bgApp, b.bgApp),
    bgSurface: l(a.bgSurface, b.bgSurface),
    bgSurfaceSubtle: l(a.bgSurfaceSubtle, b.bgSurfaceSubtle),
    bgTrack: l(a.bgTrack, b.bgTrack),
    bgEmpty: l(a.bgEmpty, b.bgEmpty),
    textPrimary: l(a.textPrimary, b.textPrimary),
    textSecondary: l(a.textSecondary, b.textSecondary),
    textMuted: l(a.textMuted, b.textMuted),
    textFaint: l(a.textFaint, b.textFaint),
    primaryInk: l(a.primaryInk, b.primaryInk),
    textAccent: l(a.textAccent, b.textAccent),
    borderDefault: l(a.borderDefault, b.borderDefault),
    borderStrong: l(a.borderStrong, b.borderStrong),
    divider: l(a.divider, b.divider),
    primary: l(a.primary, b.primary),
    accent: l(a.accent, b.accent),
    accentSoft: l(a.accentSoft, b.accentSoft),
    accentMuted: l(a.accentMuted, b.accentMuted),
    secondary: l(a.secondary, b.secondary),
    secondarySoft: l(a.secondarySoft, b.secondarySoft),
    secondaryInk: l(a.secondaryInk, b.secondaryInk),
    highlight: l(a.highlight, b.highlight),
    highlightSoft: l(a.highlightSoft, b.highlightSoft),
    highlightInk: l(a.highlightInk, b.highlightInk),
    message: l(a.message, b.message),
    messageSoft: l(a.messageSoft, b.messageSoft),
    messageInk: l(a.messageInk, b.messageInk),
    dayComplete: l(a.dayComplete, b.dayComplete),
    dayPartial: l(a.dayPartial, b.dayPartial),
    dayPending: l(a.dayPending, b.dayPending),
    pressOverlay: l(a.pressOverlay, b.pressOverlay),
    glass: l(a.glass, b.glass),
    transparent: l(a.transparent, b.transparent),
    fit: FitPalette.lerp(a.fit, b.fit, t),
    food: FoodPalette.lerp(a.food, b.food, t),
  );
}
