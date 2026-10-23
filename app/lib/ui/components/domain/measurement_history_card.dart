import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/services/measurement_trend.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../actions/app_chip.dart';
import '../data_display/bar_chart.dart';
import '../data_display/eyebrow.dart';
import '../data_display/metric.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// Metric chips, latest value with its delta versus the first month, and a
/// bar per month.
class MeasurementHistoryCard extends StatelessWidget {
  const MeasurementHistoryCard({
    super.key,
    required this.metric,
    required this.trend,
    required this.onMetricChanged,
  });

  final MeasurementMetric metric;
  final MetricTrend trend;
  final ValueChanged<MeasurementMetric> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final String unit = metricUnit(metric);
    final DateTime firstDate = trend.dates.first;
    final DateTime lastDate = trend.dates.last;
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s4,
        children: <Widget>[
          Eyebrow(
            S.historyEyebrow(
              metricLabel(metric),
              monthName(firstDate.month),
              monthName(lastDate.month),
            ),
          ),
          AppStack(
            direction: Axis.horizontal,
            wrap: true,
            gap: t.space.s2,
            children: <Widget>[
              for (final MeasurementMetric m in MeasurementMetric.values)
                AppChip(
                  label: metricLabel(m),
                  size: ChipSize.sm,
                  selected: m == metric,
                  onPressed: () => onMetricChanged(m),
                ),
            ],
          ),
          Metric(
            value: formatDecimal(trend.latest),
            unit: unit,
            size: MetricSize.lg,
            delta: S.deltaVs(
              formatSigned(trend.delta),
              unit,
              monthName(firstDate.month),
            ),
            deltaTone: trend.improving ? TextTone.success : TextTone.warning,
            caption: trend.improving
                ? S.measurementImproving
                : S.measurementWatch,
          ),
          BarChart(
            showValues: true,
            data: <BarDatum>[
              for (int i = 0; i < trend.values.length; i++)
                BarDatum(
                  label: monthShort(trend.dates[i].month),
                  value: trend.values[i],
                  valueLabel: formatDecimal(trend.values[i]),
                  state: i == trend.values.length - 1
                      ? BarState.current
                      : BarState.past,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
