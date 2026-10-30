import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> dartFiles(String dir) =>
    Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();

String strip(String src) => src
    .split('\n')
    .where((String l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  final List<File> all = dartFiles('lib');

  test('domain and formatters do not import flutter', () {
    for (final File f in all.where(
      (File f) =>
          f.path.startsWith('lib/domain/') || f.path.startsWith('lib/core/'),
    )) {
      final String s = f.readAsStringSync();
      expect(s.contains('package:flutter'), isFalse, reason: f.path);
      expect(s.contains('dart:ui'), isFalse, reason: f.path);
    }
  });

  test('raw colors only live in theme/primitives.dart', () {
    final RegExp bad = RegExp(
      r'Color\(0x|(?<![A-Za-z])Colors\.|#[0-9A-Fa-f]{6}\b',
    );
    for (final File f in all.where(
      (File f) => !f.path.endsWith('theme/primitives.dart'),
    )) {
      expect(
        bad.hasMatch(strip(f.readAsStringSync())),
        isFalse,
        reason: f.path,
      );
    }
  });

  test('ui has no raw font, padding, radius or size numbers', () {
    final List<RegExp> rules = <RegExp>[
      RegExp(r'fontSize:'),
      RegExp(r'fontFamily:'),
      RegExp(
        r'EdgeInsets\.\w+\((?:[^()]|\([^()]*\))*?(?<![\w.])[1-9]\d*(\.\d+)?',
      ),
      RegExp(r'BorderRadius\.circular\(\s*[1-9]'),
      RegExp(r'SizedBox\(\s*(height|width):\s*[1-9]'),
    ];
    for (final File f in all.where((File f) => f.path.startsWith('lib/ui/'))) {
      final String s = strip(f.readAsStringSync());
      for (final RegExp r in rules) {
        expect(r.hasMatch(s), isFalse, reason: '${f.path} ${r.pattern}');
      }
    }
  });

  test('no Spanish copy outside the strings file', () {
    final RegExp literal = RegExp(
      r'''(['"])[^'"\n]*[áéíóúñÁÉÍÓÚÑ¿¡][^'"\n]*\1''',
    );
    for (final File f in all.where((File f) => f.path.startsWith('lib/ui/'))) {
      expect(
        literal.hasMatch(strip(f.readAsStringSync())),
        isFalse,
        reason: f.path,
      );
    }
    // And no accented literals in application/data code except the seed.
    for (final File f in all.where(
      (File f) =>
          f.path.startsWith('lib/application/') ||
          f.path.startsWith('lib/theme/'),
    )) {
      expect(
        literal.hasMatch(strip(f.readAsStringSync())),
        isFalse,
        reason: f.path,
      );
    }
  });

  test('no logging calls', () {
    final RegExp log = RegExp(
      r'(?<![A-Za-z_.])(print|debugPrint|log)\(|developer\.log',
    );
    for (final File f in all) {
      expect(
        log.hasMatch(strip(f.readAsStringSync())),
        isFalse,
        reason: f.path,
      );
    }
  });

  test('pubspec runtime dependencies are the Flutter SDK packages, cupertino_icons and Firebase Auth', () {
    final String y = File('pubspec.yaml').readAsStringSync();
    final String deps = y
        .split('dependencies:')[1]
        .split('dev_dependencies:')[0];
    final List<String> names = RegExp(
      r'^  (\w+):',
      multiLine: true,
    ).allMatches(deps).map((RegExpMatch m) => m.group(1)!).toList();
    expect(names, <String>[
      'flutter',
      'flutter_localizations',
      'cupertino_icons',
      'firebase_core',
      'firebase_auth',
      'google_sign_in',
    ]);
  });

  test('android manifest hygiene', () {
    final String m = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(m.contains('android:allowBackup="false"'), isTrue);
    expect(m.contains('INTERNET'), isFalse);
  });
}
