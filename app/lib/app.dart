import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'application/app_controllers.dart';
import 'core/i18n/strings_es_mx.dart';
import 'theme/accent_controller.dart';
import 'theme/app_theme.dart';
import 'ui/shell/app_shell.dart';

/// Root widget. Rebuilds the theme whenever the runtime accent changes.
class NutriPlanApp extends StatelessWidget {
  const NutriPlanApp({
    super.key,
    required this.controllers,
    required this.accent,
  });

  static const Locale _locale = Locale('es', 'MX');

  final AppControllers controllers;
  final AccentController accent;

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
          home: AppShell(controllers: controllers),
        );
      },
    );
  }
}
