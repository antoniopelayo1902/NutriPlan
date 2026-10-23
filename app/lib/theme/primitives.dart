import 'dart:ui';

/// Raw palette. This is the ONLY file in lib/ allowed to contain color
/// literals. Components never import this file; they use semantic tokens.
abstract final class Prim {
  static const Color sand0 = Color(0xFFFFFFFF);
  static const Color sand25 = Color(0xFFFFFCF8);
  static const Color sand50 = Color(0xFFFDFAF6);
  static const Color sand100 = Color(0xFFFAF6F1);
  static const Color sand150 = Color(0xFFF6EFE6);
  static const Color sand200 = Color(0xFFF2EAE1);
  static const Color sand300 = Color(0xFFE9DFD4);
  static const Color sand400 = Color(0xFFE4D8CB);
  static const Color sand500 = Color(0xFFDED2C6);
  static const Color sand600 = Color(0xFFB9A899);
  static const Color sand700 = Color(0xFF8A7A6C);
  static const Color sand800 = Color(0xFF6E5F53);
  static const Color sand850 = Color(0xFF574D46);
  static const Color sand900 = Color(0xFF2A2320);

  static const Color terracotta100 = Color(0xFFFBEFE7);
  static const Color terracotta200 = Color(0xFFEFD3C2);
  static const Color terracotta300 = Color(0xFFE7D3C2);
  static const Color terracotta500 = Color(0xFFD9613B);
  static const Color terracotta700 = Color(0xFFA8451F);

  static const Color olive100 = Color(0xFFEEF0E4);
  static const Color olive150 = Color(0xFFEDF0E5);
  static const Color olive500 = Color(0xFF5E7048);
  static const Color olive700 = Color(0xFF55693F);
  static const Color olive800 = Color(0xFF414A2F);
  static const Color olive900 = Color(0xFF3D4A2C);

  static const Color amber100 = Color(0xFFF7EEDC);
  static const Color amber500 = Color(0xFFC9902A);
  static const Color amber700 = Color(0xFF8A6415);

  static const Color brick100 = Color(0xFFF7E7E0);
  static const Color brick700 = Color(0xFF9B3B21);

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
