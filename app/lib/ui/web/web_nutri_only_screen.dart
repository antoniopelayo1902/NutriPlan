import 'package:flutter/material.dart';

import '../../core/i18n/strings_es_mx.dart';
import '../../core/i18n/strings_web_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/actions/app_button.dart';
import '../components/data_display/empty_state.dart';
import '../screens/login/auth_gate.dart';

/// Shown on the web to a patient account: the browser version is only for
/// nutritionists, so the only action is to sign out.
class WebNutriOnlyScreen extends StatelessWidget {
  const WebNutriOnlyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final AuthScope? auth = AuthScope.maybeOf(context);
    return Scaffold(
      backgroundColor: t.colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
        child: Center(
          child: EmptyState(
            key: const Key('webNutriOnly'),
            title: SWeb.webOnlyNutriTitle,
            body: SWeb.webOnlyNutriBody,
            action: auth == null
                ? null
                : AppButton(label: S.signOut, onPressed: auth.signOut),
          ),
        ),
      ),
    );
  }
}
