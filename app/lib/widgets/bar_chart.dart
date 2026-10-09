import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Gráfica de barras hecha solo con Row, Column y AnimatedContainer.
/// Cada barra crece con una animación implícita cuando cambian los datos.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.barColors,
    this.valueLabels,
    this.height = 150,
    this.spacing = 14,
  });

  /// Altura de cada barra, de 0 a 1 (1 = barra completa).
  final List<double> values;
  final List<String> labels;
  final List<Color> barColors;
  final List<String>? valueLabels; // texto opcional encima de cada barra
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final List<Widget> bars = [];

    for (int i = 0; i < values.length; i++) {
      // Una barra vacía se dibuja como una línea delgada.
      double barHeight = values[i] * height;
      // Altura mínima para que los días sin datos se vean como una línea.
      if (barHeight < 8) {
        barHeight = 8;
      }

      bars.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (valueLabels != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(valueLabels![i], style: AppText.muted(c, size: 14).copyWith(color: c.textMuted)),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  height: barHeight,
                  decoration: BoxDecoration(color: barColors[i], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 10),
                Text(labels[i], style: AppText.muted(c, size: 13).copyWith(color: c.textFaint)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height + (valueLabels != null ? 84 : 44),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: bars),
    );
  }
}
