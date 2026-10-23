import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/theme/accent.dart';
import 'package:nutriplan/theme/tokens.dart';
import 'package:nutriplan/ui/components/primitives/app_stack.dart';
import 'package:nutriplan/ui/components/domain/app_tab_bar.dart';
import 'package:nutriplan/ui/screens/screen_frame.dart';

import '../../helpers/harness.dart';
import 'flows_test.dart' show goTab;

const List<String> _tabs = <String>[
  'Semana',
  'Hoy',
  'Cambiar',
  'Movimiento',
  'Progreso',
];

void main() {
  for (final String tab in _tabs) {
    testWidgets('$tab meets the accessibility guidelines', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpApp(tester);
      if (tab != 'Semana') await goTab(tester, tab);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  }

  for (final String tab in _tabs) {
    testWidgets('$tab last content clears the floating tab bar', (
      tester,
    ) async {
      await pumpApp(tester);
      if (tab != 'Semana') await goTab(tester, tab);
      final Finder frame = find.byType(ScreenFrame).hitTestable();
      final Finder scroll = find.descendant(
        of: find.byType(ScreenFrame),
        matching: find.byType(SingleChildScrollView),
      );
      final Finder visible = scroll.hitTestable();
      await tester.drag(visible, const Offset(0, -20000));
      await tester.pump(const Duration(milliseconds: 500));
      expect(frame, findsOneWidget);
      final Rect content = tester.getRect(
        find.descendant(of: visible, matching: find.byType(AppStack)).first,
      );
      final Rect bar = tester.getRect(find.byType(AppTabBar));
      final Rect viewport = tester.getRect(visible);
      final double clearance = viewport.bottom - content.bottom;
      expect(viewport.bottom - bar.top, lessThanOrEqualTo(clearance + 0.01));
    });
  }

  test('disabled button label keeps >= 4.5:1 contrast', () {
    final SemanticColors c = AppTokens.base().colors;
    expect(contrastRatio(c.textMuted, c.bgTrack), greaterThanOrEqualTo(4.5));
  });
}
