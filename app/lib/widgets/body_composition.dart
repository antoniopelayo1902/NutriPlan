import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/measures.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'section_card.dart';

/// Tarjeta "Composición corporal": resumen arriba y una silueta con los
/// puntos de medición. La silueta se arma con Stack + Positioned +
/// Containers redondeados.
class BodyCompositionCard extends StatelessWidget {
  const BodyCompositionCard({super.key});

  // Tamaño de la silueta (los puntos de dummy_data usan estas medidas).
  static const double figureWidth = 140;
  static const double figureHeight = 380;
  // Espacio a cada lado para las etiquetas.
  static const double sideSpace = 90;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    final List<Widget> summary = [];
    compositionSummary.forEach((label, value) {
      summary.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.muted(c, size: 13)),
              Text(value, style: AppText.bigNumber(c, size: 19)),
            ],
          ),
        ),
      );
    });

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Composición corporal', style: AppText.cardLabel(c)),
              Text('medición del $lastMeasurementDate', style: AppText.muted(c, size: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: summary),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: figureWidth + sideSpace * 2,
              height: figureHeight,
              // Stack: encima de la silueta se dibujan los puntos y etiquetas.
              child: Stack(children: [_silhouette(c), for (final BodyPoint point in bodyPoints) ..._point(c, point)]),
            ),
          ),
          const SizedBox(height: 8),
          Text('Sketch de referencia: pliegues en mm, perímetros en cm.', style: AppText.muted(c, size: 13)),
        ],
      ),
    );
  }

  /// Dibuja la silueta con formas redondeadas.
  Widget _silhouette(AppColors c) {
    Widget part(double left, double top, double width, double height, double radius) {
      return Positioned(
        left: sideSpace + left,
        top: top,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: c.beige, borderRadius: BorderRadius.circular(radius)),
        ),
      );
    }

    return Stack(
      children: [
        part(50, 0, 40, 40, 20), // cabeza
        part(62, 38, 16, 14, 4), // cuello
        part(34, 50, 72, 160, 18), // torso
        part(14, 56, 18, 130, 9), // brazo izquierdo
        part(108, 56, 18, 130, 9), // brazo derecho
        part(10, 184, 24, 30, 12), // mano izquierda
        part(106, 184, 24, 30, 12), // mano derecha
        part(40, 200, 26, 170, 12), // pierna izquierda
        part(74, 200, 26, 170, 12), // pierna derecha
      ],
    );
  }

  /// Un punto rojo sobre la silueta, una línea y su etiqueta a un lado.
  List<Widget> _point(AppColors c, BodyPoint point) {
    const double dot = 14;
    final double dotLeft = sideSpace + point.left - dot / 2;
    final double dotTop = point.top - dot / 2;

    // La etiqueta va pegada al borde izquierdo o derecho de la tarjeta.
    final double lineStart = point.labelOnLeft ? sideSpace - 4 : dotLeft + dot;
    final double lineEnd = point.labelOnLeft ? dotLeft : sideSpace + figureWidth + 4;

    return [
      Positioned(
        left: lineStart,
        top: point.top - 0.5,
        child: Container(width: lineEnd - lineStart, height: 1, color: c.textFaint.withValues(alpha: 0.5)),
      ),
      Positioned(
        left: dotLeft,
        top: dotTop,
        child: Container(
          width: dot,
          height: dot,
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(dot / 2),
            border: Border.all(color: c.card, width: 2.5),
          ),
        ),
      ),
      Positioned(
        left: point.labelOnLeft ? 0 : sideSpace + figureWidth + 6,
        top: point.top - 34,
        child: SizedBox(
          width: sideSpace - 6,
          child: Column(
            crossAxisAlignment: point.labelOnLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(point.label, style: AppText.muted(c, size: 11)),
              Text(point.value, style: AppText.body(c, size: 14, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ];
  }
}
