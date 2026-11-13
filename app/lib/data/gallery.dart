import 'package:image_picker/image_picker.dart';

/// Abre la galería del teléfono con image_picker.
abstract final class Gallery {
  /// Regresa la ruta de la imagen elegida, o null si el usuario cancela.
  static Future<String?> pickImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 90,
    );
    return file?.path;
  }
}
