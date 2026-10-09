import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_data.dart';
import '../models/meal.dart';
import '../providers/plan_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_card.dart';
import 'swap_options.dart';

/// "¿Otra cosa?": lista de las comidas de hoy para elegir cuál cambiar.
class SwapScreen extends StatelessWidget {
  const SwapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Consumer<PlanProvider>(
      builder: (context, plan, child) {
        final List<Widget> rows = [];
        for (final Meal meal in plan.todayMeals) {
          // Línea separadora entre renglones.
          rows.add(Container(height: 1, color: c.border));
          rows.add(
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              title: Text(meal.mealTime, style: AppText.cardLabel(c)),
              subtitle: Text(meal.name, style: AppText.body(c)),
              trailing: Icon(Icons.chevron_right, color: c.textFaint),
              // Abre las opciones equivalentes de esa comida.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SwapOptionsScreen(day: todayIndex, meal: meal),
                  ),
                );
              },
            ),
          );
        }

        // SafeArea: evita el notch.
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
            children: [
              const ScreenHeader(kicker: 'Equivalentes', title: '¿Otra cosa?', initials: userInitials),
              SectionCard(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text('¿Cuál comida quieres cambiar?', style: AppText.body(c, size: 18)),
                    ),
                    ...rows,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'Las opciones tienen los mismos equivalentes que tu plan, así que cambiar no te saca de tu dieta.',
                  style: AppText.muted(c),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
