import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto de la app. Usamos google_fonts:
/// - Newsreader (serif) para títulos y números grandes.
/// - Work Sans para el texto normal.
/// - DM Mono para los contadores tipo "0 de 4".
class AppText {
  /// Título grande de cada pantalla ("Mi semana", "Hoy"...).
  static TextStyle title(AppColors c) =>
      GoogleFonts.newsreader(fontSize: 40, fontWeight: FontWeight.w500, color: c.text, height: 1.05);

  /// Texto pequeño en cursiva arriba del título ("Plan semanal").
  static TextStyle kicker(AppColors c, {Color? color}) =>
      GoogleFonts.newsreader(fontSize: 19, fontStyle: FontStyle.italic, color: color ?? c.accent);

  /// Etiqueta en cursiva dentro de una tarjeta ("Desayuno", "Porciones de hoy").
  static TextStyle cardLabel(AppColors c) =>
      GoogleFonts.newsreader(fontSize: 18, fontStyle: FontStyle.italic, color: c.textMuted);

  /// Texto principal de una tarjeta (nombre de un platillo).
  static TextStyle body(AppColors c, {double size = 17, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.workSans(fontSize: size, fontWeight: weight, color: c.text);

  /// Texto secundario (equivalentes, descripciones).
  static TextStyle muted(AppColors c, {double size = 15}) =>
      GoogleFonts.workSans(fontSize: size, color: c.textMuted, height: 1.4);

  /// Números grandes ("88%", "150").
  static TextStyle bigNumber(AppColors c, {double size = 64, Color? color}) =>
      GoogleFonts.newsreader(fontSize: size, fontWeight: FontWeight.w700, color: color ?? c.text, height: 1);

  /// Contadores alineados ("0 de 4").
  static TextStyle mono(AppColors c) => GoogleFonts.dmMono(fontSize: 14, color: c.textFaint);
}

/// Construye el ThemeData de la app a partir de una paleta.
/// La pantalla de Ajustes cambia entre el tema claro y el oscuro.
ThemeData buildTheme(Brightness brightness) {
  final AppColors c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: c.background,
    dividerColor: c.border,
    fontFamily: GoogleFonts.workSans().fontFamily,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.inverse,
      onPrimary: c.onInverse,
      secondary: c.accent,
      onSecondary: c.onInverse,
      error: c.accent,
      onError: c.onInverse,
      surface: c.card,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      // La barra de navegación usa estos colores para el ícono seleccionado.
      secondaryContainer: Colors.transparent,
      onSecondaryContainer: c.text,
    ),
  );
}
