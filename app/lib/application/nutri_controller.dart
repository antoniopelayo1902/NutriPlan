import 'package:flutter/foundation.dart';

import '../domain/models/patient_summary.dart';
import 'account_identity.dart';

/// Estado de la cuenta de nutriólogo: su nombre y su lista de pacientes.
/// Las llamadas a Firestore llegan inyectadas para poder probarlo.
class NutriController extends ChangeNotifier implements AccountIdentity {
  NutriController({
    required this.uid,
    required Future<String> Function() loadName,
    required Future<List<PatientSummary>> Function() loadPatients,
    required Future<void> Function(String name) saveName,
    required Future<void> Function(String patientUid) unlink,
    required Future<void> Function(String name, String email, String objective)
    createPatient,
  }) : _loadName = loadName,
       _loadPatients = loadPatients,
       _saveName = saveName,
       _unlink = unlink,
       _createPatient = createPatient;

  final String uid;
  final Future<String> Function() _loadName;
  final Future<List<PatientSummary>> Function() _loadPatients;
  final Future<void> Function(String) _saveName;
  final Future<void> Function(String) _unlink;
  final Future<void> Function(String, String, String) _createPatient;

  bool _loading = true;
  Object? _error;
  String? _name;
  List<PatientSummary> _patients = <PatientSummary>[];

  bool get loading => _loading;
  bool get hasError => _error != null;
  List<PatientSummary> get patients =>
      List<PatientSummary>.unmodifiable(_patients);

  @override
  String? get displayName => _name;

  @override
  String get initials => initialsOf(_name ?? '');

  /// Lee el nombre y los pacientes. [silent] no muestra el esqueleto.
  Future<void> load({bool silent = false}) async {
    if (!silent) _loading = true;
    _error = null;
    notifyListeners();
    try {
      _name = await _loadName();
      _patients = await _loadPatients();
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Swipe down en la lista de pacientes.
  Future<void> refresh() => load(silent: true);

  @override
  Future<bool> rename(String name) async {
    try {
      await _saveName(name);
      _name = name.trim();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e;
      notifyListeners();
      return false;
    }
  }

  /// Registra un paciente a mano y recarga la lista. Regresa false si falla.
  Future<bool> addPatient(String name, String email, String objective) async {
    try {
      await _createPatient(name, email, objective);
      await load(silent: true);
      return !hasError;
    } catch (e) {
      _error = e;
      notifyListeners();
      return false;
    }
  }

  /// Quita a un paciente de la lista. Regresa false si falla.
  Future<bool> unlink(String patientUid) async {
    try {
      await _unlink(patientUid);
      _patients = _patients
          .where((PatientSummary p) => p.uid != patientUid)
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e;
      notifyListeners();
      return false;
    }
  }
}
