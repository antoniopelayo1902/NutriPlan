import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/portions.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../actions/app_button.dart';
import '../actions/app_toggle_button.dart';
import '../data_display/app_badge.dart';
import '../data_display/eyebrow.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import 'portion_tags.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.slotLabel,
    required this.time,
    required this.dish,
    required this.portions,
    required this.done,
    required this.swapped,
    required this.onChange,
    required this.onToggle,
  });

  final String slotLabel;
  final String time;
  final String dish;
  final Portions portions;
  final bool done;
  final bool swapped;

  /// Null disables the button (done meals cannot be swapped).
  final VoidCallback? onChange;

  /// Null disables the button (future days cannot be marked).
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s2,
            children: <Widget>[
              Eyebrow(slotLabel),
              AppText(time, variant: TextVariant.caption, tone: TextTone.muted),
              const Spacer(),
              if (swapped)
                const AppBadge(S.badgeSwapped, tone: BadgeTone.accent),
            ],
          ),
          AppText(
            dish,
            variant: TextVariant.bodyLg,
            tone: done ? TextTone.muted : TextTone.primary,
          ),
          PortionTags(portions),
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s2,
            wrap: true,
            children: <Widget>[
              AppButton(
                label: S.mealChange,
                variant: ButtonVariant.outlineAccent,
                onPressed: onChange,
              ),
              AppToggleButton(
                label: done ? S.mealDone : S.mealMark,
                pressed: done,
                onPressed: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
