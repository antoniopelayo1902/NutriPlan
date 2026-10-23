import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_flow_es_mx.dart';
import '../../../domain/models/portions.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../actions/app_button.dart';
import '../data_display/eyebrow.dart';
import '../primitives/app_card.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import 'portion_tags.dart';

/// The meal being swapped, with a way back to the meal list.
class SwapTargetCard extends StatelessWidget {
  const SwapTargetCard({
    super.key,
    required this.eyebrow,
    required this.dish,
    required this.portions,
    required this.onPickAnother,
  });

  final String eyebrow;
  final String dish;
  final Portions portions;
  final VoidCallback onPickAnother;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s2,
        align: CrossAxisAlignment.start,
        children: <Widget>[
          Eyebrow(eyebrow),
          AppText(dish, variant: TextVariant.bodyLg),
          PortionTags(portions),
          AppButton(
            label: SFlow.pickAnother,
            variant: ButtonVariant.ghost,
            iconLeft: AppIconName.chevronLeft,
            onPressed: onPickAnother,
          ),
        ],
      ),
    );
  }
}
