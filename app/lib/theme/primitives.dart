import 'dart:ui';

export 'primitives_food.dart';
export 'primitives_scales.dart';

/// Raw palette. Together with its primitives_*.dart siblings this is the ONLY
/// code in lib/ allowed to contain color literals. Components never import it;
/// they use semantic tokens.
abstract final class Prim {
  static const Color sand0 = Color(0xFFFFFFFF);
  static const Color sand25 = Color(0xFFFFFCF8);
  static const Color sand200 = Color(0xFFF2EAE1);
  static const Color sand350 = Color(0xFFEDE3D8);
  static const Color sand400 = Color(0xFFE4D8CB);
  static const Color sand450 = Color(0xFFE5DBD0);
  static const Color sand500 = Color(0xFFDED2C6);
  static const Color sand600 = Color(0xFFB9A899);
  static const Color sand800 = Color(0xFF6E5F53);
  static const Color sand850 = Color(0xFF574D46);
  static const Color sand900 = Color(0xFF2A2320);

  /// App canvas (tokens.json bg-app).
  static const Color canvas = Color(0xFFF7F1E8);

  /// Text on the primary (deep green) fill.
  static const Color inkOnDeep = Color(0xFFF3EEE4);

  /// Small text on the default accent (AA on white).
  static const Color accentInk = Color(0xFFA8451F);
  static const Color accentSoft = Color(0xFFFBE6DA);
  static const Color accentMuted = Color(0xFFEFD3C2);

  static const Color secondarySoft = Color(0xFFE2EFE6);
  static const Color highlightSoft = Color(0xFFFBEFD3);
  static const Color messageSoft = Color(0xFFF3E3EC);

  static const Color fitYesBg = Color(0xFFE3F1E7);
  static const Color fitYesFg = Color(0xFF22603D);
  static const Color fitAdjustBg = Color(0xFFFBEFD3);
  static const Color fitAdjustFg = Color(0xFF7E560B);
  static const Color fitNoBg = Color(0xFFF9E2DA);
  static const Color fitNoFg = Color(0xFF8E2E15);

  static const Color foodVerduraSoft = Color(0xFFE2F0E3);
  static const Color foodFrutaSoft = Color(0xFFFBE4DF);
  static const Color foodCerealSoft = Color(0xFFF8ECD3);
  static const Color foodAoaSoft = Color(0xFFF6E3DC);
  static const Color foodLeguminosaSoft = Color(0xFFF0E4DA);
  static const Color foodLecheSoft = Color(0xFFE3EDF6);
  static const Color foodGrasaSoft = Color(0xFFF5F0D2);

  /// Fully transparent.
  static const Color transparent = Color(0x00000000);

  /// Warm shadow ink (rgb 74,50,32) at the alphas used by the elevation specs.
  static const Color shadowInk05 = Color.fromRGBO(74, 50, 32, 0.05);
  static const Color shadowInk20 = Color.fromRGBO(74, 50, 32, 0.20);
  static const Color shadowInk22 = Color.fromRGBO(74, 50, 32, 0.22);
  static const Color shadowInk30 = Color.fromRGBO(74, 50, 32, 0.30);
  static const Color shadowInk06 = Color.fromRGBO(74, 50, 32, 0.06);

  /// White highlight used by the floating tab bar.
  static const Color highlight70 = Color.fromRGBO(255, 255, 255, 0.7);

  /// Translucent surface behind the blurred tab bar.
  static const Color glass85 = Color.fromRGBO(255, 255, 255, 0.85);

  /// Pressed-state overlay (sand-900 at 8%).
  static const Color pressOverlay = Color.fromRGBO(42, 35, 32, 0.08);
}
