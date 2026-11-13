import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Foto de perfil guardada solo en el teléfono (sin Firebase Storage).
abstract final class ProfilePhotoStore {
  static Future<Directory> _dir() => getApplicationDocumentsDirectory();

  static String _prefix(String uid) => 'profile_$uid';

  /// Copia la imagen a la carpeta de la app y borra la foto anterior.
  /// El nombre lleva la hora para que Flutter no muestre la imagen vieja.
  static Future<String> save(String uid, String sourcePath) async {
    await delete(uid);
    final Directory dir = await _dir();
    final String target =
        '${dir.path}/${_prefix(uid)}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(sourcePath).copy(target);
    return target;
  }

  /// Ruta de la foto guardada del usuario, o null si no tiene.
  static Future<String?> load(String uid) async {
    final Directory dir = await _dir();
    for (final FileSystemEntity f in dir.listSync()) {
      if (f is File && f.uri.pathSegments.last.startsWith(_prefix(uid))) {
        return f.path;
      }
    }
    return null;
  }

  static Future<void> delete(String uid) async {
    final Directory dir = await _dir();
    for (final FileSystemEntity f in dir.listSync()) {
      if (f is File && f.uri.pathSegments.last.startsWith(_prefix(uid))) {
        await f.delete();
      }
    }
  }
}
