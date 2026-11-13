import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/account_identity.dart';
import '../../../application/profile_photo_controller.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../screens/profile/profile_screen.dart';
import '../primitives/pressable.dart';
import 'avatar.dart';

/// Foto o iniciales de la cuenta; al tocarlo abre el perfil.
class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Pressable(
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
          Consumer2<AccountIdentity, ProfilePhotoController>(
            builder:
                (
                  BuildContext context,
                  AccountIdentity account,
                  ProfilePhotoController photo,
                  Widget? _,
                ) => Avatar(
                  initials: account.initials.isEmpty
                      ? S.patientInitialsFallback
                      : account.initials,
                  photoPath: photo.path,
                ),
          ),
    );
  }
}
