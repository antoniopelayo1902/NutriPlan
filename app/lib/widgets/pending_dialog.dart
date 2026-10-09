import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Muestra un Dialog (alerta de prioridad alta) para los
/// botones cuya funcionalidad todavía no está implementada.
/// La entrega pide que TODO botón haga algo; los pendientes avisan qué harán.
void showPendingDialog(BuildContext context, String message) {
  final AppColors c = AppColors.of(context);

  // Abre la alerta encima de la pantalla actual.
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: c.card,
        title: Text('Funcionalidad pendiente', style: AppText.body(c, size: 20, weight: FontWeight.w600)),
        content: Text(message, style: AppText.muted(c, size: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c.inverse,
              foregroundColor: c.onInverse,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              // Cierra la alerta.
              Navigator.pop(dialogContext);
            },
            child: const Text('Entendido'),
          ),
        ],
      );
    },
  );
}

/// SnackBar corto (alerta de prioridad baja) para confirmar una acción.
void showInfoSnackBar(BuildContext context, String message) {
  // hideCurrentSnackBar evita que se encimen varios SnackBars.
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}
