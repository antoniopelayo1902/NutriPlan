import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';

/// Placeholder block. Pulses its opacity; static when animations are
/// disabled.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.height, this.width, this.radius});

  final double? height;
  final double? width;
  final double? radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppTokens t = context.tokens;
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller?.dispose();
      _controller = null;
    } else {
      _controller ??= AnimationController(vsync: this, duration: t.motion.pulse)
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final Widget block = DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.bgEmpty,
        borderRadius: BorderRadius.circular(widget.radius ?? t.radius.md),
      ),
      child: SizedBox(
        height: widget.height ?? t.size.skeletonLine,
        width: widget.width,
      ),
    );
    final AnimationController? c = _controller;
    if (c == null) return block;
    return FadeTransition(
      opacity: Tween<double>(begin: t.size.pulseLow, end: 1).animate(c),
      child: block,
    );
  }
}
