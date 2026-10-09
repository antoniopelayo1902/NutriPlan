import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_data.dart';
import '../models/food_group.dart';
import '../models/meal.dart';
import '../providers/plan_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pill_button.dart';
import '../widgets/portion_progress.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_card.dart';
import 'swap_options.dart';

/// "Hoy": cuántos equivalentes llevas y cuál es tu siguiente comida.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.onGoToSwap});

  /// Lleva a la pestaña "Cambiar" cuando ya no quedan comidas.
  final VoidCallback onGoToSwap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Consumer<PlanProvider>(
      builder: (context, plan, child) {
        // Primera comida sin marcar (null si ya se marcaron todas).
        final Meal? next = plan.nextMeal;

        // SafeArea: evita el notch.
        return SafeArea(
          bottom: false,
          child: ListView(
            // Espacio para que la barra flotante no tape el contenido.
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
            children: [
              ScreenHeader(
                kicker: '${weekDayNames[todayIndex]} ${weekDayNumbers[todayIndex]} de $monthName',
                title: 'Hoy',
                initials: userInitials,
              ),
              SectionCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Porciones de hoy', style: AppText.cardLabel(c)),
                        Text(
                          '${plan.todayPercent}% cubierto',
                          key: const Key('todayPercent'),
                          style: AppText.bigNumber(c, size: 20, color: c.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Un renglón con barra por cada grupo de equivalentes.
                    for (final FoodGroup group in foodGroups)
                      PortionProgressRow(
                        name: group.name,
                        consumed: plan.consumedToday(group.key),
                        target: dailyTargets[group.key]!,
                      ),
                  ],
                ),
              ),
              SectionCard(
                color: c.inverse,
                // Si ya no hay comidas pendientes, muestra el mensaje de "Listo".
                child: next == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¡Listo por hoy!', style: AppText.cardLabel(c).copyWith(color: c.onInverse)),
                          const SizedBox(height: 8),
                          Text(
                            'Marcaste todas tus comidas. Mañana seguimos.',
                            style: AppText.body(c, size: 19).copyWith(color: c.onInverse),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Siguiente comida',
                            style: AppText.cardLabel(c).copyWith(color: c.onInverse.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 8),
                          Text(next.name, style: AppText.body(c, size: 20).copyWith(color: c.onInverse)),
                          const SizedBox(height: 6),
                          Text(
                            '${next.mealTime} · ${next.portionsText}',
                            style: AppText.muted(c).copyWith(color: c.onInverse.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const Key('cravingButton'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c.onInverse,
                                foregroundColor: c.inverse,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(54),
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SwapOptionsScreen(day: todayIndex, meal: next),
                                  ),
                                );
                              },
                              child: const Text('Se me antoja otra cosa'),
                            ),
                          ),
                        ],
                      ),
              ),
              SectionCard(
                color: c.greenBackground,
                shadow: false,
                child: Text(
                  'Llevas ${plan.swapsThisWeek} intercambios esta semana y sigues dentro del plan. '
                  '$nutritionistName no necesita aprobarlos.',
                  key: const Key('swapsNote'),
                  style: AppText.muted(c, size: 16).copyWith(color: c.text),
                ),
              ),
              if (next == null) PillButton(label: 'Ver opciones de intercambio', onPressed: onGoToSwap),
            ],
          ),
        );
      },
    );
  }
}
