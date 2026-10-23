import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

enum BodySiteId {
  tricipital,
  bicipital,
  subescapular,
  suprailiaco,
  brazo,
  cintura,
  cadera,
  muslo,
}

class BodySiteData {
  const BodySiteData({
    required this.id,
    required this.label,
    required this.valueLabel,
  });

  final BodySiteId id;
  final String label;
  final String valueLabel;
}

class _SiteLayout {
  const _SiteLayout(this.id, this.left, this.u, this.v, this.labelY);

  final BodySiteId id;

  /// Label column: true for the viewer's left.
  final bool left;

  /// Anchor on the silhouette, normalized to the body box.
  final double u;
  final double v;

  /// Label vertical position, normalized to the map height.
  final double labelY;
}

const List<_SiteLayout> _layout = <_SiteLayout>[
  _SiteLayout(BodySiteId.bicipital, true, 0.14, 0.30, 0.20),
  _SiteLayout(BodySiteId.subescapular, true, 0.36, 0.28, 0.34),
  _SiteLayout(BodySiteId.cintura, true, 0.38, 0.46, 0.48),
  _SiteLayout(BodySiteId.muslo, true, 0.38, 0.72, 0.72),
  _SiteLayout(BodySiteId.tricipital, false, 0.86, 0.30, 0.20),
  _SiteLayout(BodySiteId.brazo, false, 0.84, 0.40, 0.34),
  _SiteLayout(BodySiteId.suprailiaco, false, 0.62, 0.50, 0.48),
  _SiteLayout(BodySiteId.cadera, false, 0.64, 0.58, 0.62),
];

/// Read-only front silhouette with leader lines to 8 anthropometric sites.
/// Each site label is focusable and has a semantics label. [onSiteSelect] is
/// optional and reserved for the future editable mode.
class BodyMap extends StatelessWidget {
  const BodyMap({super.key, required this.sites, this.onSiteSelect});

  final List<BodySiteData> sites;
  final ValueChanged<BodySiteId>? onSiteSelect;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = constraints.maxWidth;
        final double h = w * t.size.bodyMapAspect;
        final double bodyW = w * 0.42;
        final double bodyLeft = (w - bodyW) / 2;
        final double colW = bodyLeft - t.space.s2;
        final Map<BodySiteId, BodySiteData> byId = <BodySiteId, BodySiteData>{
          for (final BodySiteData s in sites) s.id: s,
        };
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _BodyPainter(
                      body: t.colors.bgTrack,
                      outline: t.colors.borderStrong,
                      line: t.colors.textFaint,
                      dot: t.colors.accent,
                      lineWidth: t.size.bodyMapLineWidth,
                      dotRadius: t.size.dot / 2,
                      colW: colW,
                      bodyLeft: bodyLeft,
                      bodyW: bodyW,
                    ),
                  ),
                ),
              ),
              for (final _SiteLayout l in _layout)
                if (byId[l.id] != null)
                  Positioned(
                    top: l.labelY * h - t.size.bodyMapLabelHeight / 2,
                    left: l.left ? 0 : null,
                    right: l.left ? null : 0,
                    width: colW,
                    height: t.size.bodyMapLabelHeight,
                    child: _SiteLabel(
                      data: byId[l.id]!,
                      alignEnd: l.left,
                      onSelect: onSiteSelect,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _SiteLabel extends StatelessWidget {
  const _SiteLabel({
    required this.data,
    required this.alignEnd,
    required this.onSelect,
  });

  final BodySiteData data;
  final bool alignEnd;
  final ValueChanged<BodySiteId>? onSelect;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    // Labels sit in fixed slots next to the silhouette, so they stop scaling
    // at 1.3x; the semantics label still carries the full text.
    final MediaQueryData mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(maxScaleFactor: t.size.tabMaxTextScale),
      ),
      child: Semantics(
        label: '${data.label} ${data.valueLabel}',
        focusable: true,
        button: onSelect != null,
        container: true,
        child: ExcludeSemantics(
          child: Focus(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSelect == null ? null : () => onSelect!(data.id),
              child: AppStack(
                gap: t.space.s0,
                justify: MainAxisAlignment.center,
                align: alignEnd
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  AppText(
                    data.label,
                    variant: TextVariant.caption,
                    tone: TextTone.muted,
                    maxLines: 1,
                  ),
                  AppText(
                    data.valueLabel,
                    variant: TextVariant.label,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.body,
    required this.outline,
    required this.line,
    required this.dot,
    required this.lineWidth,
    required this.dotRadius,
    required this.colW,
    required this.bodyLeft,
    required this.bodyW,
  });

  final Color body;
  final Color outline;
  final Color line;
  final Color dot;
  final double lineWidth;
  final double dotRadius;
  final double colW;
  final double bodyLeft;
  final double bodyW;

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    Offset at(double u, double v) => Offset(bodyLeft + u * bodyW, v * h);

    final Paint fill = Paint()
      ..color = body
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    final Paint limb = Paint()
      ..color = body
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = bodyW * 0.16;

    // Head and neck.
    canvas.drawCircle(at(0.5, 0.075), bodyW * 0.15, fill);
    canvas.drawCircle(at(0.5, 0.075), bodyW * 0.15, stroke);
    canvas.drawRect(
      Rect.fromCenter(
        center: at(0.5, 0.155),
        width: bodyW * 0.14,
        height: h * 0.04,
      ),
      fill,
    );
    // Torso.
    final RRect torso = RRect.fromRectAndRadius(
      Rect.fromPoints(at(0.26, 0.17), at(0.74, 0.56)),
      Radius.circular(bodyW * 0.14),
    );
    canvas.drawRRect(torso, fill);
    canvas.drawRRect(torso, stroke);
    // Arms and legs.
    canvas.drawLine(at(0.2, 0.2), at(0.08, 0.52), limb);
    canvas.drawLine(at(0.8, 0.2), at(0.92, 0.52), limb);
    canvas.drawLine(at(0.38, 0.58), at(0.36, 0.96), limb);
    canvas.drawLine(at(0.62, 0.58), at(0.64, 0.96), limb);

    final Paint leader = Paint()
      ..color = line
      ..strokeWidth = lineWidth;
    final Paint dotPaint = Paint()..color = dot;
    for (final _SiteLayout l in _layout) {
      final Offset anchor = at(l.u, l.v);
      final Offset labelEdge = Offset(
        l.left ? colW : size.width - colW,
        l.labelY * h,
      );
      canvas.drawLine(labelEdge, anchor, leader);
      canvas.drawCircle(anchor, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.body != body ||
      old.dot != dot ||
      old.bodyLeft != bodyLeft ||
      old.bodyW != bodyW ||
      old.colW != colW;
}
