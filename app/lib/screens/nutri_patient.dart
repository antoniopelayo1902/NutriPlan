import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/food_group.dart';
import '../models/measures.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/bar_chart.dart';
import '../widgets/body_composition.dart';
import '../widgets/metric_chips.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/portion_stepper.dart';
import '../widgets/section_card.dart';
import 'share_plan.dart';

/// "Nuevo plan" de un paciente, vista de la nutrióloga.
/// Tres pestañas hechas con PillButton: Medidas, Historial y Porciones.
class NutriPatientScreen extends StatefulWidget {
  const NutriPatientScreen({super.key, required this.patient});

  final Patient patient;

  @override
  State<NutriPatientScreen> createState() => _NutriPatientScreenState();
}

class _NutriPatientScreenState extends State<NutriPatientScreen> {
  int _tab = 0; // 0 = Medidas, 1 = Historial, 2 = Porciones
  int _selectedMetric = 0;

  /// Porciones que la nutrióloga va ajustando con + y -.
  final Map<String, int> _portions = Map.of(dailyTargets);

  int get _totalKcal {
    int total = 0;
    for (final FoodGroup group in foodGroups) {
      total += _portions[group.key]! * group.kcalPerPortion;
    }
    return total;
  }

  void _change(String key, int delta) {
    setState(() {
      final int next = _portions[key]! + delta;
      // No se permiten porciones negativas.
      _portions[key] = next < 0 ? 0 : next;
    });
  }

  /// Convierte "71.2 kg" en 71.2.
  double _numberOf(String text) => double.parse(text.split(' ')[0]);

  /// Formato con separador de miles: 1820 -> "1,820".
  String _thousands(int value) {
    final String text = '$value';
    if (text.length <= 3) return text;
    return '${text.substring(0, text.length - 3)},${text.substring(text.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final Patient p = widget.patient;
    final String firstName = p.name.split(' ')[0];

    Widget content;
    if (_tab == 0) {
      content = _measures(c, p);
    } else if (_tab == 1) {
      content = _history(c);
    } else {
      content = _portionsTab(c, firstName);
    }

    return Scaffold(
      // SafeArea: evita el notch.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Regresar',
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new, color: c.text, size: 20),
              ),
            ),
            Text('Nuevo plan', style: AppText.kicker(c, color: c.green)),
            Text(p.name, style: AppText.title(c)),
            const SizedBox(height: 6),
            Text('${p.age} años · ${p.followUp} · ${p.visit}', style: AppText.muted(c)),
            const SizedBox(height: 18),
            Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      child: PillButton(
                        key: Key('nutriTab$i'),
                        label: ['Medidas', 'Historial', 'Porciones'][i],
                        selected: _tab == i,
                        fontSize: 15,
                        // Cambia de pestaña (Medidas, Historial, Porciones).
                        onPressed: () => setState(() => _tab = i),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            content,
          ],
        ),
      ),
    );
  }

  Widget _measures(AppColors c, Patient p) {
    final List<Widget> rows = [];
    p.measures.forEach((label, value) {
      if (rows.isNotEmpty) {
        rows.add(Container(height: 1, color: c.border));
      }
      final bool missing = value.isEmpty;
      rows.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            label,
            style: AppText.body(c, weight: FontWeight.w400).copyWith(color: missing ? c.textMuted : c.text),
          ),
          trailing: Text(
            missing ? 'Por llenar' : value,
            style: AppText.body(c, weight: FontWeight.w700).copyWith(color: missing ? c.accent : c.text),
          ),
          onTap: () {
            showPendingDialog(context, 'Aquí podrás capturar o corregir "$label" de ${p.name}.');
          },
        ),
      );
    });

    final double weight = _numberOf(p.measures['Peso']!);
    final double height = _numberOf(p.measures['Talla']!);
    // IMC = peso / talla².
    final double bmi = weight / (height * height);

    Widget calculated(String value, String label) {
      return Padding(
        padding: const EdgeInsets.only(right: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppText.bigNumber(c, size: 30, color: c.green)),
            Text(label, style: AppText.muted(c, size: 14).copyWith(color: c.green)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
          child: Column(children: rows),
        ),
        SectionCard(
          color: c.greenBackground,
          shadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calculado automáticamente', style: AppText.cardLabel(c).copyWith(color: c.green)),
              const SizedBox(height: 6),
              Row(
                children: [
                  calculated(bmi.toStringAsFixed(1), 'IMC'),
                  calculated(_thousands(1820), 'GET kcal'),
                  calculated('34.8%', 'grasa est.'),
                ],
              ),
            ],
          ),
        ),
        Text(
          'La tabla completa se llena desde la web. Aquí solo confirmas y ajustas en consulta.',
          style: AppText.muted(c),
        ),
      ],
    );
  }

  Widget _history(AppColors c) {
    final MeasureSeries series = measureSeries[_selectedMetric];
    double max = 0;
    for (final double v in series.values) {
      if (v > max) max = v;
    }
    final List<double> heights = [];
    final List<Color> colors = [];
    final List<String> labels = [];
    for (int i = 0; i < series.values.length; i++) {
      heights.add((series.values[i] - max * 0.85) / (max * 0.15));
      colors.add(i == series.values.length - 1 ? c.accentStrong : c.beige);
      labels.add(series.values[i].toStringAsFixed(1));
    }

    final List<String> names = [];
    for (final MeasureSeries s in measureSeries) {
      names.add(s.name);
    }

    return Column(
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricChips(
                names: names,
                selectedIndex: _selectedMetric,
                onSelected: (index) => setState(() => _selectedMetric = index),
              ),
              const SizedBox(height: 12),
              Text('${series.name} · junio a septiembre', style: AppText.cardLabel(c)),
              const SizedBox(height: 14),
              SimpleBarChart(
                values: heights,
                labels: series.months,
                barColors: colors,
                valueLabels: labels,
                height: 110,
              ),
            ],
          ),
        ),
        const BodyCompositionCard(),
      ],
    );
  }

  Widget _portionsTab(AppColors c, String firstName) {
    final List<Widget> rows = [];
    for (final FoodGroup group in foodGroups) {
      if (rows.isNotEmpty) {
        rows.add(Container(height: 1, color: c.border));
      }
      final int count = _portions[group.key]!;
      rows.add(
        PortionStepperRow(
          name: group.name,
          kcal: count * group.kcalPerPortion,
          count: count,
          // Resta una porción.
          onMinus: () => _change(group.key, -1),
          // Suma una porción.
          onPlus: () => _change(group.key, 1),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          padding: const EdgeInsets.fromLTRB(22, 12, 10, 18),
          child: Column(
            children: [
              ...rows,
              Container(height: 1, color: c.border),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total del día', style: AppText.body(c, weight: FontWeight.w700)),
                    Text(
                      '${_thousands(_totalKcal)} kcal',
                      key: const Key('totalKcal'),
                      style: AppText.bigNumber(c, size: 26, color: c.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: PillButton(
            label: 'Publicar plan a $firstName',
            selected: true,
            height: 60,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SharePlanScreen(patient: widget.patient, portions: Map.of(_portions)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Al publicar, $firstName recibe su semana y el catálogo de equivalentes correspondiente. No captura nada.',
          style: AppText.muted(c),
        ),
      ],
    );
  }
}
