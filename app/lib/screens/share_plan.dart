import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/measures.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_card.dart';

/// Muestra el plan publicado como código QR para que el paciente lo escanee.
///
/// PAQUETE NUEVO: qr_flutter. Su widget QrImageView dibuja un código QR
/// a partir de un texto. El texto es el plan convertido a JSON.
class SharePlanScreen extends StatelessWidget {
  const SharePlanScreen({super.key, required this.patient, required this.portions});

  final Patient patient;
  final Map<String, int> portions;

  /// Convierte el plan en un texto corto: "NP1." + JSON en base64.
  String get planCode {
    final Map<String, dynamic> plan = {'paciente': patient.name, 'porciones': portions};
    // Convierte el mapa a texto JSON.
    final String json = jsonEncode(plan);
    return 'NP1.${base64Url.encode(utf8.encode(json))}';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);
    final String firstName = patient.name.split(' ')[0];
    final String code = planCode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        title: Text('Plan publicado', style: AppText.body(c, size: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          Text('Listo para $firstName', style: AppText.kicker(c, color: c.green)),
          Text('Comparte su plan', style: AppText.title(c)),
          const SizedBox(height: 8),
          Text('$firstName escanea este código desde "Importar plan" en su app.', style: AppText.muted(c)),
          const SizedBox(height: 20),
          SectionCard(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                // El QR siempre va sobre blanco para que la cámara lo lea bien.
                color: Colors.white,
                child: QrImageView(
                  key: const Key('planQr'),
                  // Texto que se guarda dentro del QR.
                  data: code,
                  size: 240,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF2B2320)),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF2B2320),
                  ),
                ),
              ),
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código del plan', style: AppText.cardLabel(c)),
                const SizedBox(height: 8),
                Text(code, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.mono(c)),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Copiar código',
                  accent: true,
                  onPressed: () {
                    // Clipboard: guarda el texto en el portapapeles.
                    Clipboard.setData(ClipboardData(text: code));
                    showInfoSnackBar(context, 'Código copiado. Ya lo puedes pegar en WhatsApp.');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PillButton(
                  label: 'Enviar a $firstName',
                  selected: true,
                  onPressed: () {
                    showPendingDialog(
                      context,
                      'Aquí el plan se enviará directo a la app de $firstName, sin que tenga que escanear nada.',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
