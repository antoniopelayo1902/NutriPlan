import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/errors.dart';
import '../../domain/models/patient.dart';
import '../../domain/repositories/patient_repository.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

/// Datos del paciente (users/{uid}) y de su nutriólogo.
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
  Future<Nutritionist?> getNutritionist() async {
    final String? id = (await getPatient()).nutritionistId;
    if (id == null) return null;
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirestorePaths.nutritionist(id).get();
    if (!doc.exists) return null;
    return FirestoreMappers.nutritionistFromMap(doc.id, doc.data()!);
  }

  /// Guarda los datos del registro y marca el perfil como completo.
  @override
  Future<void> updateProfile({
    required String name,
    required DateTime birthDate,
    required String sex,
    required String objective,
  }) async {
    if (name.trim().isEmpty) {
      throw const DomainValidationError('Name is required');
    }
    await FirestorePaths.user(uid).update(<String, dynamic>{
      'name': name.trim(),
      'birthDate': Timestamp.fromDate(birthDate),
      'sex': sex,
      'objective': objective,
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
