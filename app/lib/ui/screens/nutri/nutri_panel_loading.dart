import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/skeleton.dart';

/// Placeholder cards while a patient tab loads.
class NutriPanelLoading extends StatelessWidget {
  const NutriPanelLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      gap: t.space.s3,
      children: <Widget>[
        for (int i = 0; i < 2; i++)
          Skeleton(height: t.size.skeletonCard, radius: t.radius.xl),
      ],
    );
  }
}
