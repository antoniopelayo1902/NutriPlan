import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'primitives.dart';

/// Traffic-light colors: a solid, a soft background and a dark text color per
/// verdict (tokens.json fit-*).
@immutable
class FitPalette {
  const FitPalette({
    required this.yes,
    required this.yesBg,
    required this.yesFg,
    required this.adjust,
    required this.adjustBg,
    required this.adjustFg,
    required this.no,
    required this.noBg,
    required this.noFg,
  });

  static const FitPalette base = FitPalette(
    yes: Hue.ok500,
    yesBg: Prim.fitYesBg,
    yesFg: Prim.fitYesFg,
    adjust: Hue.warn500,
    adjustBg: Prim.fitAdjustBg,
    adjustFg: Prim.fitAdjustFg,
    no: Hue.danger500,
    noBg: Prim.fitNoBg,
    noFg: Prim.fitNoFg,
  );

  final Color yes;
  final Color yesBg;
  final Color yesFg;
  final Color adjust;
  final Color adjustBg;
  final Color adjustFg;
  final Color no;
  final Color noBg;
  final Color noFg;

  static FitPalette lerp(FitPalette a, FitPalette b, double t) {
    Color l(Color x, Color y) => Color.lerp(x, y, t) ?? y;
    return FitPalette(
      yes: l(a.yes, b.yes),
      yesBg: l(a.yesBg, b.yesBg),
      yesFg: l(a.yesFg, b.yesFg),
      adjust: l(a.adjust, b.adjust),
      adjustBg: l(a.adjustBg, b.adjustBg),
      adjustFg: l(a.adjustFg, b.adjustFg),
      no: l(a.no, b.no),
      noBg: l(a.noBg, b.noBg),
      noFg: l(a.noFg, b.noFg),
    );
  }
}
