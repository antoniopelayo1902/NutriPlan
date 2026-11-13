import 'package:flutter/material.dart';

import '../../application/app_controllers.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/data_display/profile_avatar_button.dart';
import '../components/data_display/screen_header.dart';
import '../components/primitives/app_stack.dart';

/// Scrollable page with the shared header (patient initials on the right).
/// Al jalar hacia abajo (swipe down) recarga todo desde Firebase.
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
    return RefreshIndicator(
      key: const Key('refreshIndicator'),
      color: t.colors.accent,
      backgroundColor: t.colors.bgSurface,
      onRefresh: controllers.refreshAll,
      child: SingleChildScrollView(
        // Permite jalar aunque la pantalla no esté llena.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          t.space.s5,
          t.space.s4,
          t.space.s5,
          t.space.s12,
        ),
        child: AppStack(
          gap: t.space.s5,
          children: <Widget>[
            ScreenHeader(
              eyebrow: eyebrow,
              title: title,
              trailing: const ProfileAvatarButton(),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
