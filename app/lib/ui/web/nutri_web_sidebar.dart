import 'package:flutter/material.dart';

import '../../application/nutri_controller.dart';
import '../../core/i18n/strings_es_mx.dart';
import '../../core/i18n/strings_web_es_mx.dart';
import '../../domain/models/patient_summary.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/actions/app_button.dart';
import '../components/actions/app_text_field.dart';
import '../components/data_display/empty_state.dart';
import '../components/primitives/app_icon.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/skeleton.dart';
import '../screens/profile/share_plan_screen.dart';
import 'add_patient_dialog.dart';
import 'web_patient_tile.dart';
import 'web_sidebar_header.dart';

/// Left pane of the web layout: brand, greeting, search, patient list and
/// the QR button.
class NutriWebSidebar extends StatefulWidget {
  const NutriWebSidebar({
    super.key,
    required this.nutri,
    required this.selectedUid,
    required this.onSelect,
  });

  final NutriController nutri;
  final String? selectedUid;
  final ValueChanged<PatientSummary> onSelect;

  @override
  State<NutriWebSidebar> createState() => _NutriWebSidebarState();
}

class _NutriWebSidebarState extends State<NutriWebSidebar> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<PatientSummary> get _visible {
    final String q = _search.text.trim().toLowerCase();
    return widget.nutri.patients
        .where((PatientSummary p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  Widget _list(AppTokens t) {
    final NutriController nutri = widget.nutri;
    if (nutri.loading) {
      return AppStack(
        gap: t.space.s3,
        children: <Widget>[
          for (int i = 0; i < 3; i++)
            Skeleton(height: t.size.skeletonCard, radius: t.radius.xl),
        ],
      );
    }
    if (nutri.hasError && nutri.patients.isEmpty) {
      return EmptyState(
        title: S.errorTitle,
        body: S.errorBody,
        action: AppButton(label: S.retry, onPressed: nutri.load),
      );
    }
    if (nutri.patients.isEmpty) {
      return const EmptyState(
        key: Key('noPatients'),
        title: S.patientsEmptyTitle,
        body: S.patientsEmptyBody,
      );
    }
    final List<PatientSummary> shown = _visible;
    if (shown.isEmpty) return const EmptyState(title: SWeb.webNoMatches);
    return AppStack(
      gap: t.space.s1,
      children: <Widget>[
        for (final PatientSummary p in shown)
          WebPatientTile(
            key: Key('patient-${p.uid}'),
            patient: p,
            selected: p.uid == widget.selectedUid,
            onTap: () => widget.onSelect(p),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final NutriController nutri = widget.nutri;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(t.space.s5),
        child: AppStack(
          gap: t.space.s4,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            WebSidebarHeader(
              name: nutri.displayName,
              patientCount: nutri.patients.length,
            ),
            if (nutri.patients.isNotEmpty)
              AppTextField(
                key: const Key('patientSearch'),
                controller: _search,
                label: SWeb.webSearchPatients,
                icon: AppIconName.search,
                onChanged: (_) => setState(() {}),
              ),
            Expanded(
              child: RefreshIndicator(
                color: t.colors.accent,
                backgroundColor: t.colors.bgSurface,
                onRefresh: nutri.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[_list(t)],
                ),
              ),
            ),
            AppButton(
              key: const Key('addPatientButton'),
              label: SWeb.addPatient,
              iconLeft: AppIconName.add,
              fullWidth: true,
              onPressed: () => showAddPatientDialog(context),
            ),
            AppButton(
              key: const Key('shareCodeButton'),
              label: S.shareMyCode,
              iconLeft: AppIconName.qr,
              variant: ButtonVariant.outlineAccent,
              fullWidth: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext _) =>
                      const SharePlanScreen(nutritionist: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
