import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Renglón "Verduras  100 kcal   ( - ) 4 ( + )" de la pestaña Porciones.
class PortionStepperRow extends StatelessWidget {
  const PortionStepperRow({
    super.key,
    required this.name,
    required this.kcal,
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  final String name;
  final int kcal;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    Widget roundButton(IconData icon, String tooltip, VoidCallback onPressed) {
      return IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.border, width: 1.3),
          ),
          child: Icon(icon, size: 20, color: c.text),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.body(c, size: 18)),
                Text('$kcal kcal', style: AppText.muted(c, size: 14).copyWith(color: c.textFaint)),
              ],
            ),
          ),
          roundButton(Icons.remove, 'Quitar $name', onMinus),
          SizedBox(
            width: 28,
            child: Text('$count', textAlign: TextAlign.center, style: AppText.bigNumber(c, size: 22)),
          ),
          roundButton(Icons.add, 'Agregar $name', onPlus),
        ],
      ),
    );
  }
}
