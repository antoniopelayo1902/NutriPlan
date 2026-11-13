import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_text.dart';

/// Campo de texto con el mismo estilo que el login.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final AppIconName? icon;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radius.md),
      borderSide: BorderSide(color: t.colors.borderDefault),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: t.typo.bodyLg.copyWith(color: t.colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: t.typo.bodyMd.copyWith(color: t.colors.textMuted),
        prefixIcon: icon == null ? null : AppIcon(icon!, tone: TextTone.muted),
        errorText: errorText,
        errorStyle: t.typo.bodySm.copyWith(color: t.colors.dangerFg),
        filled: true,
        fillColor: t.colors.bgSurfaceSubtle,
        contentPadding: EdgeInsets.symmetric(
          horizontal: t.space.s4,
          vertical: t.space.s3,
        ),
        border: border,
        enabledBorder: border,
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: t.colors.dangerFg),
        ),
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: t.colors.accent,
            width: t.size.focusRingWidth,
          ),
        ),
      ),
    );
  }
}
