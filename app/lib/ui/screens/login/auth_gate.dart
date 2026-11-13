import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../../../data/auth_service.dart';
import 'login_screen.dart';
import 'session_root.dart';

/// Shows [LoginScreen] until Firebase reports a signed-in user, then [child].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        final User? user = snapshot.data;
        // El login va en su propio Overlay porque aquí todavía no hay Navigator.
        if (user == null) {
          return Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(builder: (BuildContext _) => const LoginScreen()),
            ],
          );
        }
        return AuthScope(
          uid: user.uid,
          email: user.email ?? '',
          signOut: AuthService.signOut,
          // Un usuario nuevo arma su sesión desde cero.
          child: SessionRoot(
            key: ValueKey<String>(user.uid),
            user: user,
            child: child,
          ),
        );
      },
    );
  }
}

/// Signed-in session data for screens below the gate. Absent when the app
/// runs without authentication (widget tests), so screens hide sign out.
class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.uid,
    required this.email,
    required this.signOut,
    required super.child,
  });

  final String uid;
  final String email;
  final Future<void> Function() signOut;

  static AuthScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>();

  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      email != oldWidget.email || uid != oldWidget.uid;
}
