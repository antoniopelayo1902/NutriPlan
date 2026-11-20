import 'package:flutter/foundation.dart';

import '../core/i18n/strings_es_mx.dart';
import '../domain/models/patient.dart';
import '../domain/repositories/patient_repository.dart';
import 'account_identity.dart';

/// Patient and nutritionist identity shown in headers and copy.
class ProfileController extends ChangeNotifier implements AccountIdentity {
  ProfileController(this._repository);

  final PatientRepository _repository;
  Patient? _patient;
  Nutritionist? _nutritionist;
  Object? _error;

  Patient? get patient => _patient;

  @override
  String? get displayName => _patient?.name;

  @override
  String get initials => _patient?.initials ?? '';
  Nutritionist? get nutritionist => _nutritionist;
  bool get hasError => _error != null;

  /// Cambia el nombre en la base de datos. Regresa false si falla.
  @override
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

  /// Nombre del nutriólogo, o "tu nutriólogo" si no hay uno vinculado.
  String get nutritionistName => _nutritionist?.name ?? S.yourNutritionist;

  bool get hasNutritionist => _nutritionist != null;

  /// Guarda los datos del registro. Regresa false si falla.
  Future<bool> saveProfile({
    required String name,
    required DateTime birthDate,
    required String sex,
    required String objective,
  }) async {
    try {
      await _repository.updateProfile(
        name: name,
        birthDate: birthDate,
        sex: sex,
        objective: objective,
      );
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
