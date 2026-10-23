import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_text.dart';

enum AvatarTone { accent, neutral, inverse }

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    this.size,
    this.tone = AvatarTone.accent,
    this.semanticLabel,
  });

  final String initials;

  /// Defaults to the `avatarMd` token.
  final double? size;
  final AvatarTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double dim = size ?? t.size.avatarMd;
    Color fill;
    TextTone text;
    switch (tone) {
      case AvatarTone.accent:
        fill = t.colors.accentSoft;
        text = TextTone.accent;
      case AvatarTone.neutral:
        fill = t.colors.bgTrack;
        text = TextTone.secondary;
      case AvatarTone.inverse:
        fill = t.colors.bgInverse;
        text = TextTone.inverse;
    }
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        excluding: semanticLabel != null,
        child: DecoratedBox(
          decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
          child: SizedBox(
            width: dim,
            height: dim,
            child: Center(
              child: AppText(initials, variant: TextVariant.label, tone: text),
            ),
          ),
        ),
      ),
    );
  }
}
