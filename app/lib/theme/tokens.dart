import 'package:flutter/material.dart';

import 'accent.dart';
import 'primitives.dart';

/// Semantic colors (purpose-named). Components read only these.
@immutable
class SemanticColors {
  const SemanticColors({
    required this.bgAppGradient,
    required this.bgSurface,
    required this.bgSurfaceSubtle,
    required this.bgInverse,
    required this.bgTrack,
    required this.bgEmpty,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.textInverse,
    required this.textAccent,
    required this.borderDefault,
    required this.borderStrong,
    required this.divider,
    required this.accent,
    required this.accentSoft,
    required this.accentMuted,
    required this.successBg,
    required this.successFg,
    required this.warningBg,
    required this.warningFg,
    required this.dangerBg,
    required this.dangerFg,
    required this.infoBg,
    required this.infoFg,
    required this.dayComplete,
    required this.dayPartial,
    required this.dayPending,
    required this.pressOverlay,
    required this.glass,
    required this.transparent,
  });

  /// Default (terracotta) palette.
  factory SemanticColors.base() => const SemanticColors(
    bgAppGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Prim.sand50, Prim.sand100, Prim.sand150],
    ),
    bgSurface: Prim.sand0,
    bgSurfaceSubtle: Prim.sand25,
    bgInverse: Prim.sand900,
    bgTrack: Prim.sand200,
    bgEmpty: Prim.sand300,
    textPrimary: Prim.sand900,
    textSecondary: Prim.sand850,
    textMuted: Prim.sand800,
    textFaint: Prim.sand600,
    textInverse: Prim.sand0,
    textAccent: Prim.terracotta700,
    borderDefault: Prim.sand400,
    borderStrong: Prim.sand500,
    divider: Prim.sand200,
    accent: Prim.terracotta500,
    accentSoft: Prim.terracotta100,
    accentMuted: Prim.terracotta300,
    successBg: Prim.olive150,
    successFg: Prim.olive900,
    warningBg: Prim.amber100,
    warningFg: Prim.amber700,
    dangerBg: Prim.brick100,
    dangerFg: Prim.brick700,
    infoBg: Prim.olive100,
    infoFg: Prim.olive800,
    dayComplete: Prim.olive500,
    dayPartial: Prim.amber500,
    dayPending: Prim.sand500,
    pressOverlay: Prim.pressOverlay,
    glass: Prim.glass85,
    transparent: Prim.transparent,
  );

  final LinearGradient bgAppGradient;
  final Color bgSurface;
  final Color bgSurfaceSubtle;
  final Color bgInverse;
  final Color bgTrack;
  final Color bgEmpty;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color textInverse;
  final Color textAccent;
  final Color borderDefault;
  final Color borderStrong;
  final Color divider;
  final Color accent;
  final Color accentSoft;
  final Color accentMuted;
  final Color successBg;
  final Color successFg;
  final Color warningBg;
  final Color warningFg;
  final Color dangerBg;
  final Color dangerFg;
  final Color infoBg;
  final Color infoFg;
  final Color dayComplete;
  final Color dayPartial;
  final Color dayPending;
  final Color pressOverlay;
  final Color glass;
  final Color transparent;

  // Fit tokens alias the status tokens (spec 1.2).
  Color get fitYesBg => successBg;
  Color get fitYesFg => successFg;
  Color get fitAdjustBg => warningBg;
  Color get fitAdjustFg => warningFg;
  Color get fitNoBg => dangerBg;
  Color get fitNoFg => dangerFg;

  /// Re-derives the accent family from [accent]. The default terracotta keeps
  /// the exact palette values from the spec.
  SemanticColors withAccent(Color accent) {
    if (accent == Prim.terracotta500) return SemanticColors.base();
    return copyWith(
      accent: accent,
      accentSoft: Color.lerp(accent, bgSurface, 0.9),
      accentMuted: Color.lerp(accent, bgSurface, 0.6),
      textAccent: deriveTextAccent(accent, bgSurface),
    );
  }

  SemanticColors copyWith({
    LinearGradient? bgAppGradient,
    Color? bgSurface,
    Color? bgSurfaceSubtle,
    Color? bgInverse,
    Color? bgTrack,
    Color? bgEmpty,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textFaint,
    Color? textInverse,
    Color? textAccent,
    Color? borderDefault,
    Color? borderStrong,
    Color? divider,
    Color? accent,
    Color? accentSoft,
    Color? accentMuted,
    Color? successBg,
    Color? successFg,
    Color? warningBg,
    Color? warningFg,
    Color? dangerBg,
    Color? dangerFg,
    Color? infoBg,
    Color? infoFg,
    Color? dayComplete,
    Color? dayPartial,
    Color? dayPending,
    Color? pressOverlay,
    Color? glass,
    Color? transparent,
  }) {
    return SemanticColors(
      bgAppGradient: bgAppGradient ?? this.bgAppGradient,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurfaceSubtle: bgSurfaceSubtle ?? this.bgSurfaceSubtle,
      bgInverse: bgInverse ?? this.bgInverse,
      bgTrack: bgTrack ?? this.bgTrack,
      bgEmpty: bgEmpty ?? this.bgEmpty,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textFaint: textFaint ?? this.textFaint,
      textInverse: textInverse ?? this.textInverse,
      textAccent: textAccent ?? this.textAccent,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentMuted: accentMuted ?? this.accentMuted,
      successBg: successBg ?? this.successBg,
      successFg: successFg ?? this.successFg,
      warningBg: warningBg ?? this.warningBg,
      warningFg: warningFg ?? this.warningFg,
      dangerBg: dangerBg ?? this.dangerBg,
      dangerFg: dangerFg ?? this.dangerFg,
      infoBg: infoBg ?? this.infoBg,
      infoFg: infoFg ?? this.infoFg,
      dayComplete: dayComplete ?? this.dayComplete,
      dayPartial: dayPartial ?? this.dayPartial,
      dayPending: dayPending ?? this.dayPending,
      pressOverlay: pressOverlay ?? this.pressOverlay,
      glass: glass ?? this.glass,
      transparent: transparent ?? this.transparent,
    );
  }

  static SemanticColors lerp(SemanticColors a, SemanticColors b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t) ?? y;
    return SemanticColors(
      bgAppGradient:
          LinearGradient.lerp(a.bgAppGradient, b.bgAppGradient, t) ??
          b.bgAppGradient,
      bgSurface: l(a.bgSurface, b.bgSurface),
      bgSurfaceSubtle: l(a.bgSurfaceSubtle, b.bgSurfaceSubtle),
      bgInverse: l(a.bgInverse, b.bgInverse),
      bgTrack: l(a.bgTrack, b.bgTrack),
      bgEmpty: l(a.bgEmpty, b.bgEmpty),
      textPrimary: l(a.textPrimary, b.textPrimary),
      textSecondary: l(a.textSecondary, b.textSecondary),
      textMuted: l(a.textMuted, b.textMuted),
      textFaint: l(a.textFaint, b.textFaint),
      textInverse: l(a.textInverse, b.textInverse),
      textAccent: l(a.textAccent, b.textAccent),
      borderDefault: l(a.borderDefault, b.borderDefault),
      borderStrong: l(a.borderStrong, b.borderStrong),
      divider: l(a.divider, b.divider),
      accent: l(a.accent, b.accent),
      accentSoft: l(a.accentSoft, b.accentSoft),
      accentMuted: l(a.accentMuted, b.accentMuted),
      successBg: l(a.successBg, b.successBg),
      successFg: l(a.successFg, b.successFg),
      warningBg: l(a.warningBg, b.warningBg),
      warningFg: l(a.warningFg, b.warningFg),
      dangerBg: l(a.dangerBg, b.dangerBg),
      dangerFg: l(a.dangerFg, b.dangerFg),
      infoBg: l(a.infoBg, b.infoBg),
      infoFg: l(a.infoFg, b.infoFg),
      dayComplete: l(a.dayComplete, b.dayComplete),
      dayPartial: l(a.dayPartial, b.dayPartial),
      dayPending: l(a.dayPending, b.dayPending),
      pressOverlay: l(a.pressOverlay, b.pressOverlay),
      glass: l(a.glass, b.glass),
      transparent: l(a.transparent, b.transparent),
    );
  }
}

