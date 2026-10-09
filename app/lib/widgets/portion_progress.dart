import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Renglón "Verduras ........ 0 de 4" con su barra de avance.
///
/// Usa LinearProgressIndicator.
/// Dibuja una barra de progreso con un valor de 0 a 1.
class PortionProgressRow extends StatelessWidget {
  const PortionProgressRow({super.key, required this.name, required this.consumed, required this.target});

  final String name;
  final int consumed;
  final int target;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    double progress = 0;
    if (target > 0) {
      progress = consumed / target;
    }
    if (progress > 1) {
      progress = 1;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppText.body(c)),
              Text('$consumed de $target', style: AppText.mono(c)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: c.track,
            color: progress >= 1 ? c.green : c.accentStrong,
          ),
        ],
      ),
    );
  }
}
