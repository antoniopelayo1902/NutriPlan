import 'package:flutter/widgets.dart';

/// Equal-width grid with a token gap; rows wrap automatically.
class AppGrid extends StatelessWidget {
  const AppGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.gap = 0,
  });

  final List<Widget> children;
  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final Widget c in children) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }
}
