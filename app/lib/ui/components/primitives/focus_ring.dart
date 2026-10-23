import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';

/// 2px accent ring with a 2px offset, drawn around [child] when [visible]
/// (keyboard focus only; Pressable reports that).
class FocusRing extends StatelessWidget {
  const FocusRing({
    super.key,
    required this.visible,
    required this.child,
    required this.radius,
  });

  final bool visible;
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (!visible) return child;
    final AppTokens t = context.tokens;
    final double grow = t.size.focusRingOffset + t.size.focusRingWidth;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        Positioned(
          left: -grow,
          top: -grow,
          right: -grow,
          bottom: -grow,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + grow),
                border: Border.all(
                  color: t.colors.accent,
                  width: t.size.focusRingWidth,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
