import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'pill_button.dart';
import 'section_card.dart';

/// Tarjeta de una comida del plan con sus botones "Cambiar" y "Marcar".
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.done, required this.onSwap, required this.onMark});

  final Meal meal;
  final bool done;
  final VoidCallback onSwap;
  final VoidCallback onMark;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(meal.mealTime, style: AppText.cardLabel(c)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(meal.hour, style: AppText.muted(c, size: 14).copyWith(color: c.textFaint)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(meal.name, style: AppText.body(c, size: 19)),
          const SizedBox(height: 6),
          Text(meal.portionsText, style: AppText.muted(c)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PillButton(key: Key('swap-${meal.id}'), label: 'Cambiar', accent: true, onPressed: onSwap),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PillButton(
                  key: Key('mark-${meal.id}'),
                  // El texto cambia si la comida ya se marcó.
                  label: done ? 'Hecho ✓' : 'Marcar',
                  success: done,
                  onPressed: onMark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
