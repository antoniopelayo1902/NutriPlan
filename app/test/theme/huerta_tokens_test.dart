import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/theme/accent.dart';
import 'package:nutriplan/theme/food_color.dart';
import 'package:nutriplan/theme/food_palette.dart';
import 'package:nutriplan/theme/primitives.dart';
import 'package:nutriplan/theme/tokens.dart';

void main() {
  final SemanticColors c = AppTokens.base().colors;

  test('text on primary, soft and highlight fills is AA', () {
    final List<(String, Color, Color)> pairs = <(String, Color, Color)>[
      ('primaryInk/primary', c.primaryInk, c.primary),
      ('accentInk/accentSoft', c.accentInk, c.accentSoft),
      ('secondaryInk/secondarySoft', c.secondaryInk, c.secondarySoft),
      ('highlightInk/highlightSoft', c.highlightInk, c.highlightSoft),
      ('messageInk/messageSoft', c.messageInk, c.messageSoft),
      ('fitYesFg/Bg', c.fitYesFg, c.fitYesBg),
      ('fitAdjustFg/Bg', c.fitAdjustFg, c.fitAdjustBg),
      ('fitNoFg/Bg', c.fitNoFg, c.fitNoBg),
      ('textPrimary/highlight', c.textPrimary, c.highlight),
    ];
    for (final (String, Color, Color) p in pairs) {
      expect(
        contrastRatio(p.$2, p.$3),
        greaterThanOrEqualTo(4.5),
        reason: p.$1,
      );
    }
  });

  test('every food group ink is AA on its soft background', () {
    for (final FoodGroup g in FoodGroup.values) {
      final FoodTone tone = foodColor(c, g);
      expect(
        contrastRatio(tone.ink, tone.soft),
        greaterThanOrEqualTo(4.5),
        reason: g.name,
      );
    }
  });

  test('budgeted groups map to distinct tones; azucar borrows cereal', () {
    final Set<FoodTone> tones = <FoodTone>{
      for (final FoodGroup g in FoodGroup.budgeted) foodColor(c, g),
    };
    expect(tones.length, 7);
    expect(foodColor(c, FoodGroup.azucar), c.food.cereal);
    expect(c.foodVerdura, FoodHue.verdura500);
  });

  test(
    'primary re-themes bgInverse and textInverse; accent re-themes ring',
    () {
      expect(c.bgInverse, c.primary);
      expect(c.textInverse, c.primaryInk);
      expect(c.primary, Hue.deep500);
      final SemanticColors other = c.withAccent(Hue.pop500);
      expect(other.accent, Hue.pop500);
      expect(other.primary, c.primary);
    },
  );
}
