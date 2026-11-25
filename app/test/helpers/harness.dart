import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/app.dart';
import 'package:nutriplan/application/app_controllers.dart';

import '../fakes/mock_controllers.dart';

import 'package:nutriplan/core/flags.dart';

import '../fakes/scenario.dart';

import 'package:nutriplan/theme/accent_controller.dart';
import 'package:nutriplan/theme/app_theme.dart';

/// Thursday, 8 October 2026, 10:00.
DateTime fixedNow() => DateTime(2026, 10, 8, 10);

/// 402x874 logical pixels at 1x.
void useIphoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<AppControllers> pumpApp(
  WidgetTester tester, {
  Scenario scenario = Scenario.normal,
  Flags flags = const Flags(),
  Duration latency = Duration.zero,
  AccentController? accent,
}) async {
  useIphoneViewport(tester);
  final AppControllers c = buildAppControllers(
    clock: fixedNow,
    scenario: scenario,
    flags: flags,
    latency: latency,
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    NutriPlanApp(controllers: c, accent: accent ?? AccentController()),
  );
  unawaited(c.loadAll());
  await settleLoading(tester, c);
  return c;
}

/// Wraps [child] in the themed app chrome for component tests.
Widget themed(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: buildTheme(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Material(
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
}

/// Pumps until every controller finished its initial load.
Future<void> settleLoading(WidgetTester tester, AppControllers c) async {
  for (int i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 10));
    if (!c.plan.loading &&
        !c.activity.loading &&
        !c.progress.loading &&
        c.profile.patient != null) {
      break;
    }
  }
  await tester.pump();
}