/// 4-pt spacing scale (spec 1.4).
@immutable
class AppSpace {
  const AppSpace();
  final double s0 = 0;
  final double s1 = 4;
  final double s2 = 8;
  final double s3 = 12;
  final double s4 = 16;
  final double s5 = 20;
  final double s6 = 24;
  final double s7 = 32;
  final double s8 = 40;
  final double s10 = 56;
  final double s12 = 104;
}

/// Radius scale (spec 1.5).
@immutable
class AppRadius {
  const AppRadius();
  final double sm = 8;
  final double md = 16;
  final double lg = 20;
  final double xl = 24;
  final double xl2 = 26;
  final double pill = 999;

  /// Chart bars: 10 10 5 5.
  BorderRadius get bar => const BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(10),
    bottomLeft: Radius.circular(5),
    bottomRight: Radius.circular(5),
  );
}

/// Warm elevation (spec 1.6). The inset highlight of `shadow-float` is
/// approximated with a border in the tab bar because Flutter has no inset
/// shadows.
@immutable
class AppShadows {
  const AppShadows();

  List<BoxShadow> get card => const <BoxShadow>[
    BoxShadow(color: Prim.shadowInk05, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Prim.shadowInk22,
      offset: Offset(0, 12),
      blurRadius: 28,
      spreadRadius: -16,
    ),
  ];

