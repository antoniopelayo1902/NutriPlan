import 'package:flutter/material.dart';

import 'primitives.dart';
import 'semantic_colors.dart';
import 'semantic_colors_lerp.dart';

export 'semantic_aliases.dart';
export 'semantic_colors.dart';

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
  final double fitBar = 6;
  final double mealStrip = 4;
  final double streakDisc = 56;
  final double decoCircleLg = 96;
  final double decoCircleSm = 48;
  final double decoOffset = 24;
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
    return copyWith(colors: lerpSemanticColors(colors, other.colors, t));
  }
}
