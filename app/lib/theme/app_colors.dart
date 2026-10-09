import 'package:flutter/material.dart';

/// Paleta de colores de NutriPlan, tomada de los mocks.
/// Hay dos versiones: clara y oscura. Cada pantalla pide la que toca
/// con AppColors.of(context), según el tema activo.
class AppColors {
  const AppColors({
    required this.background,
    required this.card,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.accentBackground,
    required this.beige,
    required this.track,
    required this.border,
    required this.green,
    required this.greenBackground,
    required this.inverse,
    required this.onInverse,
  });

  final Color background; // fondo de la pantalla
  final Color card; // fondo de las tarjetas
  final Color text; // texto principal
  final Color textMuted; // texto secundario
  final Color textFaint; // texto terciario (horas, etiquetas)
  final Color accent; // terracota para títulos pequeños
  final Color accentStrong; // terracota fuerte (barras destacadas)
  final Color accentSoft; // terracota claro (barras normales)
  final Color accentBackground; // fondo de la tarjeta de racha
  final Color beige; // barras y siluetas neutras
  final Color track; // fondo de las barras de progreso
  final Color border; // bordes de botones y separadores
  final Color green; // verde de "vas bien"
  final Color greenBackground; // fondo verde claro
  final Color inverse; // fondo oscuro (botón seleccionado, tarjeta "Siguiente comida")
  final Color onInverse; // texto encima de inverse

  static const AppColors light = AppColors(
    background: Color(0xFFF6F0EA),
    card: Color(0xFFFFFFFF),
    text: Color(0xFF2B2320),
    textMuted: Color(0xFF7A6F68),
    textFaint: Color(0xFFA99D94),
    accent: Color(0xFFA9452B),
    accentStrong: Color(0xFFD9653F),
    accentSoft: Color(0xFFF1D5C8),
    accentBackground: Color(0xFFF9EDE6),
    beige: Color(0xFFE6D8C9),
    track: Color(0xFFF2E7DF),
    border: Color(0xFFE7DACD),
    green: Color(0xFF5D6E45),
    greenBackground: Color(0xFFEDEFE5),
    inverse: Color(0xFF2B2320),
    onInverse: Color(0xFFFFFFFF),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF1C1816),
    card: Color(0xFF2A2421),
    text: Color(0xFFF3ECE6),
    textMuted: Color(0xFFB8ABA2),
    textFaint: Color(0xFF8A7E76),
    accent: Color(0xFFE58A6A),
    accentStrong: Color(0xFFE0714B),
    accentSoft: Color(0xFF5A3A2E),
    accentBackground: Color(0xFF3A2A23),
    beige: Color(0xFF4A3F38),
    track: Color(0xFF3A322D),
    border: Color(0xFF4A3F38),
    green: Color(0xFFA7BC86),
    greenBackground: Color(0xFF2F3527),
    inverse: Color(0xFFF3ECE6),
    onInverse: Color(0xFF1C1816),
  );

  /// Regresa la paleta que corresponde al tema actual (claro u oscuro).
  static AppColors of(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return dark;
    }
    return light;
  }
}
