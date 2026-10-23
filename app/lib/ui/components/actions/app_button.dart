import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import '../primitives/focus_ring.dart';
import '../primitives/pressable.dart';

enum ButtonVariant { primary, secondary, outlineAccent, outlineNeutral, ghost }

enum ButtonSize { md, lg }

/// The one button of the app.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.fullWidth = false,
    this.iconLeft,
    this.iconRight,
    this.loading = false,
    this.toggled,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;
  final AppIconName? iconLeft;
  final AppIconName? iconRight;
  final bool loading;

  /// Exposes toggle semantics (used by AppToggleButton).
  final bool? toggled;

  TextTone get _tone {
    if (onPressed == null && !loading) return TextTone.muted;
    switch (variant) {
      case ButtonVariant.primary:
        return TextTone.inverse;
      case ButtonVariant.outlineAccent:
        return TextTone.accent;
      case ButtonVariant.secondary:
      case ButtonVariant.outlineNeutral:
      case ButtonVariant.ghost:
        return TextTone.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final SemanticColors c = t.colors;
    final bool enabled = onPressed != null && !loading;
    final double height = size == ButtonSize.lg
        ? t.size.buttonLg
        : t.size.buttonMd;

    final bool disabled = onPressed == null && !loading;
    Color fill;
    Color? border;
    switch (variant) {
      case ButtonVariant.primary:
        fill = c.bgInverse;
      case ButtonVariant.secondary:
        fill = c.bgSurface;
      case ButtonVariant.outlineAccent:
        fill = c.transparent;
        border = c.accent;
      case ButtonVariant.outlineNeutral:
        fill = c.transparent;
        border = c.borderStrong;
      case ButtonVariant.ghost:
        fill = c.transparent;
    }
    if (disabled) {
      // Disabled keeps the label readable (muted tone, no opacity): the
      // state is carried by a flat track fill and a soft border instead.
      fill = variant == ButtonVariant.ghost ? c.transparent : c.bgTrack;
      border = variant == ButtonVariant.ghost ? null : c.borderDefault;
    }

    return Pressable(
      onPressed: enabled ? onPressed : null,
      toggled: toggled,
      minHeight: height,
      stretch: fullWidth,
      builder: (BuildContext context, PressState s) {
        final Color shown = s.pressed || s.hovered
            ? Color.alphaBlend(c.pressOverlay, fill)
            : fill;
        final Widget content = AppStack(
          direction: Axis.horizontal,
          gap: t.space.s2,
          justify: MainAxisAlignment.center,
          children: <Widget>[
            if (loading)
              SizedBox(
                width: t.size.spinner,
                height: t.size.spinner,
                child: CircularProgressIndicator(
                  strokeWidth: t.size.spinnerStroke,
                  color: textColorFor(t, _tone),
                ),
              )
            else if (iconLeft != null)
              AppIcon(iconLeft!, size: AppIconSize.sm, tone: _tone),
            Flexible(
              child: AppText(
                label,
                variant: TextVariant.label,
                tone: _tone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (iconRight != null && !loading)
              AppIcon(iconRight!, size: AppIconSize.sm, tone: _tone),
          ],
        );
        final Widget box = DecoratedBox(
          decoration: BoxDecoration(
            color: shown,
            borderRadius: BorderRadius.circular(t.radius.pill),
            border: border == null
                ? null
                : Border.all(color: border, width: t.size.borderWidth),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: t.space.s5),
              child: Center(widthFactor: fullWidth ? null : 1, child: content),
            ),
          ),
        );
        return FocusRing(visible: s.focused, radius: t.radius.pill, child: box);
      },
    );
  }
}
