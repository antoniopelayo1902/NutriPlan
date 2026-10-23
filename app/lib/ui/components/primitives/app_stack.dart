import 'package:flutter/widgets.dart';

/// Flex layout with a token gap. All layout goes through AppStack/AppGrid.
class AppStack extends StatelessWidget {
  const AppStack({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.gap = 0,
    this.align,
    this.justify = MainAxisAlignment.start,
    this.wrap = false,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;
  final Axis direction;

  /// Space between children; pass a token value (for example `t.space.s3`).
  final double gap;

  /// Defaults to stretch for vertical stacks and center for horizontal ones.
  final CrossAxisAlignment? align;
  final MainAxisAlignment justify;
  final bool wrap;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment cross =
        align ??
        (direction == Axis.vertical
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center);
    if (wrap) {
      return Wrap(
        direction: direction,
        spacing: gap,
        runSpacing: gap,
        alignment: _wrapAlign(justify),
        crossAxisAlignment: _wrapCross(cross),
        children: children,
      );
    }
    return Flex(
      direction: direction,
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: justify,
      crossAxisAlignment: cross,
      spacing: gap,
      children: children,
    );
  }

  static WrapAlignment _wrapAlign(MainAxisAlignment a) {
    switch (a) {
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
      case MainAxisAlignment.start:
        return WrapAlignment.start;
    }
  }

  static WrapCrossAlignment _wrapCross(CrossAxisAlignment a) {
    switch (a) {
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      default:
        return WrapCrossAlignment.start;
    }
  }
}
