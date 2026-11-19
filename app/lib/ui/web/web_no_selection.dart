import 'package:flutter/material.dart';

import '../../core/i18n/strings_web_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_web.dart';
import '../../theme/tokens_context.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/app_text.dart';

/// Right pane before a patient is chosen: a calm, friendly invitation.
class WebNoSelection extends StatelessWidget {
  const WebNoSelection({super.key, required this.hasPatients});

  final bool hasPatients;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Center(
      child: ConstrainedBox(
        key: const Key('noSelection'),
        constraints: BoxConstraints(maxWidth: t.size.webEmptyMax),
        child: Padding(
          padding: EdgeInsets.all(t.space.s6),
          child: AppStack(
            gap: t.space.s4,
            align: CrossAxisAlignment.center,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: t.colors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: t.size.illustrationDisc,
                  height: t.size.illustrationDisc,
                  child: Icon(
                    Icons.people_alt_outlined,
                    size: t.size.iconXl,
                    color: t.colors.textAccent,
                  ),
                ),
              ),
              const AppText(
                SWeb.selectPatientTitle,
                variant: TextVariant.titleMd,
                textAlign: TextAlign.center,
              ),
              AppText(
                hasPatients
                    ? SWeb.selectPatientBody
                    : SWeb.webEmptyNoPatientsBody,
                tone: TextTone.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
