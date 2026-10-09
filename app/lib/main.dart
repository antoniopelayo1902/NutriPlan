import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/plan_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login.dart';
import 'theme/app_text.dart';

void main() {
  // Arranca la app con el widget raíz.
  runApp(const NutriPlanApp());
}

/// Raíz de la app. Los Provider van hasta arriba del árbol para que
/// cualquier pantalla pueda leer los ajustes y el plan.
class NutriPlanApp extends StatelessWidget {
  const NutriPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => PlanProvider()),
      ],
      // Consumer redibuja MaterialApp cuando cambia el modo oscuro.
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'NutriPlan',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            // Elige el tema claro u oscuro según el switch de Ajustes.
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            // Primera pantalla: inicio de sesión.
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
