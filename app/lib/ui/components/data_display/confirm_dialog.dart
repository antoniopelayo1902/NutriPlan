import 'package:flutter/material.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../actions/app_button.dart';
import '../primitives/app_text.dart';

/// Alerta de confirmación (AlertDialog). Regresa true si el usuario acepta.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final bool? ok = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      final AppTokens t = context.tokens;
      return AlertDialog(
        backgroundColor: t.colors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radius.xl),
        ),
        title: AppText(title, variant: TextVariant.titleMd),
        content: AppText(body, tone: TextTone.secondary),
        actionsPadding: EdgeInsets.fromLTRB(
          t.space.s5,
          t.space.s0,
          t.space.s5,
          t.space.s5,
        ),
        actions: <Widget>[
          AppButton(
            key: const Key('dialogCancel'),
            label: S.cancel,
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton(
            key: const Key('dialogConfirm'),
            label: confirmLabel,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
