import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.body, this.action});

  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Padding(
      padding: EdgeInsets.all(t.space.s6),
      child: AppStack(
        gap: t.space.s3,
        align: CrossAxisAlignment.center,
        children: <Widget>[
          AppText(
            title,
            variant: TextVariant.bodyLg,
            textAlign: TextAlign.center,
          ),
          if (body != null)
            AppText(
              body!,
              variant: TextVariant.bodyMd,
              tone: TextTone.muted,
              textAlign: TextAlign.center,
            ),
          ?action,
        ],
      ),
    );
  }
}
