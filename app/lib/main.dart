import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'application/app_controllers.dart';
import 'bootstrap.dart';
import 'core/scenario.dart';
import 'firebase_options.dart';
import 'theme/accent_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final AppControllers controllers = buildAppControllers(
    scenario: Scenario.current,
    latency: const Duration(milliseconds: 300),
  );
  runApp(NutriPlanApp(controllers: controllers, accent: AccentController()));
  unawaited(controllers.loadAll());
}
