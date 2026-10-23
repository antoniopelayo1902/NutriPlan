import '../models/patient.dart';

abstract interface class PatientRepository {
  Future<Patient> getPatient();
  Future<Nutritionist> getNutritionist();
}
