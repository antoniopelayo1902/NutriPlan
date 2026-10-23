import '../domain/models/patient.dart';
import '../domain/repositories/patient_repository.dart';

class InMemoryPatientRepository implements PatientRepository {
  InMemoryPatientRepository({
    required Patient patient,
    required Nutritionist nutritionist,
    this.latency = Duration.zero,
  }) : _patient = patient,
       _nutritionist = nutritionist;

  final Patient _patient;
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
}
