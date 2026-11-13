import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/clock.dart';
import 'device_token_service.dart';
import 'firestore/firestore_paths.dart';
import 'firestore/firestore_seeder.dart';
import 'mock/seed.dart';

/// Guarda al usuario en Firestore cuando inicia sesión y borra su cuenta.
abstract final class UserService {
  /// Prepara los datos del usuario después del login (registro o Google):
  /// crea su documento y su plan si es nuevo. El token se guarda aparte.
  static Future<void> prepare(User user, {Clock clock = DateTime.now}) async {
    final FirestoreSeeder seeder = FirestoreSeeder(clock: clock);
    await seeder.ensureCatalog();
    final DocumentReference<Map<String, dynamic>> ref = FirestorePaths.user(
      user.uid,
    );
    final DocumentSnapshot<Map<String, dynamic>> doc = await ref.get();
    if (!doc.exists) {
      final SeedData seed = SeedData.build(clock);
      await ref.set(<String, dynamic>{
        'email': user.email,
        'name': _defaultName(user),
        'birthDate': Timestamp.fromDate(seed.patient.birthDate),
        'sex': seed.patient.sex,
        'objective': seed.patient.objective,
        'nutritionistId': seed.nutritionist.id,
        'provider': _provider(user),
        'token': null,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      await seeder.seedUser(user.uid);
      return;
    }
    await ref.update(<String, dynamic>{
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
    await seeder.ensureWeek(user.uid);
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

  /// Borra la cuenta de Auth y después sus datos en Firestore. Primero Auth
  /// para que, si Firebase pide volver a iniciar sesión, no se pierda nada.
  static Future<void> deleteAccount(User user) async {
    final String uid = user.uid;
    await user.delete();
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
    await FirestorePaths.user(uid).delete();
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
