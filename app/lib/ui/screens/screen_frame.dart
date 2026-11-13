import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/app_controllers.dart';
import '../../application/profile_photo_controller.dart';
import '../../core/i18n/strings_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_context.dart';
import '../components/data_display/avatar.dart';
import '../components/data_display/screen_header.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/pressable.dart';
import 'profile/profile_screen.dart';

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
            ListenableBuilder(
              listenable: controllers.profile,
              builder: (BuildContext context, Widget? _) => ScreenHeader(
                eyebrow: eyebrow,
                title: title,
                trailing: Pressable(
                  key: const Key('avatarButton'),
                  semanticLabel: S.openProfile,
                  // Abre el perfil con Navigator.push.
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext _) => const ProfileScreen(),
                    ),
                  ),
                  builder: (BuildContext context, PressState _) =>
                      Consumer<ProfilePhotoController>(
                        builder:
                            (
                              BuildContext context,
                              ProfilePhotoController photo,
                              Widget? _,
                            ) => Avatar(
                              initials:
                                  controllers.profile.patient?.initials ??
                                  S.patientInitialsFallback,
                              photoPath: photo.path,
                            ),
                      ),
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
