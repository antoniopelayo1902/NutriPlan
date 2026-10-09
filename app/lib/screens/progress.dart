import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/measures.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/bar_chart.dart';
import '../widgets/body_composition.dart';
import '../widgets/metric_chips.dart';
import '../widgets/pill_button.dart';
import '../widgets/screen_header.dart';
import '../widgets/section_card.dart';

/// "Progreso": dos vistas, "Esta semana" y "Mes con mes".
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showMonthly = false;
  int _selectedMetric = 0;

  /// Da formato tipo "71,2" (coma decimal, como en los mocks).
  String _format(double value) => value.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    // SafeArea: evita el notch.
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
        children: [
          const ScreenHeader(kicker: 'Tu avance', title: 'Progreso', initials: userInitials),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Esta semana',
                  selected: !_showMonthly,
                  onPressed: () => setState(() => _showMonthly = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PillButton(
                  label: 'Mes con mes',
                  selected: _showMonthly,
                  onPressed: () => setState(() => _showMonthly = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Muestra la vista semanal o la mensual según el botón elegido.
          if (_showMonthly) ..._monthly(c) else ..._weekly(c),
        ],
      ),
    );
  }

  List<Widget> _weekly(AppColors c) {
    final List<Color> colors = [];
    for (final double value in weekAdherence) {
      if (value >= 1) {
        colors.add(c.accentStrong);
      } else if (value > 0.1) {
        colors.add(c.accentSoft);
      } else {
        colors.add(c.beige);
      }
    }

    return [
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apego de la semana', style: AppText.cardLabel(c)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$weekAdherencePercent%', style: AppText.bigNumber(c, size: 72)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('+$adherenceChange pts', style: AppText.body(c, size: 16).copyWith(color: c.green)),
                    Text('vs. semana pasada', style: AppText.muted(c)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            SimpleBarChart(
              values: weekAdherence,
              labels: const ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
              barColors: colors,
              height: 130,
            ),
          ],
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$distinctFoods', style: AppText.bigNumber(c, size: 34)),
                  const SizedBox(height: 8),
                  Text('alimentos distintos esta semana', style: AppText.muted(c)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_format(weightChangeThisWeek), style: AppText.bigNumber(c, size: 34)),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text('kg', style: AppText.bigNumber(c, size: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('peso registrado por $nutritionistName el jueves', style: AppText.muted(c)),
                ],
              ),
            ),
          ),
        ],
      ),
      SectionCard(
        color: c.accentBackground,
        shadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('$streakDays', style: AppText.bigNumber(c, size: 32, color: c.accent)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'días seguidos sin salirte del plan',
                    style: AppText.body(c, size: 16).copyWith(color: c.accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Las insignias van en filas de dos, hechas con Row.
            Row(children: [_badge(c, achievements[0]), const SizedBox(width: 10), _badge(c, achievements[2])]),
            const SizedBox(height: 10),
            Row(children: [_badge(c, achievements[1])]),
          ],
        ),
      ),
      SectionCard(
        child: Text(
          'Tu variedad subió porque usaste equivalentes. Cambiar de comida cuenta como avance, no como falla.',
          style: AppText.muted(c, size: 17).copyWith(color: c.text),
        ),
      ),
    ];
  }

  Widget _badge(AppColors c, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: AppText.body(c, size: 13).copyWith(color: c.accent)),
    );
  }

  List<Widget> _monthly(AppColors c) {
    final MeasureSeries series = measureSeries[_selectedMetric];

    // Normalizamos las barras: el valor más alto llena la barra.
    double max = 0;
    for (final double v in series.values) {
      if (v > max) max = v;
    }
    final List<double> heights = [];
    final List<Color> colors = [];
    final List<String> valueLabels = [];
    for (int i = 0; i < series.values.length; i++) {
      // Restamos un poco para que las diferencias se noten más.
      heights.add((series.values[i] - max * 0.85) / (max * 0.15));
      colors.add(i == series.values.length - 1 ? c.accentStrong : c.beige);
      valueLabels.add(series.values[i].toStringAsFixed(1));
    }

    // Diferencia entre el primer y el último mes.
    final double change = series.changeSinceStart;
    final String sign = change > 0 ? '+' : '−';
    // Para peso, grasa y cintura bajar es bueno; para músculo, subir.
    final bool goodChange = series.name == 'Masa muscular' ? change > 0 : change < 0;

    final List<String> names = [];
    for (final MeasureSeries s in measureSeries) {
      names.add(s.name);
    }

    return [
      SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricChips(
              names: names,
              selectedIndex: _selectedMetric,
              // Cambia la métrica y redibuja la gráfica.
              onSelected: (index) => setState(() => _selectedMetric = index),
            ),
            const SizedBox(height: 14),
            Text('${series.name} hoy', style: AppText.cardLabel(c)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_format(series.latest), key: const Key('metricValue'), style: AppText.bigNumber(c, size: 64)),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(series.unit, style: AppText.bigNumber(c, size: 22)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sign${_format(change.abs())} ${series.unit}',
                      style: AppText.body(c, size: 16).copyWith(color: goodChange ? c.green : c.accent),
                    ),
                    Text('desde junio', style: AppText.muted(c)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            SimpleBarChart(
              values: heights,
              labels: series.months,
              barColors: colors,
              valueLabels: valueLabels,
              height: 110,
            ),
          ],
        ),
      ),
      const BodyCompositionCard(),
    ];
  }
}
