import 'package:flutter/widgets.dart';

import '../../../theme/food_palette.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

enum BarTone { accent, success, warning, neutral }

/// Horizontal progress with optional label row. Switches to the warning tone
/// by itself when [value] exceeds [max].
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.tone = BarTone.accent,
    this.label,
    this.valueLabel,
    this.food,
  });

  final double value;
  final double max;
  final BarTone tone;
  final String? label;
  final String? valueLabel;

  /// Food-group colors: group solid on the group soft track.
  final FoodTone? food;

  bool get over => value > max;

  BarTone get effectiveTone => over ? BarTone.warning : tone;

  Color _fill(SemanticColors c) {
    if (food != null && !over) return food!.solid;
    switch (effectiveTone) {
      case BarTone.accent:
        return c.accent;
      case BarTone.success:
        return c.dayComplete;
      case BarTone.warning:
        return c.dayPartial;
      case BarTone.neutral:
        return c.borderStrong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double factor = max <= 0 ? 0 : (value / max).clamp(0.0, 1.0);
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Widget track = DecoratedBox(
      decoration: BoxDecoration(
        color: food?.soft ?? t.colors.bgTrack,
        borderRadius: BorderRadius.circular(t.radius.pill),
      ),
      child: SizedBox(
        height: t.size.progressBar,
        child: AnimatedFractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: factor,
          duration: reduce ? Duration.zero : t.motion.base,
          curve: t.motion.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _fill(t.colors),
              borderRadius: BorderRadius.circular(t.radius.pill),
            ),
          ),
        ),
      ),
    );
    final TextTone valueTone = over ? TextTone.warning : TextTone.secondary;
    return Semantics(
      label: label,
      value: valueLabel ?? '${(factor * 100).round()}',
      container: true,
      child: ExcludeSemantics(
        child: AppStack(
          gap: t.space.s2,
          children: <Widget>[
            if (label != null || valueLabel != null)
              AppStack(
                direction: Axis.horizontal,
                gap: t.space.s2,
                justify: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  if (label != null)
                    Flexible(
                      child: AppText(
                        label!,
                        variant: TextVariant.bodySm,
                        tone: TextTone.secondary,
                      ),
                    ),
                  if (valueLabel != null)
                    AppText(
                      valueLabel!,
                      variant: TextVariant.label,
                      tone: valueTone,
                    ),
                ],
              ),
            track,
          ],
        ),
      ),
    );
  }
}
