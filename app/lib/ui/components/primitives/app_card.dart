import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import 'focus_ring.dart';
import 'pressable.dart';

enum CardTone {
  surface,
  subtle,
  inverse,
  accentSoft,
  highlightSoft,
  message,
  success,
  info,
  neutralDashed,
}

enum CardElevation { card, item, none }

/// Every white or colored panel. Pass [onTap] to make it pressable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation = CardElevation.card,
    this.tone = CardTone.surface,
    this.radius,
    this.onTap,
    this.semanticLabel,
    this.topStrip,
    this.backdrop,
  });

  final Widget child;

  /// Defaults to the `space4` token.
  final double? padding;
  final CardElevation elevation;
  final CardTone tone;
  final double? radius;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// Thin decorative band flush with the card's top edge (clipped to it).
  final Widget? topStrip;

  /// Decorative layer painted behind the content (clipped to the card).
  final Widget? backdrop;

  Color _fill(SemanticColors c) {
    switch (tone) {
      case CardTone.surface:
        return c.bgSurface;
      case CardTone.subtle:
        return c.bgSurfaceSubtle;
      case CardTone.inverse:
        return c.bgInverse;
      case CardTone.accentSoft:
        return c.accentSoft;
      case CardTone.highlightSoft:
        return c.highlightSoft;
      case CardTone.message:
        return c.messageSoft;
      case CardTone.success:
        return c.successBg;
      case CardTone.info:
        return c.infoBg;
      case CardTone.neutralDashed:
        return c.transparent;
    }
  }

  Widget _content(double pad, double r) {
    Widget body = Padding(padding: EdgeInsets.all(pad), child: child);
    if (topStrip == null && backdrop == null) return body;
    if (topStrip != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[topStrip!, body],
      );
    }
    if (backdrop != null) {
      body = Stack(
        children: <Widget>[
          Positioned.fill(child: backdrop!),
          body,
        ],
      );
    }
    return ClipRRect(borderRadius: BorderRadius.circular(r), child: body);
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final double r = radius ?? t.radius.xl;
    final double pad = padding ?? t.space.s4;

    Widget paint(bool hovered, bool focused) {
      List<BoxShadow>? shadows;
      if (elevation == CardElevation.card) {
        shadows = hovered ? t.shadow.hover : t.shadow.card;
      } else if (elevation == CardElevation.item) {
        shadows = hovered ? t.shadow.hover : t.shadow.item;
      }
      final bool dashed = tone == CardTone.neutralDashed;
      Widget box = DecoratedBox(
        decoration: BoxDecoration(
          color: _fill(t.colors),
          borderRadius: BorderRadius.circular(r),
          boxShadow: dashed ? null : shadows,
        ),
        position: DecorationPosition.background,
        child: _content(pad, r),
      );
      if (dashed) {
        box = CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: t.colors.borderStrong,
            radius: r,
            strokeWidth: t.size.borderWidth,
            dash: t.space.s2,
            gap: t.space.s1,
          ),
          child: box,
        );
      }
      return FocusRing(visible: focused, radius: r, child: box);
    }

    if (onTap == null) return paint(false, false);
    return Pressable(
      onPressed: onTap,
      semanticLabel: semanticLabel,
      minHeight: t.size.hitMin,
      stretch: true,
      builder: (BuildContext context, PressState s) =>
          paint(s.hovered, s.focused),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}
