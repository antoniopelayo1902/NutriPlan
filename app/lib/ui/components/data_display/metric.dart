import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

enum MetricSize { xl, lg, md, sm, xs }

/// Every big number: label, value, unit, delta and caption.
class Metric extends StatelessWidget {
  const Metric({
    super.key,
    required this.value,
    this.label,
    this.unit,
    this.size = MetricSize.md,
    this.delta,
    this.deltaTone = TextTone.muted,
    this.caption,
    this.tone = TextTone.primary,
  });

  final String value;
  final String? label;
  final String? unit;
  final MetricSize size;
  final String? delta;
  final TextTone deltaTone;
  final String? caption;
  final TextTone tone;

  TextVariant get _valueVariant {
    switch (size) {
      case MetricSize.xl:
        return TextVariant.displayXl;
      case MetricSize.lg:
        return TextVariant.displayLg;
      case MetricSize.md:
        return TextVariant.metricMd;
      case MetricSize.sm:
        return TextVariant.metricSm;
      case MetricSize.xs:
        return TextVariant.metricXs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      gap: t.space.s1,
      align: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null)
          AppText(label!, variant: TextVariant.bodySm, tone: TextTone.muted),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Flexible(
              child: AppText(
                value,
                variant: _valueVariant,
                tone: tone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unit != null) ...<Widget>[
              SizedBox(width: t.space.s1),
              AppText(unit!, variant: TextVariant.bodyMd, tone: TextTone.muted),
            ],
          ],
        ),
        if (delta != null)
          AppText(delta!, variant: TextVariant.label, tone: deltaTone),
        if (caption != null)
          AppText(caption!, variant: TextVariant.caption, tone: TextTone.muted),
      ],
    );
  }
}
