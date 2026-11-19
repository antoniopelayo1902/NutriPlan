import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../application/app_controllers.dart';
import '../../../application/nutri_controller.dart';
import '../../../application/profile_photo_controller.dart';
import '../../../application/toast_controller.dart';
import '../../../bootstrap.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/auth_service.dart';
import '../../../data/device_token_service.dart';
import '../../../data/nutritionist_service.dart';
import '../../../data/profile_photo_store.dart';
import '../../../data/user_service.dart';
import '../../../domain/models/user_role.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../app_providers.dart';
import '../../components/actions/app_button.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';

/// Datos de la sesión: el rol y los controllers de ese tipo de cuenta.
class _Session {
  _Session.patient(this.controllers)
    : role = UserRole.patient,
      nutri = null,
      toast = controllers!.toast,
      photo = controllers.photo;

  _Session.nutritionist(this.nutri, this.toast, this.photo)
    : role = UserRole.nutritionist,
      controllers = null;

  final UserRole role;
  final AppControllers? controllers;
  final NutriController? nutri;
  final ToastController toast;
  final ProfilePhotoController photo;

  void dispose() {
    if (controllers != null) {
      controllers!.dispose();
    } else {
      nutri!.dispose();
      toast.dispose();
      photo.dispose();
    }
  }
}

/// Después del login: guarda al usuario en Firestore, arma los controllers
/// de su tipo de cuenta y muestra la app. Usa un FutureBuilder como en clase.
class SessionRoot extends StatefulWidget {
  const SessionRoot({super.key, required this.user, required this.child});

  final User user;
  final Widget child;

  @override
  State<SessionRoot> createState() => _SessionRootState();
}

class _SessionRootState extends State<SessionRoot> {
  late Future<_Session> _session;
  _Session? _current;
  StreamSubscription<String>? _messages;

  @override
  void initState() {
    super.initState();
    _session = _start();
  }

  /// Prepara el documento del usuario y carga todo desde Firestore.
  Future<_Session> _start() async {
    final String uid = widget.user.uid;
    final UserRole role = await UserService.prepare(
      widget.user,
      newRole: AuthService.pendingRole,
    );
    // Sin await: el permiso de notificaciones no debe frenar la app.
    unawaited(UserService.saveDeviceToken(uid).catchError((_) {}));
    final ProfilePhotoController photo = ProfilePhotoController(
      load: () => ProfilePhotoStore.load(uid),
      save: (String path) => ProfilePhotoStore.save(uid, path),
    );
    final _Session session;
    if (role == UserRole.nutritionist) {
      final NutriController nutri = NutriController(
        uid: uid,
        loadName: () => NutritionistService.loadName(uid),
        loadPatients: () => NutritionistService.patientsOf(uid),
        saveName: (String name) => NutritionistService.rename(uid, name),
        unlink: NutritionistService.unlink,
        createPatient: (String name, String email, String objective) =>
            NutritionistService.createPatient(
              nutriUid: uid,
              name: name,
              email: email,
              objective: objective,
            ),
      );
      session = _Session.nutritionist(nutri, ToastController(), photo);
      unawaited(nutri.load());
      unawaited(photo.load());
    } else {
      final AppControllers c = buildFirestoreControllers(uid: uid);
      session = _Session.patient(c);
      unawaited(c.loadAll());
    }
    _current = session;
    // Notificación con la app abierta: se muestra como toast.
    _messages = DeviceTokenService.foregroundTitles().listen(
      session.toast.show,
    );
    return session;
  }

  void _retry() => setState(() => _session = _start());

  @override
  void dispose() {
    _messages?.cancel();
    _current?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return FutureBuilder<_Session>(
      future: _session,
      builder: (BuildContext context, AsyncSnapshot<_Session> snapshot) {
        final _Session? s = snapshot.data;
        if (s != null) {
          return s.role == UserRole.nutritionist
              ? NutriProviders(
                  nutri: s.nutri!,
                  toast: s.toast,
                  photo: s.photo,
                  child: widget.child,
                )
              : AppProviders(controllers: s.controllers!, child: widget.child);
        }
        return DecoratedBox(
          decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(t.space.s5),
                  child: snapshot.hasError
                      ? EmptyState(
                          title: S.accountErrorTitle,
                          body: S.accountErrorBody,
                          action: AppButton(label: S.retry, onPressed: _retry),
                        )
                      : AppStack(
                          gap: t.space.s4,
                          align: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(color: t.colors.accent),
                            const AppText(
                              S.loadingAccount,
                              key: Key('loadingAccount'),
                              tone: TextTone.secondary,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
