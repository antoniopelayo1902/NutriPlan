import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import '../primitives/focus_ring.dart';
import '../primitives/pressable.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    Widget row(bool focused) {
      final Widget content = Padding(
        padding: EdgeInsets.symmetric(vertical: t.space.s2),
        child: AppStack(
          direction: Axis.horizontal,
          gap: t.space.s3,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ?leading,
            Expanded(
              child: AppStack(
                gap: t.space.s1,
                align: CrossAxisAlignment.start,
                children: <Widget>[
                  AppText(title, variant: TextVariant.bodyLg),
                  if (subtitle != null)
                    AppText(
                      subtitle!,
                      variant: TextVariant.bodySm,
                      tone: TextTone.muted,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      );
      return FocusRing(visible: focused, radius: t.radius.sm, child: content);
    }

    if (onPressed == null) return row(false);
    return Pressable(
      onPressed: onPressed,
      stretch: true,
      builder: (BuildContext context, PressState s) => row(s.focused),
    );
  }
}
