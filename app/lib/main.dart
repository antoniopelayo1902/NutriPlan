import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app.dart';
import 'data/firebase_emulators.dart';
import 'firebase_options.dart';
import 'theme/accent_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseEmulators.connectIfEnabled();
  // Reads the iOS CLIENT_ID from GoogleService-Info.plist.
  await GoogleSignIn.instance.initialize();
  // Los controllers se arman con los datos de Firestore al iniciar sesión.
  runApp(NutriPlanApp(accent: AccentController(), requireAuth: true));
}
