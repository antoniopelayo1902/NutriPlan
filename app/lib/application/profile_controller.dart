import 'package:flutter/foundation.dart';

import '../domain/models/patient.dart';
import '../domain/repositories/patient_repository.dart';

/// Patient and nutritionist identity shown in headers and copy.
class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final PatientRepository _repository;
  Patient? _patient;
  Nutritionist? _nutritionist;
  Object? _error;

  Patient? get patient => _patient;
  Nutritionist? get nutritionist => _nutritionist;
  bool get hasError => _error != null;

  /// Cambia el nombre en la base de datos. Regresa false si falla.
  Future<bool> rename(String name) async {
    try {
      await _repository.updateName(name);
      await load();
      return !hasError;
    } catch (e) {
      _error = e;
      notifyListeners();
      return false;
    }
  }

  Future<void> load() async {
    try {
      _patient = await _repository.getPatient();
      _nutritionist = await _repository.getNutritionist();
      _error = null;
    } catch (e) {
      _error = e;
    }
    notifyListeners();
  }
}
