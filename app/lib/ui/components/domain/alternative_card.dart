import 'package:flutter/widgets.dart';

import '../../../domain/models/fit.dart';
import '../../../domain/models/portions.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/fit_badge.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import 'portion_tags.dart';

class AlternativeCard extends StatelessWidget {
  const AlternativeCard({
    super.key,
    required this.dish,
    required this.portions,
    required this.fit,
    required this.onTap,
  });

  final String dish;
  final Portions portions;
  final Fit fit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      elevation: CardElevation.item,
      radius: t.radius.lg,
      onTap: onTap,
      semanticLabel: '$dish, ${FitBadge.labelOf(fit)}',
      child: AppStack(
        gap: t.space.s2,
        children: <Widget>[
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s3,
            align: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(child: AppText(dish, variant: TextVariant.bodyLg)),
              FitBadge(fit),
            ],
          ),
          PortionTags(portions),
        ],
      ),
    );
  }
}
