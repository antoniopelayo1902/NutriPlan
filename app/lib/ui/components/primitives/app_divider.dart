import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.inset = 0});

  /// Horizontal inset, usually a space token.
  final double inset;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: SizedBox(
        height: t.size.borderWidth,
        child: ColoredBox(color: t.colors.divider),
      ),
    );
  }
}
