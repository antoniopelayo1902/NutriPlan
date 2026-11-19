import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// Rounded, filled input look shared by the login fields.
InputDecoration loginFieldDecoration(AppTokens t, String label, IconData icon) {
  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(t.radius.md),
    borderSide: BorderSide(color: t.colors.borderDefault),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: t.typo.bodyMd.copyWith(color: t.colors.textMuted),
    prefixIcon: Icon(icon, color: t.colors.textMuted),
    filled: true,
    fillColor: t.colors.bgSurfaceSubtle,
    contentPadding: EdgeInsets.symmetric(
      horizontal: t.space.s4,
      vertical: t.space.s3,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(
        color: t.colors.accent,
        width: t.size.focusRingWidth,
      ),
    ),
  );
}
