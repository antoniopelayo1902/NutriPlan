import 'package:flutter/widgets.dart';

import '../../../domain/services/adherence.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import '../primitives/focus_ring.dart';
import '../primitives/pressable.dart';

class DayPickerDay {
  const DayPickerDay({
    required this.label,
    required this.number,
    required this.status,
    this.semanticLabel,
  });

  final String label;
  final int number;
  final DayStatus status;
  final String? semanticLabel;
}

/// Week strip with a status dot per day.
class DayPicker extends StatelessWidget {
  const DayPicker({
    super.key,
    required this.days,
    required this.selected,
    required this.onSelect,
  });

  final List<DayPickerDay> days;
  final int selected;
  final ValueChanged<int> onSelect;

  Color _dot(SemanticColors c, DayStatus s) {
    switch (s) {
      case DayStatus.complete:
        return c.dayComplete;
      case DayStatus.partial:
        return c.dayPartial;
      case DayStatus.pending:
        return c.dayPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      direction: Axis.horizontal,
      gap: t.space.s1,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        for (int i = 0; i < days.length; i++)
          Expanded(
            child: Pressable(
              onPressed: () => onSelect(i),
              selected: i == selected,
              semanticLabel: days[i].semanticLabel,
              minHeight: t.size.dayPickerHeight,
              stretch: true,
              builder: (BuildContext context, PressState s) {
                final bool on = i == selected;
                final Widget box = DecoratedBox(
                  decoration: BoxDecoration(
                    color: on ? t.colors.bgInverse : t.colors.bgSurface,
                    borderRadius: BorderRadius.circular(t.radius.md),
                    boxShadow: on ? null : t.shadow.item,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: t.size.dayPickerHeight,
                    ),
                    child: Center(
                      child: AppStack(
                        gap: t.space.s1,
                        align: CrossAxisAlignment.center,
                        children: <Widget>[
                          AppText(
                            days[i].label,
                            variant: TextVariant.micro,
                            tone: on ? TextTone.inverse : TextTone.muted,
                          ),
                          AppText(
                            '${days[i].number}',
                            variant: TextVariant.metricXs,
                            tone: on ? TextTone.inverse : TextTone.primary,
                          ),
                          SizedBox(
                            width: t.size.dot,
                            height: t.size.dot,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: _dot(t.colors, days[i].status),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                return FocusRing(
                  visible: s.focused,
                  radius: t.radius.md,
                  child: box,
                );
              },
            ),
          ),
      ],
    );
  }
}
