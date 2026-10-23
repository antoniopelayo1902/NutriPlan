import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_text.dart';

/// Dark pill message. Positioning and queueing live in the shell.
class AppToast extends StatelessWidget {
  const AppToast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: t.size.toastMaxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.bgInverse,
              borderRadius: BorderRadius.circular(t.radius.lg),
              boxShadow: t.shadow.float,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: t.space.s4,
                vertical: t.space.s3,
              ),
              child: AppText(
                message,
                variant: TextVariant.bodySm,
                tone: TextTone.inverse,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
