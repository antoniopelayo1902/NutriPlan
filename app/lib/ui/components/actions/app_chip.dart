import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_text.dart';
import '../primitives/focus_ring.dart';
import '../primitives/pressable.dart';

enum ChipSize { sm, md }

/// Filter, metric and quick-log chip. Visual height 38 (sm) or 44 (md); the
/// hit area is always at least 44x44.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.size = ChipSize.md,
    this.flat = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final ChipSize size;

  /// No border when unselected (used inside a SegmentedControl).
  final bool flat;

  /// Fill the horizontal space offered by the parent.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double height = size == ChipSize.sm ? t.size.chipSm : t.size.chipMd;
    return Pressable(
      onPressed: onPressed,
      selected: selected,
      stretch: expand,
      builder: (BuildContext context, PressState s) {
        Color fill = selected ? t.colors.bgInverse : t.colors.bgSurface;
        if (flat && !selected) fill = t.colors.transparent;
        if (s.pressed || s.hovered) {
          fill = Color.alphaBlend(t.colors.pressOverlay, fill);
        }
        final Widget box = Opacity(
          opacity: onPressed == null ? t.size.disabledOpacity : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(t.radius.pill),
              border: selected || flat
                  ? null
                  : Border.all(
                      color: t.colors.borderDefault,
                      width: t.size.borderWidth,
                    ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.space.s4),
                child: Center(
                  widthFactor: expand ? null : 1,
                  child: AppText(
                    label,
                    variant: TextVariant.label,
                    tone: selected ? TextTone.inverse : TextTone.primary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
        return FocusRing(visible: s.focused, radius: t.radius.pill, child: box);
      },
    );
  }
}
