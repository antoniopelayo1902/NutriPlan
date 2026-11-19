import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../application/toast_controller.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/plan_share_service.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../login/auth_gate.dart';
import '../page_frame.dart';

/// Factor WOW (parte 1): el QR con el código del plan del paciente, o el
/// código del nutriólogo para vincular pacientes si [nutritionist].
class SharePlanScreen extends StatelessWidget {
  const SharePlanScreen({super.key, this.nutritionist = false});

  final bool nutritionist;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final String uid = AuthScope.maybeOf(context)?.uid ?? '';
    final String code = nutritionist
        ? PlanShareService.nutriCodeFor(uid)
        : PlanShareService.codeFor(uid);
    return PageFrame(
      eyebrow: S.wowEyebrow,
      title: nutritionist ? S.nutriCodeTitle : S.sharePlanTitle,
      children: <Widget>[
        AppCard(
          child: AppStack(
            gap: t.space.s4,
            align: CrossAxisAlignment.center,
            children: <Widget>[
              AppText(
                nutritionist ? S.nutriCodeBody : S.sharePlanBody,
                tone: TextTone.secondary,
                textAlign: TextAlign.center,
              ),
              // qr_flutter dibuja el QR con el texto del código.
              QrImageView(
                key: const Key('planQr'),
                data: code,
                size: t.size.qrSize,
                backgroundColor: t.colors.bgSurface,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: t.colors.textPrimary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: t.colors.textPrimary,
                ),
              ),
              AppButton(
                key: const Key('copyCodeButton'),
                label: S.copyCode,
                variant: ButtonVariant.outlineNeutral,
                onPressed: () async {
                  final ToastController toast = context.read<ToastController>();
                  await Clipboard.setData(ClipboardData(text: code));
                  toast.show(S.codeCopied);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
