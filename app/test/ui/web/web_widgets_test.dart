import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/domain/models/patient_summary.dart';
import 'package:nutriplan/theme/app_theme.dart';
import 'package:nutriplan/ui/web/web_no_selection.dart';
import 'package:nutriplan/ui/web/web_patient_tile.dart';

Widget _host(Widget child) => MaterialApp(
  theme: buildTheme(),
  home: Scaffold(body: child),
);

void main() {
  const PatientSummary patient = PatientSummary(
    uid: 'p1',
    name: 'Laura Mena',
    email: 'laura@example.com',
    objective: 'Bajar de peso',
  );

  testWidgets('patient tile shows name and reports taps', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        WebPatientTile(
          key: const Key('patient-p1'),
          patient: patient,
          selected: true,
          onTap: () => taps++,
        ),
      ),
    );
    expect(find.text('Laura Mena'), findsOneWidget);
    expect(find.text('Bajar de peso'), findsOneWidget);
    await tester.tap(find.byKey(const Key('patient-p1')));
    expect(taps, 1);
  });

  testWidgets('no-selection pane adapts to having patients or not', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(const WebNoSelection(hasPatients: true)));
    expect(find.byKey(const Key('noSelection')), findsOneWidget);
    expect(find.text('Elige un paciente'), findsOneWidget);
    await tester.pumpWidget(_host(const WebNoSelection(hasPatients: false)));
    expect(find.textContaining('código QR'), findsOneWidget);
  });
}
