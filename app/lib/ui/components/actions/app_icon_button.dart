import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';
import '../primitives/focus_ring.dart';
import '../primitives/pressable.dart';

enum IconButtonSize { sm, md }

enum IconButtonVariant { ghost, outline }

/// Icon-only button. The sm size is 32 visually but keeps a 44 hit area.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = IconButtonSize.md,
    this.variant = IconButtonVariant.ghost,
  });

  final AppIconName icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final IconButtonSize size;
  final IconButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double visual = size == IconButtonSize.sm
        ? t.size.iconButtonSm
        : t.size.iconButtonMd;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      builder: (BuildContext context, PressState s) {
        final Color fill = s.pressed || s.hovered
            ? t.colors.bgTrack
            : t.colors.transparent;
        final Widget box = Opacity(
          opacity: onPressed == null ? t.size.disabledOpacity : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: variant == IconButtonVariant.outline
                  ? Border.all(
                      color: t.colors.borderStrong,
                      width: t.size.borderWidth,
                    )
                  : null,
            ),
            child: SizedBox(
              width: visual,
              height: visual,
              child: Center(child: AppIcon(icon, tone: TextTone.secondary)),
            ),
          ),
        );
        return FocusRing(visible: s.focused, radius: visual / 2, child: box);
      },
    );
  }
}
