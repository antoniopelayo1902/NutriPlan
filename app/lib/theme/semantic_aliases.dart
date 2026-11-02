import 'package:flutter/painting.dart';

import 'semantic_colors.dart';

/// Older names and Huerta convenience getters over [SemanticColors].
extension SemanticColorAliases on SemanticColors {
  /// Solid app canvas as a gradient (kept for the shell background).
  LinearGradient get bgAppGradient =>
      LinearGradient(colors: <Color>[bgApp, bgApp]);

  Color get bgInverse => primary;
  Color get textInverse => primaryInk;
  Color get accentInk => textAccent;

  Color get successBg => fit.yesBg;
  Color get successFg => fit.yesFg;
  Color get warningBg => fit.adjustBg;
  Color get warningFg => fit.adjustFg;
  Color get dangerBg => fit.noBg;
  Color get dangerFg => fit.noFg;
  Color get infoBg => secondarySoft;
  Color get infoFg => secondaryInk;

  Color get fitYes => fit.yes;
  Color get fitYesBg => fit.yesBg;
  Color get fitYesFg => fit.yesFg;
  Color get fitAdjust => fit.adjust;
  Color get fitAdjustBg => fit.adjustBg;
  Color get fitAdjustFg => fit.adjustFg;
  Color get fitNo => fit.no;
  Color get fitNoBg => fit.noBg;
  Color get fitNoFg => fit.noFg;

  Color get foodVerdura => food.verdura.solid;
  Color get foodVerduraSoft => food.verdura.soft;
  Color get foodFruta => food.fruta.solid;
  Color get foodFrutaSoft => food.fruta.soft;
  Color get foodCereal => food.cereal.solid;
  Color get foodCerealSoft => food.cereal.soft;
  Color get foodAoa => food.aoa.solid;
  Color get foodAoaSoft => food.aoa.soft;
  Color get foodLeguminosa => food.leguminosa.solid;
  Color get foodLeguminosaSoft => food.leguminosa.soft;
  Color get foodLeche => food.leche.solid;
  Color get foodLecheSoft => food.leche.soft;
  Color get foodGrasa => food.grasa.solid;
  Color get foodGrasaSoft => food.grasa.soft;
}
