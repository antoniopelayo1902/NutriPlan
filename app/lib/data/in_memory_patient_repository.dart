import '../domain/models/patient.dart';
import '../domain/repositories/patient_repository.dart';

class InMemoryPatientRepository implements PatientRepository {
  InMemoryPatientRepository({
    required Patient patient,
    required Nutritionist nutritionist,
    this.latency = Duration.zero,
  }) : _patient = patient,
       _nutritionist = nutritionist;

  Patient _patient;
  final Nutritionist _nutritionist;
  final Duration latency;

  @override
  Future<Patient> getPatient() async {
    await Future<void>.delayed(latency);
    return _patient;
  }

  @override
  Future<Nutritionist> getNutritionist() async {
    await Future<void>.delayed(latency);
    return _nutritionist;
  }

  @override
  Future<void> updateName(String name) async {
    await Future<void>.delayed(latency);
    _patient = Patient(
      id: _patient.id,
      name: name.trim(),
      birthDate: _patient.birthDate,
      sex: _patient.sex,
      objective: _patient.objective,
      nutritionistId: _patient.nutritionistId,
    );
  }
}
