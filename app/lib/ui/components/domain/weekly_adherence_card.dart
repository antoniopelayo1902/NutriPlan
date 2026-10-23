import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/bar_chart.dart';
import '../data_display/eyebrow.dart';
import '../data_display/metric.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

class WeeklyAdherenceCard extends StatelessWidget {
  const WeeklyAdherenceCard({
    super.key,
    required this.pctLabel,
    required this.deltaLabel,
    required this.deltaTone,
    required this.days,
    this.highlightIndex,
  });

  final String pctLabel;
  final String deltaLabel;
  final TextTone deltaTone;
  final List<BarDatum> days;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s4,
        children: <Widget>[
          const Eyebrow(S.adherenceEyebrow),
          Metric(
            value: pctLabel,
            size: MetricSize.xl,
            delta: deltaLabel,
            deltaTone: deltaTone,
          ),
          BarChart(data: days, highlightIndex: highlightIndex),
        ],
      ),
    );
  }
}
