import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/measurement.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/body_map.dart';
import '../data_display/eyebrow.dart';
import '../data_display/metric.dart';
import '../data_display/metric_group.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// Read-only body composition: headline metrics plus the 8-site body map.
class BodyCompositionCard extends StatelessWidget {
  const BodyCompositionCard({
    super.key,
    required this.measurement,
    required this.nutritionistName,
  });

  final Measurement measurement;
  final String nutritionistName;

  String _mm(double? v) =>
      v == null ? '-' : formatWithUnit(formatDecimal(v), S.unitMm);
  String _cm(double? v) =>
      v == null ? '-' : formatWithUnit(formatDecimal(v), S.unitCm);

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final Skinfolds s = measurement.skinfolds;
    final Circumferences c = measurement.circumferences;
    BodySiteData site(BodySiteId id, String value) =>
        BodySiteData(id: id, label: S.siteLabels[id.name]!, valueLabel: value);
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s4,
        children: <Widget>[
          const Eyebrow(S.bodyEyebrow),
          MetricGroup(
            items: <Metric>[
              Metric(
                label: S.labelWeight,
                value: formatDecimal(measurement.weightKg),
                unit: S.unitKg,
                size: MetricSize.sm,
              ),
              Metric(
                label: S.labelHeight,
                value: formatDecimal(measurement.heightM, digits: 2),
                unit: S.unitM,
                size: MetricSize.sm,
              ),
              Metric(
                label: S.labelFat,
                value: formatDecimal(measurement.bodyFatPct),
                unit: S.unitPct,
                size: MetricSize.sm,
              ),
              Metric(
                label: S.labelMuscle,
                value: formatDecimal(measurement.muscleKg),
                unit: S.unitKg,
                size: MetricSize.sm,
              ),
            ],
          ),
          BodyMap(
            sites: <BodySiteData>[
              site(BodySiteId.tricipital, _mm(s.tricipital)),
              site(BodySiteId.bicipital, _mm(s.bicipital)),
              site(BodySiteId.subescapular, _mm(s.subescapular)),
              site(BodySiteId.suprailiaco, _mm(s.suprailiaco)),
              site(BodySiteId.brazo, _cm(c.brazo)),
              site(BodySiteId.cintura, _cm(c.cintura)),
              site(BodySiteId.cadera, _cm(c.cadera)),
              site(BodySiteId.muslo, _cm(c.muslo)),
            ],
          ),
          AppText(
            S.bodyCaption(nutritionistName, formatDayMonth(measurement.date)),
            variant: TextVariant.caption,
            tone: TextTone.muted,
          ),
        ],
      ),
    );
  }
}
