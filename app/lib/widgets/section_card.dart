import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tarjeta blanca con esquinas muy redondeadas y una sombra suave.
/// Es un Card. Usamos Card y no un Container porque los
/// ListTile que van adentro necesitan una superficie Material para dibujar
/// el efecto al tocarlos.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(22),
    this.margin = const EdgeInsets.only(bottom: 18),
    this.shadow = true,
  });

  final Widget child;
  final Color? color; // null = color de tarjeta del tema
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Card(
      margin: margin,
      color: color ?? c.card,
      elevation: shadow ? 6 : 0,
      shadowColor: c.text.withValues(alpha: 0.18),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: padding,
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
