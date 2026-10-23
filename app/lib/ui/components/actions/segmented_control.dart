import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import 'app_chip.dart';

class SegmentOption<T> {
  const SegmentOption(this.value, this.label);
  final T value;
  final String label;
}

/// Pill-shaped switch between a few options, built from [AppChip].
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.fullWidth = false,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final Widget row = AppStack(
      direction: Axis.horizontal,
      gap: t.space.s1,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        for (final SegmentOption<T> o in options)
          _wrap(
            AppChip(
              label: o.label,
              size: ChipSize.sm,
              flat: true,
              expand: fullWidth,
              selected: o.value == value,
              onPressed: () => onChanged(o.value),
            ),
          ),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.bgTrack,
        borderRadius: BorderRadius.circular(t.radius.pill),
      ),
      child: Padding(padding: EdgeInsets.all(t.space.s1), child: row),
    );
  }

  Widget _wrap(Widget chip) =>
      fullWidth ? Expanded(child: chip) : Flexible(child: chip);
}
