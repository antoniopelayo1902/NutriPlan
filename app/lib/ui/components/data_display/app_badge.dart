import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_text.dart';

enum BadgeTone {
  success,
  warning,
  danger,
  info,
  accent,
  message,
  highlight,
  neutral,
}

class AppBadge extends StatelessWidget {
  const AppBadge(this.label, {super.key, this.tone = BadgeTone.neutral});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final SemanticColors c = t.colors;
    Color fill;
    TextTone text;
    switch (tone) {
      case BadgeTone.success:
        fill = c.successBg;
        text = TextTone.success;
      case BadgeTone.warning:
        fill = c.warningBg;
        text = TextTone.warning;
      case BadgeTone.danger:
        fill = c.dangerBg;
        text = TextTone.danger;
      case BadgeTone.info:
        fill = c.infoBg;
        text = TextTone.info;
      case BadgeTone.accent:
        fill = c.accentSoft;
        text = TextTone.accent;
      case BadgeTone.message:
        fill = c.messageSoft;
        text = TextTone.message;
      case BadgeTone.highlight:
        fill = c.bgSurface;
        text = TextTone.highlight;
      case BadgeTone.neutral:
        fill = c.bgTrack;
        text = TextTone.secondary;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(t.radius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: t.space.s2,
          vertical: t.space.s1,
        ),
        child: AppText(label, variant: TextVariant.caption, tone: text),
      ),
    );
  }
}
