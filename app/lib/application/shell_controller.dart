import 'package:flutter/foundation.dart';

import '../core/clock.dart';

/// Which meal the Cambiar tab is working on.
class SwapTarget {
  const SwapTarget(this.date, this.mealId);
  final DateTime date;
  final String mealId;
}

class ShellController extends ChangeNotifier {
  static const int tabSemana = 0;
  static const int tabHoy = 1;
  static const int tabCambiar = 2;
  static const int tabMovimiento = 3;
  static const int tabProgreso = 4;

  int _tab = tabSemana;
  SwapTarget? _target;
  DateTime? _selectedDay;

  int get tabIndex => _tab;
  SwapTarget? get pendingSwap => _target;

  /// Day highlighted in Semana; null means "today".
  DateTime? get selectedDay => _selectedDay;

  void selectTab(int index) {
    if (index == _tab) return;
    _tab = index;
    notifyListeners();
  }

  /// Opens Cambiar with [mealId] of [date] preselected.
  void openSwap(DateTime date, String mealId) {
    _target = SwapTarget(dateOnly(date), mealId);
    _selectedDay = dateOnly(date);
    _tab = tabCambiar;
    notifyListeners();
  }

  void clearSwap() {
    if (_target == null) return;
    _target = null;
    notifyListeners();
  }

  void selectDay(DateTime date) {
    _selectedDay = dateOnly(date);
    notifyListeners();
  }

  /// After a swap: clear the target and go back to Semana on that day.
  void finishSwap(DateTime date) {
    _target = null;
    _selectedDay = dateOnly(date);
    _tab = tabSemana;
    notifyListeners();
  }
}
