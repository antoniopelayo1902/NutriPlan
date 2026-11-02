import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../domain/models/food_group.dart';
import '../../../domain/models/portions.dart';
import '../../../theme/food_color.dart';
import '../../../theme/food_palette.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// "1 Cereal", "1 Fruta" pills for a set of portions: a food-group dot on a
/// soft food-group background. Read as a single "1 Cereal · 1 Fruta" label.
class PortionTags extends StatelessWidget {
  const PortionTags(this.portions, {super.key});

  final Portions portions;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Semantics(
      container: true,
      label: formatPortionTags(portions),
      child: ExcludeSemantics(
        child: AppStack(
          direction: Axis.horizontal,
          wrap: true,
          gap: t.space.s2,
          children: <Widget>[
            for (final FoodGroup g in tagOrder)
              if (portions[g] > 0)
                _Pill(
                  tone: foodColor(t.colors, g),
                  label:
                      '${formatPortion(portions[g])} '
                      '${groupTagLabel(g, portions[g])}',
                ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.tone, required this.label});

  final FoodTone tone;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.soft,
        borderRadius: BorderRadius.circular(t.radius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.space.s2,
          vertical: t.space.s1,
        ),
        child: AppStack(
          direction: Axis.horizontal,
          gap: t.space.s1,
          children: <Widget>[
            SizedBox(
              width: t.size.dot,
              height: t.size.dot,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tone.solid,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            AppText(label, variant: TextVariant.caption, color: tone.ink),
          ],
        ),
      ),
    );
  }
}
