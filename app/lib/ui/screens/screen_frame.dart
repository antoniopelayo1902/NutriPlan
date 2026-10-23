import 'package:flutter/widgets.dart';

import '../../application/app_controllers.dart';
import '../../core/i18n/strings_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/data_display/avatar.dart';
import '../components/data_display/screen_header.dart';
import '../components/primitives/app_stack.dart';

/// Scrollable page with the shared header (patient initials on the right).
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.controllers,
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final AppControllers controllers;
  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        t.space.s5,
        t.space.s4,
        t.space.s5,
        t.space.s12,
      ),
      child: AppStack(
        gap: t.space.s5,
        children: <Widget>[
          ListenableBuilder(
            listenable: controllers.profile,
            builder: (BuildContext context, Widget? _) => ScreenHeader(
              eyebrow: eyebrow,
              title: title,
              trailing: Avatar(
                initials:
                    controllers.profile.patient?.initials ??
                    S.patientInitialsFallback,
                semanticLabel: S.avatarLabel,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
