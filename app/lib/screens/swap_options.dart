import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_data.dart';
import '../models/meal.dart';
import '../providers/plan_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_card.dart';

/// Opciones equivalentes para una comida. Al elegir una, se cambia en el
/// plan (PlanProvider) y regresamos a la pantalla anterior.
class SwapOptionsScreen extends StatelessWidget {
  const SwapOptionsScreen({super.key, required this.day, required this.meal});

  final int day;
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    // Las opciones son las alternativas del tiempo de comida, más el
    // platillo original del mock, sin repetir el que ya está en el plan.
    final List<String> options = [];
    for (final Meal base in baseMeals) {
      if (base.id == meal.id && base.name != meal.name) {
        options.add(base.name);
      }
    }
    for (final String name in swapOptions[meal.id]!) {
      if (name != meal.name) {
        options.add(name);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        title: Text('Cambiar ${meal.mealTime.toLowerCase()}', style: AppText.body(c, size: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          Text('Ahora tienes', style: AppText.kicker(c)),
          Text(meal.name, style: AppText.title(c).copyWith(fontSize: 30)),
          const SizedBox(height: 6),
          Text('Cubre: ${meal.portionsText}', style: AppText.muted(c)),
          const SizedBox(height: 22),
          Text('Opciones con los mismos equivalentes', style: AppText.cardLabel(c)),
          const SizedBox(height: 12),
          for (final String option in options)
            SectionCard(
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
              child: Row(
                children: [
                  Expanded(child: Text(option, style: AppText.body(c))),
                  const SizedBox(width: 12),
                  PillButton(
                    label: 'Elegir',
                    accent: true,
                    height: 46,
                    onPressed: () {
                      // listen: false porque aquí solo llamamos una función, no redibujamos.
                      Provider.of<PlanProvider>(context, listen: false).swapMeal(day, meal, option);
                      showInfoSnackBar(context, 'Listo: cambiaste tu ${meal.mealTime.toLowerCase()} por $option.');
                      // Regresa a la pantalla anterior.
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          PillButton(
            label: 'Buscar otro alimento',
            onPressed: () {
              showPendingDialog(
                context,
                'Aquí podrás buscar en todo el catálogo de equivalentes y armar tu propia combinación.',
              );
            },
          ),
        ],
      ),
    );
  }
}
