import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_emulators.dart';

/// Notificaciones con Firebase Cloud Messaging, como en la clase.
abstract final class DeviceTokenService {
  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Pide permiso de notificaciones y regresa el token del dispositivo.
  /// En iOS sin token de APNs (simulador o sin llave en Firebase) es null.
  static Future<String?> token() async {
    // Con emuladores (pruebas) no hay notificaciones: se omite el permiso.
    if (FirebaseEmulators.enabled) return null;
    try {
      await _messaging.requestPermission();
      if (Platform.isIOS && await _messaging.getAPNSToken() == null) {
        return null;
      }
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Título de cada notificación que llega con la app abierta.
  static Stream<String> foregroundTitles() => FirebaseMessaging.onMessage
      .map((RemoteMessage m) => m.notification?.title ?? '')
      .where((String title) => title.isNotEmpty);
}
