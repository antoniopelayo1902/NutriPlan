import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'application/app_controllers.dart';
import 'core/i18n/strings_es_mx.dart';
import 'theme/accent_controller.dart';
import 'theme/app_theme.dart';
import 'domain/models/user_role.dart';
import 'ui/app_providers.dart';
import 'ui/screens/login/auth_gate.dart';
import 'ui/screens/nutri/nutri_home_screen.dart';
import 'ui/shell/app_shell.dart';
import 'ui/web/nutri_web_shell.dart';
import 'ui/web/web_nutri_only_screen.dart';

/// Root widget. Rebuilds the theme whenever the runtime accent changes.
class NutriPlanApp extends StatelessWidget {
  const NutriPlanApp({
    super.key,
    this.controllers,
    required this.accent,
    this.requireAuth = false,
  }) : assert(requireAuth || controllers != null);

  static const Locale _locale = Locale('es', 'MX');

  /// Controllers fijos (widget tests). Con login se arman por usuario.
  final AppControllers? controllers;
  final AccentController accent;

  /// Puts the Firebase login in front of the app. Off in widget tests,
  /// which run without Firebase.
  final bool requireAuth;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accent,
      builder: (BuildContext context, Color color, Widget? _) {
        return MaterialApp(
          title: S.appName,
          debugShowCheckedModeBanner: false,
          locale: _locale,
          supportedLocales: const <Locale>[_locale],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildTheme(accent: color),
          // builder envuelve al Navigator: login y Provider quedan arriba de
          // todas las pantallas, también de las que se abren con push.
          builder: (BuildContext context, Widget? navigator) => requireAuth
              ? AuthGate(child: navigator!)
              : AppProviders(controllers: controllers!, child: navigator!),
          home: const _Home(),
        );
      },
    );
  }
}

/// Primera pantalla del Navigator según el tipo de cuenta: las cinco
/// pestañas del paciente o la lista de pacientes del nutriólogo.
class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    if (context.watch<UserRole>() == UserRole.nutritionist) {
      return kIsWeb ? const NutriWebShell() : const NutriHomeScreen();
    }
    if (kIsWeb) return const WebNutriOnlyScreen();
    return AppShell(controllers: context.read<AppControllers>());
  }
}
