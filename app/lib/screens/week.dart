import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/dummy_data.dart';
import '../models/meal.dart';
import '../providers/plan_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/meal_card.dart';
import '../widgets/screen_header.dart';
import 'swap_options.dart';

/// "Mi semana": selector de día y las comidas de ese día.
class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

  /// Color del puntito debajo de cada día según cómo le fue.
  Color _dotColor(AppColors c, String status) {
    if (status == 'ok') return c.green;
    if (status == 'partial') return const Color(0xFFD1922F);
    if (status == 'today') return c.beige;
    return c.border;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    // Consumer se vuelve a dibujar cuando PlanProvider llama notifyListeners().
    return Consumer<PlanProvider>(
      builder: (context, plan, child) {
        final int day = plan.selectedDay;
        final List<Meal> meals = plan.mealsOf(day);

        final List<Widget> dayButtons = [];
        for (int i = 0; i < 7; i++) {
          final bool selected = i == day;
          dayButtons.add(
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  height: 84,
                  child: ElevatedButton(
                    key: Key('day$i'),
                    // Cambia el día y el Consumer redibuja las comidas.
                    onPressed: () => plan.selectDay(i),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      backgroundColor: selected ? c.inverse : c.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: selected ? c.inverse : c.border),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekDayLetters[i],
                          style: AppText.muted(c, size: 12).copyWith(color: selected ? c.onInverse : c.textMuted),
                        ),
                        Text(
                          '${weekDayNumbers[i]}',
                          style: AppText.bigNumber(c, size: 22).copyWith(color: selected ? c.onInverse : c.text),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _dotColor(c, dayStatus[i]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // SafeArea: evita el notch. bottom: false porque abajo ya está la barra.
        return SafeArea(
          bottom: false,
          child: ListView(
            // 130 abajo para que la barra flotante no tape la última tarjeta.
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
            children: [
              const ScreenHeader(kicker: 'Plan semanal', title: 'Mi semana', initials: userInitials),
              Row(children: dayButtons),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '${weekDayNames[day]} ${weekDayNumbers[day]}${day == todayIndex ? ' · hoy' : ''}',
                  style: AppText.kicker(c, color: c.textMuted),
                ),
              ),
              // Una tarjeta por cada comida del día.
              for (final Meal meal in meals)
                MealCard(
                  meal: meal,
                  done: plan.isDone(day, meal),
                  // Marca/desmarca la comida (también actualiza la pantalla Hoy).
                  onMark: () => plan.toggleDone(day, meal),
                  onSwap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SwapOptionsScreen(day: day, meal: meal),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
