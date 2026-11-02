import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/portions.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../actions/app_button.dart';
import '../primitives/app_icon.dart';
import '../data_display/eyebrow.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import 'portion_tags.dart';

class NextMealCard extends StatelessWidget {
  const NextMealCard({
    super.key,
    required this.eyebrow,
    required this.dish,
    required this.portions,
    required this.onCrave,
  });

  final String eyebrow;
  final String dish;
  final Portions portions;
  final VoidCallback onCrave;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      tone: CardTone.inverse,
      backdrop: const _Circles(),
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[
          Eyebrow(eyebrow, tone: TextTone.inverse),
          AppText(dish, variant: TextVariant.bodyLg, tone: TextTone.inverse),
          PortionTags(portions),
          AppStack(
            direction: Axis.horizontal,
            children: <Widget>[
              Flexible(
                child: AppButton(
                  label: S.craveSomethingElse,
                  variant: ButtonVariant.secondary,
                  iconRight: AppIconName.arrowRight,
                  onPressed: onCrave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two decorative circles (accent and highlight) in the top-right corner.
class _Circles extends StatelessWidget {
  const _Circles();

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ExcludeSemantics(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -t.size.decoCircleLg / 2,
            right: -t.size.decoCircleLg / 2,
            child: _dot(t.size.decoCircleLg, t.colors.accent),
          ),
          Positioned(
            top: -t.size.decoOffset,
            right: t.size.decoCircleLg / 2 + t.space.s2,
            child: _dot(t.size.decoCircleSm, t.colors.highlight),
          ),
        ],
      ),
    );
  }

  Widget _dot(double size, Color color) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
