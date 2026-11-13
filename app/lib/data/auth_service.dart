import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/i18n/strings_es_mx.dart';
import '../domain/models/user_role.dart';

/// Every Firebase Authentication call of the app. Screens only call these
/// and show [errorMessage] when one fails.
abstract final class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Rol elegido en el login; se usa solo si la cuenta es nueva.
  static UserRole pendingRole = UserRole.patient;

  /// Emits the signed-in user, or null after signing out.
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<void> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Opens the Google account picker and signs in to Firebase with its token.
  /// Returns false when the user closes the picker without choosing.
  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    }
  }

  /// Signs out of Firebase and of Google.
  static Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  static String errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return S.authInvalidEmail;
        case 'user-disabled':
          return S.authUserDisabled;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return S.authWrongCredentials;
        case 'email-already-in-use':
          return S.authEmailInUse;
        case 'weak-password':
          return S.authWeakPassword;
        case 'network-request-failed':
          return S.authNoNetwork;
        case 'too-many-requests':
          return S.authTooManyRequests;
      }
    }
    if (error is GoogleSignInException) return S.authGoogleFailed;
    return S.authUnknown;
  }
}
