import 'fit_palette.dart';
import 'food_palette.dart';
import 'primitives.dart';
import 'semantic_colors.dart';

/// The Huerta palette: deep green primary, terracotta accent, saffron
/// highlight, plum messages (tokens.json color.semantic).
const SemanticColors huertaColors = SemanticColors(
  bgApp: Prim.canvas,
  bgSurface: Prim.sand0,
  bgSurfaceSubtle: Prim.sand25,
  bgTrack: Prim.sand200,
  bgEmpty: Prim.sand450,
  textPrimary: Prim.sand900,
  textSecondary: Prim.sand850,
  textMuted: Prim.sand800,
  textFaint: Prim.sand600,
  primaryInk: Prim.inkOnDeep,
  textAccent: Prim.accentInk,
  borderDefault: Prim.sand400,
  borderStrong: Prim.sand500,
  divider: Prim.sand350,
  primary: Hue.deep500,
  accent: Hue.accent500,
  accentSoft: Prim.accentSoft,
  accentMuted: Prim.accentMuted,
  secondary: Hue.sec500,
  secondarySoft: Prim.secondarySoft,
  secondaryInk: Hue.sec700,
  highlight: Hue.pop500,
  highlightSoft: Prim.highlightSoft,
  highlightInk: Hue.pop800,
  message: Hue.plum500,
  messageSoft: Prim.messageSoft,
  messageInk: Hue.plum700,
  dayComplete: Hue.sec500,
  dayPartial: Hue.pop500,
  dayPending: Prim.sand500,
  pressOverlay: Prim.pressOverlay,
  glass: Prim.glass85,
  transparent: Prim.transparent,
  fit: FitPalette.base,
  food: FoodPalette.base,
);
