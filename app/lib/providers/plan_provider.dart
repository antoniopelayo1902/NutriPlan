import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/meal.dart';

/// Estado del plan de la semana. Lo comparten las pantallas Semana,
/// Hoy y Cambiar, por eso vive en un Provider y no en un setState.
class PlanProvider extends ChangeNotifier {
  PlanProvider() {
    // Armamos los 7 días con los datos hardcodeados.
    for (int day = 0; day < 7; day++) {
      _week.add(mealsForDay(day));
    }
  }

  final List<List<Meal>> _week = [];

  /// Comidas marcadas como hechas. La clave es "dia-idComida", ej. "4-desayuno".
  final Set<String> _done = {};

  int _selectedDay = todayIndex;
  int _swapsThisWeek = 3;

  int get selectedDay => _selectedDay;
  int get swapsThisWeek => _swapsThisWeek;

  List<Meal> mealsOf(int day) => _week[day];
  List<Meal> get todayMeals => _week[todayIndex];

  bool isDone(int day, Meal meal) => _done.contains('$day-${meal.id}');

  void selectDay(int day) {
    _selectedDay = day;
    // Avisa a los Consumer para que se redibujen.
    notifyListeners();
  }

  /// Marca o desmarca una comida como hecha.
  void toggleDone(int day, Meal meal) {
    final String key = '$day-${meal.id}';
    if (_done.contains(key)) {
      _done.remove(key);
    } else {
      _done.add(key);
    }
    notifyListeners();
  }

  /// Cambia el platillo de una comida por otro con los mismos equivalentes.
  void swapMeal(int day, Meal meal, String newName) {
    final List<Meal> meals = _week[day];
    for (int i = 0; i < meals.length; i++) {
      if (meals[i].id == meal.id) {
        meals[i] = Meal(id: meal.id, mealTime: meal.mealTime, hour: meal.hour, name: newName, portions: meal.portions);
      }
    }
    _swapsThisWeek++;
    notifyListeners();
  }

  /// Equivalentes consumidos hoy de un grupo (suma de las comidas marcadas).
  int consumedToday(String groupKey) {
    int total = 0;
    for (final Meal meal in todayMeals) {
      if (isDone(todayIndex, meal)) {
        total += meal.portions[groupKey] ?? 0;
      }
    }
    return total;
  }

  /// Porcentaje del día cubierto (0 a 100), contando todos los grupos.
  int get todayPercent {
    int target = 0;
    int consumed = 0;
    dailyTargets.forEach((group, amount) {
      target += amount;
      final int eaten = consumedToday(group);
      // Comer de más en un grupo no compensa lo que falta en otro.
      consumed += eaten > amount ? amount : eaten;
    });
    return (consumed * 100 / target).round();
  }

  /// La primera comida de hoy que todavía no se marca (o null si ya todas).
  Meal? get nextMeal {
    for (final Meal meal in todayMeals) {
      if (!isDone(todayIndex, meal)) {
        return meal;
      }
    }
    return null;
  }
}
