import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';

/// One band of a [PortionStrip]; [weight] is the number of portions.
class PortionStripSegment {
  const PortionStripSegment(this.color, this.weight);

  final Color color;
  final double weight;
}

/// Thin decorative bar split proportionally to the portions per food group.
class PortionStrip extends StatelessWidget {
  const PortionStrip({super.key, required this.segments});

  final List<PortionStripSegment> segments;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ExcludeSemantics(
      child: SizedBox(
        height: t.size.mealStrip,
        child: Row(
          children: <Widget>[
            for (final PortionStripSegment s in segments)
              Expanded(
                flex: (s.weight * 2).round().clamp(1, 1000),
                child: ColoredBox(
                  color: s.color,
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
