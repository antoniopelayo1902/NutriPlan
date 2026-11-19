import 'package:flutter/material.dart';

import '../../application/account_identity.dart';
import '../../domain/models/patient_summary.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_web.dart';
import '../../theme/tokens_context.dart';
import '../components/data_display/avatar.dart';
import '../components/primitives/app_icon.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/app_text.dart';
import '../components/primitives/pressable.dart';

/// One patient in the sidebar, with soft hover and selected states.
class WebPatientTile extends StatelessWidget {
  const WebPatientTile({
    super.key,
    required this.patient,
    required this.selected,
    required this.onTap,
  });

  final PatientSummary patient;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Pressable(
      selected: selected,
      stretch: true,
      onPressed: onTap,
      builder: (BuildContext context, PressState s) {
        final Color fill = selected
            ? t.colors.accentSoft
            : s.hovered
            ? t.colors.bgSurfaceSubtle
            : t.colors.transparent;
        return AnimatedContainer(
          duration: t.motion.base,
          curve: t.motion.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: t.space.s3,
            vertical: t.space.s2,
          ),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(t.radius.md),
            border: Border.all(
              width: t.size.selectedBorder,
              color: selected ? t.colors.accentMuted : t.colors.transparent,
            ),
          ),
          child: AppStack(
            direction: Axis.horizontal,
            gap: t.space.s3,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Avatar(
                initials: initialsOf(patient.name),
                tone: selected ? AvatarTone.inverse : AvatarTone.accent,
              ),
              Expanded(
                child: AppStack(
                  gap: t.space.s1,
                  align: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppText(
                      patient.name,
                      variant: TextVariant.bodyLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppText(
                      patient.objective.isEmpty
                          ? patient.email
                          : patient.objective,
                      variant: TextVariant.bodySm,
                      tone: TextTone.muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppIcon(
                AppIconName.chevronRight,
                tone: selected ? TextTone.accent : TextTone.faint,
              ),
            ],
          ),
        );
      },
    );
  }
}
