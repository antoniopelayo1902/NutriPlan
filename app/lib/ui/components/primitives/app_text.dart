import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';

/// Typographic roles, one per entry of the type ramp.
enum TextVariant {
  displayXl,
  displayLg,
  titleLg,
  titleMd,
  metricMd,
  metricSm,
  metricXs,
  eyebrow,
  bodyLg,
  bodyMd,
  bodySm,
  caption,
  label,
  micro,
}

enum TextTone {
  primary,
  secondary,
  muted,
  faint,
  accent,
  inverse,
  info,
  highlight,
  message,
  success,
  warning,
  danger,
}

TextStyle textStyleFor(AppTokens t, TextVariant v) {
  switch (v) {
    case TextVariant.displayXl:
      return t.typo.displayXl;
    case TextVariant.displayLg:
      return t.typo.displayLg;
    case TextVariant.titleLg:
      return t.typo.titleLg;
    case TextVariant.titleMd:
      return t.typo.titleMd;
    case TextVariant.metricMd:
      return t.typo.metricMd;
    case TextVariant.metricSm:
      return t.typo.metricSm;
    case TextVariant.metricXs:
      return t.typo.metricXs;
    case TextVariant.eyebrow:
      return t.typo.eyebrow;
    case TextVariant.bodyLg:
      return t.typo.bodyLg;
    case TextVariant.bodyMd:
      return t.typo.bodyMd;
    case TextVariant.bodySm:
      return t.typo.bodySm;
    case TextVariant.caption:
      return t.typo.caption;
    case TextVariant.label:
      return t.typo.label;
    case TextVariant.micro:
      return t.typo.micro;
  }
}

Color textColorFor(AppTokens t, TextTone tone) {
  final SemanticColors c = t.colors;
  switch (tone) {
    case TextTone.primary:
      return c.textPrimary;
    case TextTone.secondary:
      return c.textSecondary;
    case TextTone.muted:
      return c.textMuted;
    case TextTone.faint:
      return c.textFaint;
    case TextTone.accent:
      return c.textAccent;
    case TextTone.inverse:
      return c.textInverse;
    case TextTone.info:
      return c.infoFg;
    case TextTone.highlight:
      return c.highlightInk;
    case TextTone.message:
      return c.messageInk;
    case TextTone.success:
      return c.successFg;
    case TextTone.warning:
      return c.warningFg;
    case TextTone.danger:
      return c.dangerFg;
  }
}

/// The only way to render text.
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = TextVariant.bodyMd,
    this.tone = TextTone.primary,
    this.color,
    this.maxLines,
    this.textAlign,
    this.overflow,
  });

  final String text;
  final TextVariant variant;
  final TextTone tone;

  /// Overrides [tone] (for example a food-group ink color).
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      style: textStyleFor(
        t,
        variant,
      ).copyWith(color: color ?? textColorFor(t, tone)),
    );
  }
}
