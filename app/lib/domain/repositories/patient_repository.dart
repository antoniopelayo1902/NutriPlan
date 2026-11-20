import '../models/patient.dart';

abstract interface class PatientRepository {
  Future<Patient> getPatient();

  /// Null cuando el paciente no tiene nutriólogo vinculado.
  Future<Nutritionist?> getNutritionist();
  Future<void> updateName(String name);

  /// Datos que se piden al registrarse.
  Future<void> updateProfile({
    required String name,
    required DateTime birthDate,
    required String sex,
    required String objective,
  });
}
