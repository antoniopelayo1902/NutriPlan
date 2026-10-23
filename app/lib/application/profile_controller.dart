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
