import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/measurement.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/eyebrow.dart';
import '../primitives/app_card.dart';
import '../primitives/app_divider.dart';
import '../primitives/app_grid.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// One row per measured month with the main values in a grid.
class MonthlyMeasurementsCard extends StatelessWidget {
  const MonthlyMeasurementsCard({super.key, required this.measurements});

  /// Newest first.
  final List<Measurement> measurements;

  Widget _cell(AppTokens t, String label, String value) {
    return AppStack(
      gap: t.space.s0,
      align: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(label, variant: TextVariant.caption, tone: TextTone.muted),
        AppText(value, variant: TextVariant.label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < measurements.length; i++) {
      final Measurement m = measurements[i];
      if (i > 0) rows.add(const AppDivider());
      rows.add(
        AppStack(
          gap: t.space.s2,
          children: <Widget>[
            AppStack(
              direction: Axis.horizontal,
              gap: t.space.s2,
              children: <Widget>[
                AppText(monthName(m.date.month), variant: TextVariant.bodyLg),
                Flexible(
                  child: AppText(
                    S.measuredOn(formatDayMonth(m.date)),
                    variant: TextVariant.caption,
                    tone: TextTone.muted,
                  ),
                ),
              ],
            ),
            AppGrid(
              columns: 4,
              gap: t.space.s2,
              children: <Widget>[
                _cell(
                  t,
                  S.labelWeight,
                  formatWithUnit(formatDecimal(m.weightKg), S.unitKg),
                ),
                _cell(
                  t,
                  S.metricBodyFat,
                  formatWithUnit(formatDecimal(m.bodyFatPct), S.unitPct),
                ),
                _cell(
                  t,
                  S.metricMuscle,
                  formatWithUnit(formatDecimal(m.muscleKg), S.unitKg),
                ),
                _cell(
                  t,
                  S.metricWaist,
                  m.circumferences.cintura == null
                      ? '-'
                      : formatWithUnit(
                          formatDecimal(m.circumferences.cintura!),
                          S.unitCm,
                        ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[const Eyebrow(S.monthsEyebrow), ...rows],
      ),
    );
  }
}
