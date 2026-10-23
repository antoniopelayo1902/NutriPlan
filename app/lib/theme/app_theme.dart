import 'package:flutter/material.dart';

import 'primitives.dart';
import 'tokens.dart';

/// Reads [AppTokens] from the nearest [Theme].
AppTokens tokensOf(BuildContext context) {
  final AppTokens? t = Theme.of(context).extension<AppTokens>();
  assert(t != null, 'AppTokens missing from ThemeData.extensions');
  return t ?? AppTokens.base();
}

/// Builds the light theme for the given runtime [accent].
ThemeData buildTheme({Color accent = Prim.terracotta500}) {
  final AppTokens tokens = AppTokens.withAccent(accent);
  final SemanticColors c = tokens.colors;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppType.uiFamily,
    scaffoldBackgroundColor: c.transparent,
    canvasColor: c.bgSurface,
    splashFactory: NoSplash.splashFactory,
    highlightColor: c.transparent,
    colorScheme: ColorScheme.light(
      primary: c.accent,
      onPrimary: c.textInverse,
      surface: c.bgSurface,
      onSurface: c.textPrimary,
      error: c.dangerFg,
    ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
