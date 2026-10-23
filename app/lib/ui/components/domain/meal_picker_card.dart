import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../core/i18n/strings_flow_es_mx.dart';
import '../../../domain/models/plan.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/empty_state.dart';
import '../data_display/list_item.dart';
import '../primitives/app_card.dart';
import '../primitives/app_divider.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

/// Step 1 of a swap: choose which open meal of today to change.
class MealPickerCard extends StatelessWidget {
  const MealPickerCard({super.key, required this.open, required this.onPick});

  final List<Meal> open;
  final ValueChanged<Meal> onPick;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    if (open.isEmpty) {
      return const EmptyState(
        title: SFlow.pickMealAllDoneTitle,
        body: SFlow.pickMealAllDoneBody,
      );
    }
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s2,
        children: <Widget>[
          const AppText(S.pickMealTitle, variant: TextVariant.bodyLg),
          const AppText(
            SFlow.pickMealHint,
            variant: TextVariant.bodyMd,
            tone: TextTone.muted,
          ),
          for (int i = 0; i < open.length; i++) ...<Widget>[
            if (i > 0) const AppDivider(),
            ListItem(
              title: open[i].dish,
              subtitle:
                  '${slotLabel(open[i].slot)} · ${formatTime(open[i].time)}',
              trailing: const AppIcon(AppIconName.chevronRight),
              onPressed: () => onPick(open[i]),
            ),
          ],
        ],
      ),
    );
  }
}
