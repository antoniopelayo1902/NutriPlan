import 'package:flutter/widgets.dart';

import '../../../application/account_identity.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../core/i18n/strings_web_es_mx.dart';
import '../../../domain/models/measurement.dart';
import '../../../domain/models/patient_summary.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_web.dart';
import '../../../theme/tokens_context.dart';
import '../../components/data_display/avatar.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/metric.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';

/// Wide-screen header of a patient: avatar, name, objective and quick stats.
class NutriPatientHeader extends StatelessWidget {
  const NutriPatientHeader({
    super.key,
    required this.patient,
    required this.latest,
    required this.dailyKcal,
  });

  final PatientSummary patient;
  final Measurement? latest;

  /// Daily kcal of the published targets, null while unknown.
  final double? dailyKcal;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final Measurement? m = latest;
    final double? bmi = m == null ? null : m.weightKg / (m.heightM * m.heightM);
    return AppCard(
      padding: t.space.s6,
      tone: CardTone.accentSoft,
      elevation: CardElevation.none,
      child: AppStack(
        direction: Axis.horizontal,
        gap: t.space.s5,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Avatar(
            initials: initialsOf(patient.name),
            size: t.size.avatarXl,
            tone: AvatarTone.inverse,
          ),
          Expanded(
            child: AppStack(
              gap: t.space.s1,
              align: CrossAxisAlignment.start,
              children: <Widget>[
                const Eyebrow(S.patientEyebrow),
                Semantics(
                  header: true,
                  child: AppText(
                    patient.name,
                    variant: TextVariant.titleLg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppText(
                  patient.objective.isEmpty
                      ? SWeb.webStatNoObjective
                      : patient.objective,
                  tone: TextTone.secondary,
                ),
                AppText(
                  patient.email,
                  variant: TextVariant.caption,
                  tone: TextTone.muted,
                ),
              ],
            ),
          ),
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s7,
            align: CrossAxisAlignment.start,
            children: <Widget>[
              _stat(
                t,
                SWeb.webStatWeight,
                m == null ? SWeb.webStatEmpty : formatDecimal(m.weightKg),
                m == null ? null : S.unitKg,
              ),
              _stat(
                t,
                SWeb.webStatBmi,
                bmi == null ? SWeb.webStatEmpty : formatDecimal(bmi),
                null,
              ),
              _stat(
                t,
                SWeb.webStatPlan,
                dailyKcal == null
                    ? SWeb.webStatEmpty
                    : formatInt(dailyKcal!.round()),
                dailyKcal == null ? null : S.unitKcal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(AppTokens t, String label, String value, String? unit) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: t.size.webStatMin),
      child: Metric(label: label, value: value, unit: unit),
    );
  }
}