  List<BoxShadow> get item => const <BoxShadow>[
    BoxShadow(color: Prim.shadowInk05, offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(
      color: Prim.shadowInk20,
      offset: Offset(0, 9),
      blurRadius: 22,
      spreadRadius: -15,
    ),
  ];

  List<BoxShadow> get hover => const <BoxShadow>[
    BoxShadow(color: Prim.shadowInk06, offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(
      color: Prim.shadowInk30,
      offset: Offset(0, 14),
      blurRadius: 28,
      spreadRadius: -16,
    ),
  ];

  List<BoxShadow> get float => const <BoxShadow>[
    BoxShadow(
      color: Prim.shadowInk30,
      offset: Offset(0, 10),
      blurRadius: 30,
      spreadRadius: -10,
    ),
  ];

  /// Highlight color for the top edge of floating surfaces.
  Color get floatHighlight => Prim.highlight70;
}

/// Motion (spec 1.7).
@immutable
class AppMotion {
  const AppMotion();
  final Duration fast = const Duration(milliseconds: 120);
  final Duration base = const Duration(milliseconds: 220);
  final Duration slow = const Duration(milliseconds: 360);
  final Curve easeOut = const Cubic(0.2, 0.8, 0.2, 1);

  /// Skeleton pulse period.
  final Duration pulse = const Duration(milliseconds: 1200);
}

/// Sizing (spec 1.8) plus component-level dimensions.
@immutable
class AppSizing {
  const AppSizing();
  final double hitMin = 48;
  final double iconSm = 16;
  final double iconMd = 20;
  final double avatarMd = 38;
  final double stepperBtn = 32;
  final double buttonMd = 48;
  final double buttonLg = 48;
  final double chipSm = 38;
  final double chipMd = 48;
  final double iconButtonSm = 32;
  final double iconButtonMd = 48;
  final double tabBarHeight = 56;
  final double tabBarBottom = 12;
  final double tabBarInset = 14;
  final double tabBlur = 16;
  final double focusRingWidth = 2;
  final double focusRingOffset = 2;
  final double chartHeight = 120;
  final double barStub = 6;
  final double dot = 8;
  final double dotLg = 10;
  final double progressBar = 8;
  final double borderWidth = 1;
  final double spinner = 18;
  final double spinnerStroke = 2;
  final double dayPickerHeight = 72;
  final double bodyMapAspect = 1.1;
  final double bodyMapLabelHeight = 40;
  final double bodyMapLineWidth = 1;
  final double toastMaxWidth = 360;
  final double disabledOpacity = 0.45;
  final double pressedScale = 0.98;
  final double pulseLow = 0.45;
  final double skeletonCard = 148;
  final double skeletonLine = 14;
  final double metricRowMin = 120;
  final double tabMaxTextScale = 1.3;
}

/// Type ramp (spec 1.3). Letter spacing is em * size, height is the
/// line-height multiplier.
@immutable
class AppType {
  AppType()
    : displayXl = _display(700, 52, 0.9, -0.04),
      displayLg = _display(700, 48, 0.9, -0.04),
      titleLg = _display(500, 33, 1.05, -0.02),
      titleMd = _display(500, 30, 1.05, -0.02),
      metricMd = _display(700, 28, 1, 0),
      metricSm = _display(700, 21, 1.1, 0),
      metricXs = _display(700, 17, 1, 0),
      eyebrow = _display(400, 14.5, 1, 0, italic: true),
      bodyLg = _ui(500, 16.5, 1.35, -0.01),
      bodyMd = _ui(400, 14, 1.5, 0),
      bodySm = _ui(400, 12.5, 1.5, 0),
      caption = _ui(400, 11.5, 1.4, 0),
      label = _ui(600, 13, 1, 0),
      micro = _ui(500, 10.5, 1, 0);

  static const String displayFamily = 'Newsreader';
  static const String uiFamily = 'WorkSans';

  final TextStyle displayXl;
  final TextStyle displayLg;
  final TextStyle titleLg;
  final TextStyle titleMd;
  final TextStyle metricMd;
  final TextStyle metricSm;
  final TextStyle metricXs;
  final TextStyle eyebrow;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodySm;
  final TextStyle caption;
  final TextStyle label;
  final TextStyle micro;

  String get uiFontFamily => uiFamily;

  static FontWeight _weight(int w) =>
      FontWeight.values[(w ~/ 100 - 1).clamp(0, 8)];

  static TextStyle _display(
    int weight,
    double size,
    double height,
    double em, {
    bool italic = false,
  }) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      fontWeight: _weight(weight),
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      letterSpacing: em * size,
      fontVariations: <FontVariation>[
        FontVariation.weight(weight.toDouble()),
        FontVariation.opticalSize(size.clamp(6.0, 72.0)),
      ],
    );
  }

