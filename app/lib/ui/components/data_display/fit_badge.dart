import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/fit.dart';
import 'app_badge.dart';

/// Traffic-light badge mapped to the fit tokens and i18n labels.
class FitBadge extends StatelessWidget {
  const FitBadge(this.fit, {super.key});

  final Fit fit;

  static BadgeTone toneOf(Fit fit) {
    switch (fit) {
      case Fit.yes:
        return BadgeTone.success;
      case Fit.adjust:
        return BadgeTone.warning;
      case Fit.no:
        return BadgeTone.danger;
    }
  }

  static String labelOf(Fit fit) {
    switch (fit) {
      case Fit.yes:
        return S.fitYes;
      case Fit.adjust:
        return S.fitAdjust;
      case Fit.no:
        return S.fitNo;
    }
  }

  @override
  Widget build(BuildContext context) =>
      AppBadge(labelOf(fit), tone: toneOf(fit));
}
