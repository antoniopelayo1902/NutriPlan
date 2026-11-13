import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/account_identity.dart';
import '../../../application/profile_controller.dart';
import '../../../application/profile_photo_controller.dart';
import '../../../application/toast_controller.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/gallery.dart';
import '../../../data/profile_photo_store.dart';
import '../../../data/user_service.dart';
import '../../../domain/models/user_role.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_text_field.dart';
import '../../components/data_display/avatar.dart';
import '../../components/data_display/confirm_dialog.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/list_item.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_divider.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../login/auth_gate.dart';
import '../page_frame.dart';
import 'scan_plan_screen.dart';
import 'share_plan_screen.dart';

/// Perfil de paciente o nutrióloga: foto desde la galería, nombre, token,
/// Factor WOW y cuenta.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  Future<Map<String, dynamic>>? _account;
  String? _nameError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name.text = context.read<AccountIdentity>().displayName ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Future de la clase: se lee el documento del usuario una sola vez.
    final AuthScope? auth = AuthScope.maybeOf(context);
    _account ??= auth == null ? null : UserService.accountInfo(auth.uid);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Abre la galería y guarda la foto solo en el teléfono.
  Future<void> _changePhoto() async {
    final ProfilePhotoController photo = context.read<ProfilePhotoController>();
    final ToastController toast = context.read<ToastController>();
    try {
      final String? path = await Gallery.pickImage();
      if (path == null) return;
      await photo.set(path);
      toast.show(S.photoUpdated);
    } catch (_) {
      toast.show(S.photoFailed);
    }
  }

  /// Update del nombre en Firestore.
  Future<void> _saveName() async {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = S.nameRequired);
      return;
    }
    setState(() {
      _nameError = null;
      _saving = true;
    });
    final ToastController toast = context.read<ToastController>();
    final bool ok = await context.read<AccountIdentity>().rename(_name.text);
    if (!mounted) return;
    setState(() => _saving = false);
    toast.show(ok ? S.nameSaved : S.actionFailed);
  }

  Future<void> _deleteAccount() async {
    final bool sure = await showConfirmDialog(
      context,
      title: S.deleteAccountTitle,
      body: S.deleteAccountBody,
      confirmLabel: S.delete,
    );
    if (!sure || !mounted) return;
    final ToastController toast = context.read<ToastController>();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await ProfilePhotoStore.delete(user.uid);
      await UserService.deleteAccount(user);
    } on FirebaseAuthException catch (e) {
      toast.show(
        e.code == 'requires-recent-login'
            ? S.deleteAccountRecentLogin
            : S.actionFailed,
      );
    } catch (_) {
      toast.show(S.actionFailed);
    }
  }

  bool get _isNutri => context.read<UserRole>() == UserRole.nutritionist;

  void _open(Widget screen) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (BuildContext _) => screen),
  );

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final AuthScope? auth = AuthScope.maybeOf(context);
    return PageFrame(
      eyebrow: S.profileEyebrow,
      title: S.profileTitle,
      children: <Widget>[
        Consumer2<AccountIdentity, ProfilePhotoController>(
          builder:
              (
                BuildContext context,
                AccountIdentity account,
                ProfilePhotoController photo,
                Widget? _,
              ) => AppCard(
                child: AppStack(
                  gap: t.space.s4,
                  align: CrossAxisAlignment.center,
                  children: <Widget>[
                    Avatar(
                      key: const Key('profileAvatar'),
                      initials: account.initials.isEmpty
                          ? S.patientInitialsFallback
                          : account.initials,
                      size: t.size.avatarLg,
                      photoPath: photo.path,
                    ),
                    AppButton(
                      key: const Key('changePhotoButton'),
                      label: S.changePhoto,
                      iconLeft: AppIconName.image,
                      variant: ButtonVariant.outlineAccent,
                      onPressed: _changePhoto,
                    ),
                  ],
                ),
              ),
        ),
        AppCard(
          child: AppStack(
            gap: t.space.s3,
            children: <Widget>[
              AppTextField(
                key: const Key('nameField'),
                controller: _name,
                label: S.nameLabel,
                errorText: _nameError,
              ),
              AppButton(
                key: const Key('saveNameButton'),
                label: S.saveName,
                fullWidth: true,
                loading: _saving,
                onPressed: _saving ? null : _saveName,
              ),
            ],
          ),
        ),
        _accountCard(t, auth),
        AppCard(
          child: AppStack(
            gap: t.space.s3,
            children: <Widget>[
              Eyebrow(_isNutri ? S.nutriWowEyebrow : S.wowEyebrow),
              AppText(
                _isNutri ? S.nutriWowBody : S.scanBodyAny,
                tone: TextTone.secondary,
              ),
              AppButton(
                key: const Key('sharePlanButton'),
                label: S.sharePlan,
                iconLeft: AppIconName.qr,
                fullWidth: true,
                onPressed: () => _open(SharePlanScreen(nutritionist: _isNutri)),
              ),
              // La nutrióloga no importa planes: solo comparte su código.
              if (!_isNutri)
                AppButton(
                  key: const Key('scanPlanButton'),
                  label: S.scanAny,
                  iconLeft: AppIconName.camera,
                  fullWidth: true,
                  variant: ButtonVariant.outlineNeutral,
                  onPressed: () => _open(const ScanPlanScreen()),
                ),
            ],
          ),
        ),
        if (auth != null)
          AppStack(
            gap: t.space.s2,
            children: <Widget>[
              AppButton(
                key: const Key('profileSignOutButton'),
                label: S.signOut,
                iconLeft: AppIconName.logout,
                variant: ButtonVariant.outlineNeutral,
                fullWidth: true,
                onPressed: auth.signOut,
              ),
              AppButton(
                key: const Key('deleteAccountButton'),
                label: S.deleteAccount,
                iconLeft: AppIconName.delete,
                variant: ButtonVariant.ghost,
                fullWidth: true,
                onPressed: _deleteAccount,
              ),
            ],
          ),
      ],
    );
  }

  /// Correo, nutrióloga y token del dispositivo guardado en Firestore.
  Widget _accountCard(AppTokens t, AuthScope? auth) {
    return AppCard(
      padding: t.space.s5,
      child: Builder(
        builder: (BuildContext context) => AppStack(
          gap: t.space.s2,
          children: <Widget>[
            const Eyebrow(S.accountEyebrow),
            ListItem(title: S.emailLabel, subtitle: auth?.email ?? ''),
            const AppDivider(),
            ListItem(
              key: const Key('roleRow'),
              title: S.roleLabel,
              subtitle: _isNutri ? S.roleNutritionist : S.rolePatient,
            ),
            const AppDivider(),
            if (!_isNutri) ...<Widget>[
              Consumer<ProfileController>(
                builder:
                    (
                      BuildContext context,
                      ProfileController profile,
                      Widget? _,
                    ) => ListItem(
                      key: const Key('nutritionistRow'),
                      title: S.nutritionistLabel,
                      subtitle: profile.nutritionist?.name ?? '',
                    ),
              ),
              const AppDivider(),
            ],
            FutureBuilder<Map<String, dynamic>>(
              future: _account,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot,
                  ) {
                    final bool hasToken = snapshot.data?['token'] is String;
                    return ListItem(
                      key: const Key('tokenRow'),
                      title: S.tokenLabel,
                      subtitle: !snapshot.hasData
                          ? S.loadingAccount
                          : hasToken
                          ? S.tokenSaved
                          : S.tokenMissing,
                    );
                  },
            ),
          ],
        ),
      ),
    );
  }
}
