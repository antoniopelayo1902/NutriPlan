import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../../../data/auth_service.dart';
import 'login_screen.dart';

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
        if (user == null) return const LoginScreen();
        return AuthScope(
          email: user.email ?? '',
          signOut: AuthService.signOut,
          child: child,
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
    required this.email,
    required this.signOut,
    required super.child,
  });

  final String email;
  final Future<void> Function() signOut;

  static AuthScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>();

  @override
  bool updateShouldNotify(AuthScope oldWidget) => email != oldWidget.email;
}
