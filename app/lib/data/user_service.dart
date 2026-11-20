import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/clock.dart';
import '../domain/models/user_role.dart';
import 'device_token_service.dart';
import 'firestore/firestore_paths.dart';
import 'firestore/firestore_seeder.dart';
import 'mock/seed.dart';
import 'nutritionist_service.dart';

/// Guarda al usuario en Firestore cuando inicia sesión y borra su cuenta.
abstract final class UserService {
  /// Prepara los datos del usuario después del login (registro o Google).
  /// Si es nuevo crea su documento con [newRole]; regresa el rol guardado.
  static Future<UserRole> prepare(
    User user, {
    UserRole newRole = UserRole.patient,
    Clock clock = DateTime.now,
  }) async {
    final FirestoreSeeder seeder = FirestoreSeeder(clock: clock);
    await seeder.ensureCatalog();
    final DocumentReference<Map<String, dynamic>> ref = FirestorePaths.user(
      user.uid,
    );
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    if (!doc.exists) {
      if (newRole == UserRole.nutritionist) {
        await _createNutritionist(user);
      } else {
        await _createPatient(user, seeder, clock);
      }
      return newRole;
    }
    await ref.update(<String, dynamic>{
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
    final UserRole role = UserRole.parse(doc.data()!['role']);
    if (role == UserRole.patient) await seeder.ensureWeek(user.uid);
    return role;
  }

  /// Paciente nuevo: su documento y el plan de ejemplo.
  static Future<void> _createPatient(
    User user,
    FirestoreSeeder seeder,
    Clock clock,
  ) async {
    final SeedData seed = SeedData.build(clock);
    await FirestorePaths.user(user.uid).set(<String, dynamic>{
      'role': UserRole.patient.name,
      'email': user.email,
      'name': _defaultName(user),
      'birthDate': Timestamp.fromDate(seed.patient.birthDate),
      'sex': seed.patient.sex,
      'objective': seed.patient.objective,
      // Sin nutriólogo hasta que escanee su código QR.
      'nutritionistId': null,
      // Pide nombre, fecha de nacimiento, sexo y objetivo al entrar.
      'profileComplete': false,
      'provider': _provider(user),
      'token': null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
    await seeder.seedUser(user.uid);
  }

  /// Nutriólogo nueva: su documento y su nombre en el catálogo.
  static Future<void> _createNutritionist(User user) async {
    final String name = _defaultName(user);
    final WriteBatch batch = FirestorePaths.db.batch();
    batch.set(FirestorePaths.user(user.uid), <String, dynamic>{
      'role': UserRole.nutritionist.name,
      'email': user.email,
      'name': name,
      'provider': _provider(user),
      'token': null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
    batch.set(FirestorePaths.nutritionist(user.uid), <String, dynamic>{
      'name': name,
    });
    await batch.commit();
  }

  /// Pide el permiso de notificaciones y guarda el token del dispositivo.
  /// Va aparte porque espera a que el usuario conteste el permiso.
  static Future<void> saveDeviceToken(String uid) async {
    final String? token = await DeviceTokenService.token();
    await FirestorePaths.user(uid).update(<String, dynamic>{
      'token': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Lee el documento del usuario (por ejemplo, para mostrar su token).
  static Future<Map<String, dynamic>> accountInfo(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirestorePaths.user(uid).get();
    return doc.data() ?? <String, dynamic>{};
  }

  /// Borra los datos en Firestore y después la cuenta de Auth. Los datos van
  /// primero porque las reglas solo dejan escribir con sesión iniciada.
  static Future<void> deleteAccount(User user) async {
    final String uid = user.uid;
    // Firebase pide un login reciente para borrar la cuenta; se revisa antes
    // de tocar los datos para no dejarlos a medias.
    final DateTime? lastSignIn = user.metadata.lastSignInTime;
    if (lastSignIn == null ||
        DateTime.now().difference(lastSignIn) > const Duration(minutes: 5)) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    for (final CollectionReference<Map<String, dynamic>> c
        in <CollectionReference<Map<String, dynamic>>>[
          FirestorePaths.days(uid),
          FirestorePaths.activityLogs(uid),
          FirestorePaths.measurements(uid),
        ]) {
      final QuerySnapshot<Map<String, dynamic>> snap = await c.get();
      final WriteBatch batch = FirestorePaths.db.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    await FirestorePaths.plan(uid).delete();
    // Si era nutriólogo, sus pacientes quedan sin nutriólogo.
    for (final p in await NutritionistService.patientsOf(uid)) {
      await NutritionistService.unlink(p.uid);
    }
    await FirestorePaths.nutritionist(uid).delete();
    await FirestorePaths.user(uid).delete();
    await user.delete();
  }

  /// Nombre inicial: el de Google, o la parte del correo antes de la @.
  static String _defaultName(User user) {
    final String? display = user.displayName;
    if (display != null && display.trim().isNotEmpty) return display.trim();
    final String local = (user.email ?? '').split('@').first;
    if (local.isEmpty) return SeedData.build(DateTime.now).patient.name;
    return local[0].toUpperCase() + local.substring(1);
  }

  static String _provider(User user) => user.providerData.isEmpty
      ? 'password'
      : user.providerData.first.providerId;
}
