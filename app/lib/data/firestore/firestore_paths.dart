import 'package:cloud_firestore/cloud_firestore.dart';

/// Nombres de las colecciones de Firestore en un solo lugar.
abstract final class FirestorePaths {
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static const String users = 'users';
  static const String nutritionists = 'nutritionists';
  static const String options = 'options';

  static CollectionReference<Map<String, dynamic>> usersCollection() =>
      db.collection(users);

  /// users/{uid}: perfil del paciente y token del dispositivo.
  static DocumentReference<Map<String, dynamic>> user(String uid) =>
      db.collection(users).doc(uid);

  /// users/{uid}/plan/current: datos generales del plan.
  static DocumentReference<Map<String, dynamic>> plan(String uid) =>
      user(uid).collection('plan').doc('current');

  /// users/{uid}/days: un documento por día con sus comidas.
  static CollectionReference<Map<String, dynamic>> days(String uid) =>
      user(uid).collection('days');

  /// users/{uid}/activityLogs: sesiones de actividad (el CRUD).
  static CollectionReference<Map<String, dynamic>> activityLogs(String uid) =>
      user(uid).collection('activityLogs');

  /// users/{uid}/measurements: medidas de cada consulta.
  static CollectionReference<Map<String, dynamic>> measurements(String uid) =>
      user(uid).collection('measurements');

  static CollectionReference<Map<String, dynamic>> optionsCollection() =>
      db.collection(options);

  static DocumentReference<Map<String, dynamic>> nutritionist(String id) =>
      db.collection(nutritionists).doc(id);
}
