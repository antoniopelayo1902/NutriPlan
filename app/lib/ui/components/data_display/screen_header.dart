import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import 'eyebrow.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      direction: Axis.horizontal,
      gap: t.space.s3,
      align: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: AppStack(
            gap: t.space.s1,
            align: CrossAxisAlignment.start,
            children: <Widget>[
              Eyebrow(eyebrow),
              Semantics(
                header: true,
                child: AppText(title, variant: TextVariant.titleLg),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
