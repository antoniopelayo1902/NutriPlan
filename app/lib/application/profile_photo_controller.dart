import 'package:flutter/foundation.dart';

/// Ruta local de la foto de perfil. Avisa con notifyListeners cuando cambia
/// para que el avatar de todas las pantallas se redibuje (Provider).
class ProfilePhotoController extends ChangeNotifier {
  ProfilePhotoController({
    required Future<String?> Function() load,
    required Future<String> Function(String sourcePath) save,
  }) : _load = load,
       _save = save;

  /// Sin foto y sin guardar nada (widget tests).
  ProfilePhotoController.none() : _load = _nothing, _save = _same;

  static Future<String?> _nothing() async => null;
  static Future<String> _same(String path) async => path;

  final Future<String?> Function() _load;
  final Future<String> Function(String) _save;

  String? _path;

  String? get path => _path;

  /// Lee la foto que ya estaba guardada en el teléfono.
  Future<void> load() async {
    _path = await _load();
    notifyListeners();
  }

  /// Guarda la imagen elegida como nueva foto de perfil.
  Future<void> set(String sourcePath) async {
    _path = await _save(sourcePath);
    notifyListeners();
  }
}
