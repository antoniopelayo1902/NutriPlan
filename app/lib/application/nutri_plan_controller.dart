import 'package:flutter/foundation.dart';

import '../domain/models/equivalent_option.dart';
import '../domain/models/plan.dart';
import '../domain/models/week_menu.dart';

/// Estado del editor de plan del nutriólogo: el catálogo, el menú que va
/// armando y el día que está viendo.
class NutriPlanController extends ChangeNotifier {
  NutriPlanController({
    required Future<Map<MealSlot, List<EquivalentOption>>> Function()
    loadCatalog,
    required Future<WeekMenu?> Function() loadMenu,
    required Future<void> Function(WeekMenu menu) publish,
  }) : _loadCatalog = loadCatalog,
       _loadMenu = loadMenu,
       _publish = publish;

  final Future<Map<MealSlot, List<EquivalentOption>>> Function() _loadCatalog;
  final Future<WeekMenu?> Function() _loadMenu;
  final Future<void> Function(WeekMenu) _publish;

  bool _loading = true;
  bool _publishing = false;
  bool _hasError = false;
  bool _hasPlan = false;
  int _day = 0;
  WeekMenu _menu = WeekMenu();
  Map<MealSlot, List<EquivalentOption>> _catalog =
      const <MealSlot, List<EquivalentOption>>{};

  bool get loading => _loading;
  bool get publishing => _publishing;
  bool get hasError => _hasError;

  /// True si el paciente ya tenía un plan publicado.
  bool get hasPlan => _hasPlan;
  int get day => _day;
  WeekMenu get menu => _menu;
  bool get catalogEmpty =>
      _catalog.values.every((List<EquivalentOption> l) => l.isEmpty);

  List<EquivalentOption> catalogFor(MealSlot slot) =>
      _catalog[slot] ?? const <EquivalentOption>[];

  Future<void> load() async {
    _loading = true;
    _hasError = false;
    notifyListeners();
    try {
      _catalog = await _loadCatalog();
      final WeekMenu? saved = await _loadMenu();
      _hasPlan = saved != null;
      _menu = saved ?? WeekMenu();
    } catch (_) {
      _hasError = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectDay(int day) {
    _day = day;
    notifyListeners();
  }

  /// Elige [option] para su tiempo de comida en el día que se está viendo.
  void pick(EquivalentOption option) {
    _menu = _menu.withPick(_day, option);
    notifyListeners();
  }

  /// Deja toda la semana igual que el día que se está viendo.
  void copyDayToWeek() {
    _menu = _menu.copyDayToWeek(_day);
    notifyListeners();
  }

  /// Publica el menú completo. Regresa false si falta algo o si falla.
  Future<bool> publish() async {
    if (!_menu.complete || _publishing) return false;
    _publishing = true;
    notifyListeners();
    try {
      await _publish(_menu);
      _hasPlan = true;
      return true;
    } catch (_) {
      return false;
    } finally {
      _publishing = false;
      notifyListeners();
    }
  }
}
