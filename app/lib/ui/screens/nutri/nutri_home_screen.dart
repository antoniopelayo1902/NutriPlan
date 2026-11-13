import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/nutri_controller.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/patient_summary.dart';
import '../../../application/account_identity.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/data_display/avatar.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/list_item.dart';
import '../../components/data_display/profile_avatar_button.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_divider.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../../components/primitives/skeleton.dart';
import '../page_frame.dart';
import '../profile/share_plan_screen.dart';
import 'nutri_patient_screen.dart';

/// Inicio de la nutrióloga: la lista de sus pacientes desde Firestore.
class NutriHomeScreen extends StatelessWidget {
  const NutriHomeScreen({super.key});

  void _open(BuildContext context, Widget screen) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (BuildContext _) => screen),
  );

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final NutriController nutri = context.watch<NutriController>();
    return PageFrame(
      eyebrow: S.nutriEyebrow,
      title: S.patientsTitle,
      showBack: false,
      trailing: const ProfileAvatarButton(),
      // Swipe down: vuelve a leer la lista de Firestore.
      onRefresh: nutri.refresh,
      children: <Widget>[
        if (nutri.loading)
          AppStack(
            gap: t.space.s3,
            children: <Widget>[
              for (int i = 0; i < 3; i++)
                Skeleton(height: t.size.skeletonCard, radius: t.radius.xl),
            ],
          )
        else if (nutri.hasError && nutri.patients.isEmpty)
          EmptyState(
            title: S.errorTitle,
            body: S.errorBody,
            action: AppButton(label: S.retry, onPressed: nutri.load),
          )
        else if (nutri.patients.isEmpty)
          EmptyState(
            key: const Key('noPatients'),
            title: S.patientsEmptyTitle,
            body: S.patientsEmptyBody,
            action: AppButton(
              key: const Key('emptyShareCodeButton'),
              label: S.shareMyCode,
              iconLeft: AppIconName.qr,
              onPressed: () =>
                  _open(context, const SharePlanScreen(nutritionist: true)),
            ),
          )
        else
          AppCard(
            padding: t.space.s5,
            child: AppStack(
              gap: t.space.s2,
              children: <Widget>[
                Eyebrow(S.patientCount(nutri.patients.length)),
                for (int i = 0; i < nutri.patients.length; i++) ...<Widget>[
                  if (i > 0) const AppDivider(),
                  _PatientRow(
                    patient: nutri.patients[i],
                    onTap: () => _open(
                      context,
                      NutriPatientScreen(patient: nutri.patients[i]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        // Con la lista vacía el botón ya está en el mensaje.
        if (nutri.patients.isNotEmpty || nutri.loading)
          AppButton(
            key: const Key('shareCodeButton'),
            label: S.shareMyCode,
            iconLeft: AppIconName.qr,
            variant: ButtonVariant.outlineAccent,
            fullWidth: true,
            onPressed: () =>
                _open(context, const SharePlanScreen(nutritionist: true)),
          ),
      ],
    );
  }
}

class _PatientRow extends StatelessWidget {
  const _PatientRow({required this.patient, required this.onTap});

  final PatientSummary patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListItem(
      key: Key('patient-${patient.uid}'),
      leading: Avatar(initials: initialsOf(patient.name)),
      title: patient.name,
      subtitle: patient.objective.isEmpty ? patient.email : patient.objective,
      trailing: const AppIcon(AppIconName.chevronRight, tone: TextTone.muted),
      onPressed: onTap,
    );
  }
}
