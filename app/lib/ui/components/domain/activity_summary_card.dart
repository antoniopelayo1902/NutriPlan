import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/services/activity_summary.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/bar_chart.dart';
import '../data_display/eyebrow.dart';
import '../data_display/metric.dart';
import '../data_display/progress_bar.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// Weekly minutes, goal progress and minutes per day.
class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    super.key,
    required this.summary,
    required this.todayIndex,
  });

  final ActivitySummary summary;

  /// Monday = 0. Highlighted in the chart.
  final int todayIndex;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double shown = summary.minutes > summary.goalMinutes
        ? summary.goalMinutes.toDouble()
        : summary.minutes.toDouble();
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s4,
        children: <Widget>[
          const Eyebrow(S.weekEyebrow),
          Metric(
            value: formatInt(summary.minutes),
            unit: S.unitMin,
            size: MetricSize.lg,
            delta: S.goalPct(summary.pct, summary.goalMinutes),
            deltaTone: summary.goalMet ? TextTone.success : TextTone.muted,
          ),
          ProgressBar(
            value: shown,
            max: summary.goalMinutes.toDouble(),
            tone: summary.goalMet ? BarTone.success : BarTone.accent,
            label: S.sessionsCount(summary.sessions, summary.goalSessions),
            valueLabel: '${summary.pct}%',
          ),
          BarChart(
            highlightIndex: todayIndex,
            data: <BarDatum>[
              for (int i = 0; i < summary.minutesPerDay.length; i++)
                BarDatum(
                  label: S.weekdayInitials[i],
                  value: summary.minutesPerDay[i].toDouble(),
                  valueLabel: formatMinutes(summary.minutesPerDay[i]),
                  state: summary.minutesPerDay[i] == 0
                      ? BarState.empty
                      : BarState.past,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
