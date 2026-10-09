import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/activity_entry.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/bar_chart.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_card.dart';

/// "Movimiento": minutos de la semana, registro rápido e historial.
/// El estado vive aquí (setState) porque ninguna otra pantalla lo usa.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late List<ActivityEntry> _entries;

  @override
  void initState() {
    super.initState();
    // Copiamos la lista hardcodeada para poder agregar y quitar sesiones.
    _entries = List.of(initialActivities);
  }

  int get _totalMinutes {
    int total = 0;
    for (final ActivityEntry entry in _entries) {
      total += entry.minutes;
    }
    return total;
  }

  void _register(QuickActivity quick) {
    setState(() {
      // Agrega la sesión de hoy; setState redibuja total y gráfica.
      _entries.add(
        ActivityEntry(
          type: quick.type,
          day: 'Vie',
          dayIndex: todayIndex,
          minutes: quick.minutes,
          kcal: quick.minutes * quick.kcalPerMinute,
        ),
      );
    });
    showInfoSnackBar(context, '${quick.type} de ${quick.minutes} min registrada hoy.');
  }

  void _remove(int index) {
    final ActivityEntry removed = _entries[index];
    setState(() {
      // Quita la sesión de la lista.
      _entries.removeAt(index);
    });
    showInfoSnackBar(context, 'Se quitó ${removed.type} del ${removed.day}.');
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final int total = _totalMinutes;

    // Minutos por día para la gráfica (lunes a domingo).
    final List<int> perDay = [0, 0, 0, 0, 0, 0, 0];
    for (final ActivityEntry entry in _entries) {
      perDay[entry.dayIndex] += entry.minutes;
    }
    final List<double> bars = [];
    for (final int minutes in perDay) {
      double value = minutes / 60; // 60 min = barra completa
      if (value > 1) value = 1;
      bars.add(value);
    }

    double goalProgress = total / weeklyMovementGoal;
    if (goalProgress > 1) goalProgress = 1;
    final int goalPercent = (total * 100 / weeklyMovementGoal).round();

    // Botones de registro rápido en dos filas (2 por fila).
    final List<Widget> quickRows = [];
    for (int i = 0; i < quickActivities.length; i += 2) {
      final List<Widget> rowChildren = [];
      for (int j = i; j < i + 2 && j < quickActivities.length; j++) {
        final QuickActivity quick = quickActivities[j];
        rowChildren.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: PillButton(
                key: Key('quick${quick.type}'),
                label: '${quick.type} · ${quick.minutes} min',
                height: 50,
                fontSize: 15,
                horizontalPadding: 6,
                fontWeight: FontWeight.w500,
                onPressed: () => _register(quick),
              ),
            ),
          ),
        );
      }
      quickRows.add(Row(children: rowChildren));
    }

    final List<Widget> history = [];
    for (int i = 0; i < _entries.length; i++) {
      final ActivityEntry entry = _entries[i];
      if (i > 0) {
        history.add(Container(height: 1, color: c.border));
      }
      history.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: entry.type == 'Caminata' ? c.greenBackground : c.accentBackground,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Icon(
                  entry.type == 'Caminata' ? Icons.directions_walk : Icons.fitness_center,
                  color: entry.type == 'Caminata' ? c.green : c.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.type, style: AppText.body(c, size: 18)),
                    Text('${entry.day} · ${entry.kcal} kcal', style: AppText.muted(c, size: 14)),
                  ],
                ),
              ),
              Text('${entry.minutes}′', style: AppText.bigNumber(c, size: 24)),
              IconButton(
                key: Key('removeActivity$i'),
                tooltip: 'Quitar',
                onPressed: () => _remove(i),
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: c.border, width: 1.3),
                  ),
                  child: Icon(Icons.close, size: 18, color: c.textMuted),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // SafeArea: evita el notch.
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
        children: [
          const ScreenHeader(kicker: 'Actividad física', title: 'Movimiento', initials: userInitials),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Movimiento de la semana', style: AppText.cardLabel(c)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$total', key: const Key('totalMinutes'), style: AppText.bigNumber(c)),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text('min', style: AppText.bigNumber(c, size: 22)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$goalPercent%', style: AppText.body(c, size: 16).copyWith(color: c.green)),
                        Text('de $weeklyMovementGoal min', style: AppText.muted(c)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: goalProgress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: c.track,
                  color: c.green,
                ),
                const SizedBox(height: 16),
                SimpleBarChart(
                  values: bars,
                  labels: activityDayLetters,
                  barColors: [for (final double v in bars) v > 0.1 ? const Color(0xFFC9B2A1) : c.track],
                  height: 90,
                  spacing: 10,
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registrar en un toque', style: AppText.cardLabel(c)),
                const SizedBox(height: 14),
                ...quickRows,
                const SizedBox(height: 4),
                Text(
                  'Sin formularios: el tipo y la duración típica ya vienen de tu plan. '
                  '$nutritionistName ve el registro en su panel.',
                  style: AppText.muted(c),
                ),
              ],
            ),
          ),
          SectionCard(
            padding: const EdgeInsets.fromLTRB(22, 10, 12, 10),
            child: Column(children: history),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta indicada por $nutritionistName', style: AppText.body(c, size: 16, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$weeklySessionsGoal sesiones · $weeklyMovementGoal min a la semana', style: AppText.muted(c)),
              ],
            ),
          ),
          PillButton(
            label: 'Conectar con Salud de Apple',
            onPressed: () {
              showPendingDialog(
                context,
                'Aquí se leerán tus pasos y entrenamientos desde la app Salud para registrarlos solos.',
              );
            },
          ),
        ],
      ),
    );
  }
}
