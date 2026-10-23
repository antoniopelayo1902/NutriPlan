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
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[
          Eyebrow(eyebrow, tone: TextTone.inverse),
          AppText(dish, variant: TextVariant.bodyLg, tone: TextTone.inverse),
          PortionTags(portions, tone: TextTone.inverse),
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