  static TextStyle _ui(int weight, double size, double height, double em) {
    return TextStyle(
      fontFamily: uiFamily,
      fontSize: size,
      fontWeight: _weight(weight),
      height: height,
      letterSpacing: em * size,
      fontVariations: <FontVariation>[FontVariation.weight(weight.toDouble())],
    );
  }
}

/// The single token bundle exposed through [ThemeData.extensions].
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  AppTokens({
    required this.colors,
    this.space = const AppSpace(),
    this.radius = const AppRadius(),
    this.shadow = const AppShadows(),
    this.motion = const AppMotion(),
    this.size = const AppSizing(),
    AppType? typo,
  }) : typo = typo ?? AppType();

  factory AppTokens.base() => AppTokens(colors: SemanticColors.base());

  /// Tokens for a runtime [accent].
  factory AppTokens.withAccent(Color accent) =>
      AppTokens(colors: SemanticColors.base().withAccent(accent));

  final SemanticColors colors;
  final AppSpace space;
  final AppRadius radius;
  final AppShadows shadow;
  final AppMotion motion;
  final AppSizing size;
  final AppType typo;

  /// Same tokens with a different accent family.
  AppTokens accentTo(Color accent) =>
      copyWith(colors: colors.withAccent(accent));

  @override
  AppTokens copyWith({
    SemanticColors? colors,
    AppSpace? space,
    AppRadius? radius,
    AppShadows? shadow,
    AppMotion? motion,
    AppSizing? size,
    AppType? typo,
  }) {
    return AppTokens(
      colors: colors ?? this.colors,
      space: space ?? this.space,
      radius: radius ?? this.radius,
      shadow: shadow ?? this.shadow,
      motion: motion ?? this.motion,
      size: size ?? this.size,
      typo: typo ?? this.typo,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return copyWith(colors: SemanticColors.lerp(colors, other.colors, t));
  }
}
