import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// [complete] and [partial] are adherence days; [current] is today; [past]
/// is a neutral earlier value; [empty] has no data.
enum BarState {
  current,
  complete,
  partial,
  past,
  empty;

  /// State of a day with [pct] percent of its meals done.
  static BarState day(int pct, bool isToday) {
    if (pct == 0) return empty;
    if (isToday) return current;
    return pct >= 100 ? complete : partial;
  }
}

class BarDatum {
  const BarDatum({
    required this.label,
    required this.value,
    this.valueLabel,
    this.state = BarState.past,
  });

  final String label;
  final double value;
  final String? valueLabel;
  final BarState state;
}

/// The one chart of the app. Exposes a single summarizing semantics label.
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.data,
    this.height,
    this.showValues = false,
    this.highlightIndex,
    this.semanticLabel,
  });

  final List<BarDatum> data;

  /// Defaults to the `chartHeight` token.
  final double? height;
  final bool showValues;
  final int? highlightIndex;

  /// Overrides the generated summary.
  final String? semanticLabel;

  String get summary => data
      .map((BarDatum d) => '${d.label} ${d.valueLabel ?? d.value.round()}')
      .join(', ');

  Color _color(SemanticColors c, int i, BarDatum d) {
    if (highlightIndex == i) return c.accent;
    switch (d.state) {
      case BarState.current:
        return c.accent;
      case BarState.complete:
        return c.dayComplete;
      case BarState.partial:
        return c.dayPartial;
      case BarState.past:
        return c.accentMuted;
      case BarState.empty:
        return c.bgEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double chartH = height ?? t.size.chartHeight;
    double maxValue = 0;
    for (final BarDatum d in data) {
      if (d.value > maxValue) maxValue = d.value;
    }
    return Semantics(
      label: semanticLabel ?? summary,
      container: true,
      child: ExcludeSemantics(
        child: AppStack(
          direction: Axis.horizontal,
          align: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            for (int i = 0; i < data.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: t.space.s1),
                  child: _column(context, t, i, data[i], chartH, maxValue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _column(
    BuildContext context,
    AppTokens t,
    int i,
    BarDatum d,
    double chartH,
    double maxValue,
  ) {
    final double valueRow =
        MediaQuery.textScalerOf(context).scale(t.typo.micro.fontSize ?? 0) +
        t.space.s2;
    final double barH = d.value <= 0 || maxValue <= 0
        ? t.size.barStub
        : (chartH * d.value / maxValue).clamp(t.size.barStub, chartH);
    return AppStack(
      gap: t.space.s1,
      align: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: chartH + (showValues ? valueRow : 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (showValues)
                Padding(
                  padding: EdgeInsets.only(bottom: t.space.s1),
                  child: AppText(
                    d.valueLabel ?? d.value.round().toString(),
                    variant: TextVariant.micro,
                    tone: TextTone.secondary,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              AnimatedContainer(
                height: barH,
                duration: t.motion.base,
                curve: t.motion.easeOut,
                decoration: BoxDecoration(
                  color: _color(t.colors, i, d),
                  borderRadius: t.radius.bar,
                ),
              ),
            ],
          ),
        ),
        AppText(
          d.label,
          variant: TextVariant.micro,
          tone: highlightIndex == i ? TextTone.accent : TextTone.muted,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }
}
