import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/app.dart';
import 'package:nutriplan/application/app_controllers.dart';

import '../../fakes/mock_controllers.dart';

import 'package:nutriplan/theme/accent_controller.dart';
import 'package:nutriplan/domain/models/plan.dart';
import 'package:nutriplan/ui/components/domain/app_tab_bar.dart';

import '../../helpers/harness.dart';

Future<void> goTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(AppTabBar), matching: find.text(label)),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('Semana shows the selected day and meal progress', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.textContaining(' de 4 comidas'), findsOneWidget);
  });

  testWidgets('Cambiar alternatives offer a way back to the meal list', (
    tester,
  ) async {
    final AppControllers c = await pumpApp(tester);
    await goTab(tester, 'Hoy');
    await tester.ensureVisible(find.text('Se me antoja otra cosa'));
    await tester.pump();
    await tester.tap(find.text('Se me antoja otra cosa'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.shell.pendingSwap, isNotNull);
    await tester.tap(find.text('Elegir otra comida'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(c.shell.pendingSwap, isNull);
    expect(find.text('¿Cuál comida quieres cambiar?'), findsOneWidget);
    expect(
      find.text(
        'Elige una comida de hoy para ver equivalentes del mismo grupo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Cambiar picker explains when every meal is done', (
    tester,
  ) async {
    final AppControllers c = await pumpApp(tester);
    final DayPlan day = c.plan.todayPlan!;
    for (final Meal m in day.meals) {
      if (!m.done) {
        unawaited(c.plan.toggleDone(day.date, m.id));
        await tester.pump(const Duration(seconds: 1));
      }
    }
    await goTab(tester, 'Cambiar');
    expect(find.text('Ya completaste las comidas de hoy'), findsOneWidget);
  });

  testWidgets('loading state is announced as Cargando', (tester) async {
    final SemanticsHandle h = tester.ensureSemantics();
    useIphoneViewport(tester);
    final AppControllers c = buildAppControllers(
      clock: fixedNow,
      latency: const Duration(milliseconds: 300),
    );
    addTearDown(c.dispose);
    await tester.pumpWidget(
      NutriPlanApp(controllers: c, accent: AccentController()),
    );
    expect(find.bySemanticsLabel('Cargando'), findsWidgets);
    unawaited(c.loadAll());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    h.dispose();
  });
}
