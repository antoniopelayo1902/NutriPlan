import 'package:flutter/material.dart';

import '../../core/i18n/strings_es_mx.dart';
import '../../core/i18n/strings_web_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/data_display/profile_avatar_button.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/app_text.dart';
import 'web_brand_mark.dart';

/// Top of the sidebar: brand, profile button, greeting and patient count.
class WebSidebarHeader extends StatelessWidget {
  const WebSidebarHeader({
    super.key,
    required this.name,
    required this.patientCount,
  });

  final String? name;
  final int patientCount;

  String get _greeting {
    final String first = (name ?? '').trim().split(RegExp(r'\s+')).first;
    return first.isEmpty ? SWeb.webGreetingFallback : SWeb.webGreeting(first);
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      gap: t.space.s5,
      children: <Widget>[
        const Row(
          children: <Widget>[
            Expanded(child: WebBrandMark()),
            ProfileAvatarButton(),
          ],
        ),
        AppStack(
          gap: t.space.s1,
          align: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              header: true,
              child: AppText(_greeting, variant: TextVariant.titleMd),
            ),
            const AppText(
              SWeb.webGreetingSub,
              variant: TextVariant.bodyMd,
              tone: TextTone.secondary,
            ),
            AppText(
              S.patientCount(patientCount),
              key: const Key('patientCount'),
              variant: TextVariant.label,
              tone: TextTone.accent,
            ),
          ],
        ),
      ],
    );
  }
}
