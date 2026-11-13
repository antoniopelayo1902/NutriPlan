import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../application/app_controllers.dart';
import '../../../bootstrap.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/device_token_service.dart';
import '../../../data/user_service.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../app_providers.dart';
import '../../components/actions/app_button.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';

/// Después del login: guarda al usuario en Firestore, arma los controllers
/// con sus datos y muestra la app. Usa un FutureBuilder como en la clase.
class SessionRoot extends StatefulWidget {
  const SessionRoot({super.key, required this.user, required this.child});

  final User user;
  final Widget child;

  @override
  State<SessionRoot> createState() => _SessionRootState();
}

class _SessionRootState extends State<SessionRoot> {
  late Future<AppControllers> _session;
  AppControllers? _controllers;
  StreamSubscription<String>? _messages;

  @override
  void initState() {
    super.initState();
    _session = _start();
  }

  /// Prepara el documento del usuario y carga todo desde Firestore.
  Future<AppControllers> _start() async {
    await UserService.prepare(widget.user);
    // Sin await: el permiso de notificaciones no debe frenar la app.
    unawaited(UserService.saveDeviceToken(widget.user.uid).catchError((_) {}));
    final AppControllers c = buildFirestoreControllers(uid: widget.user.uid);
    _controllers = c;
    // Notificación con la app abierta: se muestra como toast.
    _messages = DeviceTokenService.foregroundTitles().listen(c.toast.show);
    unawaited(c.loadAll());
    return c;
  }

  void _retry() => setState(() => _session = _start());

  @override
  void dispose() {
    _messages?.cancel();
    _controllers?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return FutureBuilder<AppControllers>(
      future: _session,
      builder: (BuildContext context, AsyncSnapshot<AppControllers> snapshot) {
        if (snapshot.hasData) {
          return AppProviders(controllers: snapshot.data!, child: widget.child);
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
