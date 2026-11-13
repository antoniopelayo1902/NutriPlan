import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/errors.dart';
import '../../domain/models/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Datos del paciente (users/{uid}) y de su nutrióloga.
class FirestorePatientRepository implements PatientRepository {
  FirestorePatientRepository({required this.uid});

  final String uid;

  @override
  Future<Patient> getPatient() async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirestorePaths.user(uid).get();
    if (!doc.exists) throw const NotFoundError('User not found');
    return FirestoreMappers.patientFromMap(uid, doc.data()!);
  }

  @override
  Future<Nutritionist> getNutritionist() async {
    final Patient patient = await getPatient();
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirestorePaths.nutritionist(patient.nutritionistId).get();
    if (!doc.exists) throw const NotFoundError('Nutritionist not found');
    return FirestoreMappers.nutritionistFromMap(doc.id, doc.data()!);
  }

  /// Cambia el nombre que se muestra en el perfil.
  @override
  Future<void> updateName(String name) async {
    if (name.trim().isEmpty) {
      throw const DomainValidationError('Name is required');
    }
    await FirestorePaths.user(uid).update(<String, dynamic>{
      'name': name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
