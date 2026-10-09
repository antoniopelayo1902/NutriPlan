import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón redondo en forma de píldora, el que se repite en todos los mocks.
/// Es un ElevatedButton con estilo propio:
/// - selected: fondo oscuro y texto blanco ("Esta semana", "Publicar plan").
/// - accent: borde y texto terracota ("Cambiar").
/// - normal: fondo blanco con borde beige ("Marcar").
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.accent = false,
    this.success = false,
    this.height = 54,
    this.fontSize = 16,
    this.horizontalPadding = 18,
    this.fontWeight = FontWeight.w700,
  });

  final String label;
  final VoidCallback onPressed;
  final bool selected;
  final bool accent;
  final bool success; // verde: la comida ya se marcó
  final double height;
  final double fontSize;
  final double horizontalPadding;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    Color background = c.card;
    Color foreground = c.text;
    Color border = c.border;

    if (selected) {
      background = c.inverse;
      foreground = c.onInverse;
      border = c.inverse;
    } else if (success) {
      background = c.greenBackground;
      foreground = c.green;
      border = c.green;
    } else if (accent) {
      foreground = c.accent;
      border = c.accent;
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: StadiumBorder(side: BorderSide(color: border, width: 1.3)),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
