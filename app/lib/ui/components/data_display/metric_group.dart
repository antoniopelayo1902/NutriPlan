import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import 'metric.dart';

/// Wrapping row of small metrics.
class MetricGroup extends StatelessWidget {
  const MetricGroup({super.key, required this.items});

  final List<Metric> items;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      direction: Axis.horizontal,
      wrap: true,
      gap: t.space.s5,
      align: CrossAxisAlignment.start,
      children: items,
    );
  }
}
