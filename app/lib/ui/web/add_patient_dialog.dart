import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/nutri_controller.dart';
import '../../application/toast_controller.dart';
import '../../core/i18n/strings_es_mx.dart';
import '../../core/i18n/strings_web_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../../theme/tokens_web.dart';
import '../components/actions/app_button.dart';
import '../components/actions/app_text_field.dart';
import '../components/primitives/app_icon.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/app_text.dart';
import '../screens/profile/share_plan_screen.dart';

/// Opens the "add patient" dialog: a manual record form, or the nutritionist
/// QR code for patients who link from their own account.
Future<void> showAddPatientDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (BuildContext _) => const AddPatientDialog(),
);

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _objective = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _objective.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = SWeb.addPatientNameRequired);
      return;
    }
    final NutriController nutri = context.read<NutriController>();
    final ToastController toast = context.read<ToastController>();
    final NavigatorState nav = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final bool ok = await nutri.addPatient(
      _name.text,
      _email.text,
      _objective.text,
    );
    toast.show(ok ? SWeb.addPatientDone : S.actionFailed);
    if (ok) {
      nav.pop();
    } else if (mounted) {
      setState(() => _saving = false);
    }
  }

  void _openCode() {
    final NavigatorState nav = Navigator.of(context);
    nav.pop();
    nav.push(
      MaterialPageRoute<void>(
        builder: (BuildContext _) => const SharePlanScreen(nutritionist: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Dialog(
      backgroundColor: t.colors.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radius.xl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: t.size.webLoginCard),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(t.space.s6),
          child: AppStack(
            gap: t.space.s4,
            children: <Widget>[
              const AppText(SWeb.addPatientTitle, variant: TextVariant.titleMd),
              const AppText(SWeb.addPatientBody, tone: TextTone.secondary),
              AppTextField(
                key: const Key('addPatientName'),
                controller: _name,
                label: SWeb.addPatientName,
                errorText: _error,
              ),
              AppTextField(
                key: const Key('addPatientEmail'),
                controller: _email,
                label: SWeb.addPatientEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              AppTextField(
                key: const Key('addPatientObjective'),
                controller: _objective,
                label: SWeb.addPatientObjective,
              ),
              const AppText(
                SWeb.addPatientNote,
                variant: TextVariant.caption,
                tone: TextTone.muted,
              ),
              AppButton(
                key: const Key('addPatientCreate'),
                label: SWeb.addPatientCreate,
                fullWidth: true,
                loading: _saving,
                onPressed: _saving ? null : _create,
              ),
              const AppText(
                SWeb.addPatientOr,
                variant: TextVariant.caption,
                tone: TextTone.muted,
                textAlign: TextAlign.center,
              ),
              AppButton(
                key: const Key('addPatientCode'),
                label: S.shareMyCode,
                iconLeft: AppIconName.qr,
                variant: ButtonVariant.outlineAccent,
                fullWidth: true,
                onPressed: _saving ? null : _openCode,
              ),
              AppButton(
                label: S.cancel,
                variant: ButtonVariant.ghost,
                fullWidth: true,
                onPressed: _saving ? null : () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
