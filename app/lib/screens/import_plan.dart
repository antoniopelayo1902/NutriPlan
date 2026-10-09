import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/pill_button.dart';
import '../widgets/section_card.dart';

/// Importar el plan que comparte la nutrióloga: escaneando su QR o
/// pegando el código. Aquí irá el "Factor WOW" (cámara + QR).
class ImportPlanScreen extends StatefulWidget {
  const ImportPlanScreen({super.key});

  @override
  State<ImportPlanScreen> createState() => _ImportPlanScreenState();
}

class _ImportPlanScreenState extends State<ImportPlanScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _import() {
    final String code = _codeController.text.trim();
    if (code.isEmpty) {
      showInfoSnackBar(context, 'Pega primero el código que te compartió tu nutrióloga.');
      return;
    }
    // Los códigos de NutriPlan siempre empiezan con NP1.
    if (!code.startsWith('NP1.')) {
      showInfoSnackBar(context, 'Ese código no es de NutriPlan. Debe empezar con NP1.');
      return;
    }
    showPendingDialog(
      context,
      'El código es válido. Aquí se leerá el plan y se guardará en tu teléfono, reemplazando el actual.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        title: Text('Importar plan', style: AppText.body(c, size: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          Text('De tu nutrióloga', style: AppText.kicker(c)),
          Text('Importar plan', style: AppText.title(c)),
          const SizedBox(height: 20),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Escanea su código QR', style: AppText.cardLabel(c)),
                const SizedBox(height: 14),
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.border, width: 1.3),
                  ),
                  child: Icon(Icons.qr_code_scanner, size: 72, color: c.textFaint),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(
                    label: 'Abrir cámara',
                    selected: true,
                    onPressed: () {
                      showPendingDialog(context, 'Aquí se activará la cámara para escanear el QR de tu nutrióloga.');
                    },
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O pega el código', style: AppText.cardLabel(c)),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('codeField'),
                  controller: _codeController,
                  maxLines: 3,
                  // Botón "Listo" en el teclado para cerrarlo.
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'NP1.…',
                    filled: true,
                    fillColor: c.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: PillButton(label: 'Importar', accent: true, onPressed: _import),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
