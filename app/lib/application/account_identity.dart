import 'package:flutter/foundation.dart';

/// Lo que el perfil necesita de cualquier cuenta (paciente o nutrióloga).
abstract interface class AccountIdentity implements Listenable {
  String? get displayName;
  String get initials;

  /// Cambia el nombre en la base de datos. Regresa false si falla.
  Future<bool> rename(String name);
}

/// Hasta dos iniciales del nombre, en mayúsculas.
String initialsOf(String name) {
  final List<String> parts = name
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  final String second = parts.length > 1 ? parts[1].substring(0, 1) : '';
  return (parts.first.substring(0, 1) + second).toUpperCase();
}
