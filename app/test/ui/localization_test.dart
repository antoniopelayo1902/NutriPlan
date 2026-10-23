import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('app runs in es-MX with Spanish built-in strings', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    final BuildContext context = tester.element(find.byType(Navigator).first);
    expect(Localizations.localeOf(context), const Locale('es', 'MX'));
    expect(MaterialLocalizations.of(context).backButtonTooltip, 'Atrás');
  });
}
