import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Para probar sin tocar la base real: flutter run --dart-define=USE_EMULATOR=true
/// con los emuladores de Firebase corriendo en la Mac.
abstract final class FirebaseEmulators {
  static const bool enabled = bool.fromEnvironment('USE_EMULATOR');

  static Future<void> connectIfEnabled() async {
    if (!enabled) return;
    await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }
}
