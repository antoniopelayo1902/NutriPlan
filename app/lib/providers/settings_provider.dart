import 'package:flutter/material.dart';

/// Guarda los ajustes de la app. Usa Provider:
/// cuando cambia un valor llamamos notifyListeners() y los Consumer
/// que lo escuchan se vuelven a dibujar.
class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _mealReminders = true;
  bool _waterReminders = false;

  bool get darkMode => _darkMode;
  bool get mealReminders => _mealReminders;
  bool get waterReminders => _waterReminders;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setMealReminders(bool value) {
    _mealReminders = value;
    notifyListeners();
  }

  void setWaterReminders(bool value) {
    _waterReminders = value;
    notifyListeners();
  }
}
