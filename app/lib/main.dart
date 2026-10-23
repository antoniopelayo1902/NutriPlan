import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app.dart';
import 'application/app_controllers.dart';
import 'bootstrap.dart';
import 'core/scenario.dart';
import 'theme/accent_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final AppControllers controllers = buildAppControllers(
    scenario: Scenario.current,
    latency: const Duration(milliseconds: 300),
  );
  runApp(NutriPlanApp(controllers: controllers, accent: AccentController()));
  unawaited(controllers.loadAll());
}
