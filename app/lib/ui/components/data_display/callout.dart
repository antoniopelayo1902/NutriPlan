import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_card.dart';
import '../primitives/app_text.dart';

enum CalloutTone { info, accentSoft, message, success, neutralDashed }

class Callout extends StatelessWidget {
  const Callout(this.text, {super.key, this.tone = CalloutTone.info});

  final String text;
  final CalloutTone tone;

  CardTone get _cardTone {
    switch (tone) {
      case CalloutTone.info:
        return CardTone.info;
      case CalloutTone.accentSoft:
        return CardTone.accentSoft;
      case CalloutTone.message:
        return CardTone.message;
      case CalloutTone.success:
        return CardTone.success;
      case CalloutTone.neutralDashed:
        return CardTone.neutralDashed;
    }
  }

  TextTone get _textTone {
    switch (tone) {
      case CalloutTone.info:
        return TextTone.info;
      case CalloutTone.success:
        return TextTone.success;
      case CalloutTone.message:
        return TextTone.message;
      case CalloutTone.accentSoft:
        return TextTone.accent;
      case CalloutTone.neutralDashed:
        return TextTone.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      tone: _cardTone,
      elevation: CardElevation.none,
      radius: t.radius.lg,
      child: AppText(text, variant: TextVariant.bodyMd, tone: _textTone),
    );
  }
}
