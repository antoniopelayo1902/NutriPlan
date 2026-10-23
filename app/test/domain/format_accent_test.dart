import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/core/format/es_mx_format.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/theme/accent.dart';
import 'package:nutriplan/theme/primitives.dart';
import 'package:nutriplan/theme/tokens.dart';

import 'helpers.dart';

void main() {
  group('formatters', () {
    test('decimals use a comma', () {
      expect(formatDecimal(71.2), '71,2');
      expect(formatDecimal(0), '0,0');
      expect(formatDecimal(1.63, digits: 2), '1,63');
    });
    test('thousands use a comma', () {
      expect(formatInt(1820), '1,820');
      expect(formatInt(999), '999');
      expect(formatInt(1234567), '1,234,567');
      expect(formatInt(0), '0');
    });
    test('negatives use U+2212 and positives get +', () {
      expect(formatSigned(-1.8), '−1,8');
      expect(formatSigned(1.2), '+1,2');
      expect(formatSigned(0), '0,0');
      expect(formatSigned(-0.01), '0,0');
      expect(formatSignedInt(4), '+4');
      expect(formatSignedInt(-8), '−8');
      expect(formatSignedInt(0), '0');
      expect(formatInt(-1500), '−1,500');
    });
    test('units and minutes', () {
      expect(formatWithUnit(formatDecimal(71.2), 'kg'), '71,2 kg');
      expect(formatMinutes(30), '30′');
    });
    test('portions', () {
      expect(formatPortion(0), '0');
      expect(formatPortion(0.5), '½');
      expect(formatPortion(1), '1');
      expect(formatPortion(1.5), '1½');
      expect(formatPortion(2), '2');
    });
    test('portion tags use singular/plural in fixed order', () {
      expect(
        formatPortionTags(
          p(<FoodGroup, double>{FoodGroup.fruta: 1, FoodGroup.cereal: 1}),
        ),
        '1 Cereal · 1 Fruta',
      );
      expect(
        formatPortionTags(
          p(<FoodGroup, double>{FoodGroup.cereal: 2, FoodGroup.grasa: 0.5}),
        ),
        '2 Cereales · ½ Grasa',
      );
    });
    test('dates', () {
      expect(formatLongDate(DateTime(2025, 10, 8)), 'miércoles 8 de octubre');
      expect(formatDayMonth(DateTime(2026, 9, 12)), '12 de septiembre');
      expect(formatTime('08:00'), '8:00');
      expect(formatTime('14:30'), '14:30');
    });
  });

  group('accent', () {
    const surface = Prim.sand0;
    test('default terracotta text accent has contrast >= 4.5', () {
      expect(
        contrastRatio(deriveTextAccent(Prim.terracotta500, surface), surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(Prim.terracotta700, surface),
        greaterThanOrEqualTo(4.5),
      );
    });
    for (final entry in <String, Color>{
      'light yellow': const Color(0xFFFFEB3B),
      'teal': const Color(0xFF009688),
      'purple': const Color(0xFF9C27B0),
      'white-ish': const Color(0xFFFFFFE0),
    }.entries) {
      test('${entry.key} accent derives readable text', () {
        final d = deriveTextAccent(entry.value, surface);
        expect(contrastRatio(d, surface), greaterThanOrEqualTo(4.5));
        final t = AppTokens.withAccent(entry.value);
        expect(t.colors.accent, entry.value);
        expect(
          contrastRatio(t.colors.textAccent, t.colors.bgSurface),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });

  group('tokens', () {
    final t = AppTokens.base();
    test('match the spec', () {
      expect(t.space.s4, 16);
      expect(t.space.s12, 104);
      expect(t.radius.xl, 24);
      expect(t.radius.bar.topLeft.x, 10);
      expect(t.radius.bar.bottomLeft.x, 5);
      expect(t.size.hitMin, 48);
      expect(t.colors.accent, Prim.terracotta500);
      expect(t.colors.textMuted, Prim.sand800);
      expect(t.colors.fitNoFg, Prim.brick700);
      expect(t.typo.displayXl.fontSize, 52);
      expect(t.typo.displayXl.letterSpacing, closeTo(-2.08, 1e-9));
      expect(t.typo.displayXl.fontFamily, 'Newsreader');
      expect(t.typo.bodyMd.fontFamily, 'WorkSans');
      expect(t.motion.base, const Duration(milliseconds: 220));
      expect(t.shadow.card.length, 2);
    });
    test('copyWith and lerp', () {
      final other = t.accentTo(const Color(0xFF009688));
      expect(other.colors.accent, const Color(0xFF009688));
      expect(t.lerp(other, 1).colors.accent, const Color(0xFF009688));
      expect(t.lerp(other, 0).colors.accent, Prim.terracotta500);
      expect(t.copyWith(space: t.space).colors, t.colors);
    });
  });

  test('fonts are bundled', () {
    for (final f in <String>[
      'Newsreader.ttf',
      'Newsreader-Italic.ttf',
      'WorkSans.ttf',
      'OFL-Newsreader.txt',
      'OFL-WorkSans.txt',
    ]) {
      expect(File('assets/fonts/$f').existsSync(), isTrue, reason: f);
    }
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('family: WorkSans'),
    );
  });
}
