import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver de las pruebas end to end. Guarda las capturas que toma la prueba
/// en la carpeta indicada por SCREENSHOT_DIR (o en build/screenshots).
Future<void> main() async {
  final String dir = Platform.environment['SCREENSHOT_DIR'] ?? 'build/screenshots';
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final File file = File('$dir/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}
