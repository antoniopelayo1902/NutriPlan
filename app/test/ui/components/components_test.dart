import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriplan/application/toast_controller.dart';
import 'package:nutriplan/core/i18n/strings_es_mx.dart';
import 'package:nutriplan/domain/models/fit.dart';
import 'package:nutriplan/domain/models/food_group.dart';
import 'package:nutriplan/domain/models/portions.dart';
import 'package:nutriplan/domain/services/adherence.dart';
import 'package:nutriplan/theme/app_theme.dart';
import 'package:nutriplan/ui/components/actions/app_button.dart';
import 'package:nutriplan/ui/components/actions/app_chip.dart';
import 'package:nutriplan/ui/components/actions/app_icon_button.dart';
import 'package:nutriplan/ui/components/actions/app_toggle_button.dart';
import 'package:nutriplan/ui/components/actions/segmented_control.dart';
import 'package:nutriplan/ui/components/data_display/app_badge.dart';
import 'package:nutriplan/ui/components/data_display/bar_chart.dart';
import 'package:nutriplan/ui/components/data_display/body_map.dart';
import 'package:nutriplan/ui/components/data_display/day_picker.dart';
import 'package:nutriplan/ui/components/data_display/fit_badge.dart';
import 'package:nutriplan/ui/components/data_display/progress_bar.dart';
import 'package:nutriplan/ui/components/domain/app_tab_bar.dart';
import 'package:nutriplan/ui/components/domain/meal_card.dart';
import 'package:nutriplan/ui/components/primitives/app_icon.dart';
import 'package:nutriplan/ui/components/primitives/app_text.dart';
import 'package:nutriplan/ui/components/primitives/skeleton.dart';

import '../../helpers/harness.dart';

Color? fillOf(WidgetTester t, Finder f) {
  final box = t.widget<DecoratedBox>(
    find.descendant(of: f, matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  group('AppButton', () {
    testWidgets('variants render and fire', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        themed(
          Column(
            children: [
              for (final v in ButtonVariant.values)
                AppButton(label: v.name, variant: v, onPressed: () => taps++),
            ],
          ),
        ),
      );
      for (final v in ButtonVariant.values) {
        await tester.tap(find.text(v.name));
      }
      expect(taps, ButtonVariant.values.length);
    });

    testWidgets('disabled blocks onPressed and loading too', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        themed(
          Column(
            children: [
              const AppButton(label: 'off', onPressed: null),
              AppButton(label: 'busy', loading: true, onPressed: () => taps++),
            ],
          ),
        ),
      );
      await tester.tap(find.text('off'), warnIfMissed: false);
      await tester.tap(find.text('busy'), warnIfMissed: false);
      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hit target is at least 44x44', (tester) async {
      await tester.pumpWidget(themed(AppButton(label: 'x', onPressed: () {})));
      final s = tester.getSize(find.byType(AppButton));
      expect(s.height, greaterThanOrEqualTo(44));
      expect(s.width, greaterThanOrEqualTo(44));
    });
  });

  testWidgets('AppToggleButton exposes toggled semantics and swaps variant', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    bool on = false;
    await tester.pumpWidget(
      themed(
        StatefulBuilder(
          builder: (c, set) => AppToggleButton(
            label: on ? 'Hecho' : 'Marcar',
            pressed: on,
            onPressed: () => set(() => on = !on),
          ),
        ),
      ),
    );
    var node = tester.getSemantics(find.byType(AppToggleButton));
    expect(node.flagsCollection.isToggled, Tristate.isFalse);
    final offFill = fillOf(tester, find.byType(AppToggleButton));
    await tester.tap(find.byType(AppToggleButton));
    await tester.pump();
    node = tester.getSemantics(find.byType(AppToggleButton));
    expect(node.flagsCollection.isToggled, Tristate.isTrue);
    expect(fillOf(tester, find.byType(AppToggleButton)), isNot(offFill));
    handle.dispose();
  });

  group('FitBadge', () {
    test('labels and tones', () {
      expect(FitBadge.labelOf(Fit.yes), 'cabe hoy');
      expect(FitBadge.labelOf(Fit.adjust), 'ajusta');
      expect(FitBadge.labelOf(Fit.no), 'no cabe');
      expect(FitBadge.toneOf(Fit.yes), BadgeTone.success);
      expect(FitBadge.toneOf(Fit.adjust), BadgeTone.warning);
      expect(FitBadge.toneOf(Fit.no), BadgeTone.danger);
    });
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(themed(const FitBadge(Fit.adjust)));
      expect(find.text('ajusta'), findsOneWidget);
    });
  });

  group('ProgressBar', () {
    test('auto warning when value exceeds max', () {
      expect(
        const ProgressBar(value: 5, max: 4).effectiveTone,
        BarTone.warning,
      );
      expect(const ProgressBar(value: 4, max: 4).effectiveTone, BarTone.accent);
      expect(
        const ProgressBar(
          value: 5,
          max: 4,
          tone: BarTone.success,
        ).effectiveTone,
        BarTone.warning,
      );
    });
    testWidgets('exposes a semantics value', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        themed(
          const SizedBox(
            width: 300,
            child: ProgressBar(
              value: 1,
              max: 2,
              label: 'Frutas',
              valueLabel: '1 de 2',
            ),
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(ProgressBar));
      expect(node.value, '1 de 2');
      expect(node.label, 'Frutas');
      handle.dispose();
    });
  });

  group('BarChart', () {
    testWidgets('one summarizing semantics label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        themed(
          const SizedBox(
            width: 300,
            child: BarChart(
              data: [
                BarDatum(label: 'L', value: 10, valueLabel: '10 min'),
                BarDatum(label: 'M', value: 0, state: BarState.empty),
              ],
            ),
          ),
        ),
      );
      final node = tester.getSemantics(find.byType(BarChart));
      expect(node.label, 'L 10 min, M 0');
      handle.dispose();
    });

    testWidgets('empty bars keep a stub height', (tester) async {
      await tester.pumpWidget(
        themed(
          const SizedBox(
            width: 300,
            child: BarChart(
              data: [
                BarDatum(label: 'L', value: 10),
                BarDatum(label: 'M', value: 0, state: BarState.empty),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bars = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((w) => w.constraints!.maxHeight)
          .toList();
      expect(bars[1], 6);
      expect(bars[0], greaterThan(bars[1]));
    });
  });

  testWidgets('DayPicker selection and semantics', (tester) async {
    final handle = tester.ensureSemantics();
    int? picked;
    await tester.pumpWidget(
      themed(
        SizedBox(
          width: 400,
          child: DayPicker(
            selected: 1,
            onSelect: (i) => picked = i,
            days: [
              for (int i = 0; i < 7; i++)
                DayPickerDay(
                  label: 'L',
                  number: i + 1,
                  status: DayStatus.partial,
                  semanticLabel: 'dia ${i + 1}',
                ),
            ],
          ),
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('dia 2'))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('dia 3'))
          .flagsCollection
          .isSelected,
      Tristate.isFalse,
    );
    await tester.tap(find.text('5'));
    expect(picked, 4);
    handle.dispose();
  });

  testWidgets('SegmentedControl switches value', (tester) async {
    String v = 'a';
    await tester.pumpWidget(
      themed(
        StatefulBuilder(
          builder: (c, set) => SegmentedControl<String>(
            value: v,
            onChanged: (x) => set(() => v = x),
            options: const [
              SegmentOption('a', 'Uno'),
              SegmentOption('b', 'Dos'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dos'));
    await tester.pump();
    expect(v, 'b');
  });

  testWidgets('AppIconButton sm and AppChip sm keep a 44x44 hit area', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        Row(
          children: [
            AppIconButton(
              icon: AppIconName.close,
              semanticLabel: 'x',
              size: IconButtonSize.sm,
              onPressed: () {},
            ),
            AppChip(label: 'a', size: ChipSize.sm, onPressed: () {}),
          ],
        ),
      ),
    );
    for (final f in [find.byType(AppIconButton), find.byType(AppChip)]) {
      final s = tester.getSize(f);
      expect(s.height, greaterThanOrEqualTo(44));
      expect(s.width, greaterThanOrEqualTo(44));
    }
  });

  testWidgets('AppChip exposes selected semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(AppChip(label: 'a', selected: true, onPressed: () {})),
    );
    expect(
      tester.getSemantics(find.byType(AppChip)).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    handle.dispose();
  });

  testWidgets('AppTabBar selection and tap', (tester) async {
    final handle = tester.ensureSemantics();
    int? tapped;
    await tester.pumpWidget(
      themed(
        SizedBox(
          width: 380,
          child: AppTabBar(
            active: 2,
            onSelect: (i) => tapped = i,
            items: const [
              AppTabItem(AppIconName.calendar, 'Semana'),
              AppTabItem(AppIconName.today, 'Hoy'),
              AppTabItem(AppIconName.swap, 'Cambiar'),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Cambiar')).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(find.text('Hoy')).flagsCollection.isSelected,
      Tristate.isFalse,
    );
    await tester.tap(find.text('Hoy'));
    expect(tapped, 1);
    handle.dispose();
  });

  testWidgets('MealCard callbacks and swapped badge', (tester) async {
    int change = 0, toggle = 0;
    await tester.pumpWidget(
      themed(
        SizedBox(
          width: 380,
          child: MealCard(
            slotLabel: 'Comida',
            time: '14:30',
            dish: 'Plato',
            portions: Portions({FoodGroup.cereal: 1, FoodGroup.fruta: 1}),
            done: false,
            swapped: true,
            onChange: () => change++,
            onToggle: () => toggle++,
          ),
        ),
      ),
    );
    expect(find.text('cambiado'), findsOneWidget);
    expect(find.text('1 Cereal'), findsOneWidget);
    expect(find.text('1 Fruta'), findsOneWidget);
    await tester.tap(find.text('Cambiar'));
    await tester.tap(find.text('Marcar'));
    expect((change, toggle), (1, 1));
  });

  testWidgets('BodyMap shows 8 labeled sites', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        SizedBox(
          width: 360,
          child: BodyMap(
            sites: [
              for (final id in BodySiteId.values)
                BodySiteData(
                  id: id,
                  label: S.siteLabels[id.name]!,
                  valueLabel: '1 mm',
                ),
            ],
          ),
        ),
      ),
    );
    for (final label in S.siteLabels.values) {
      expect(
        find.bySemanticsLabel('$label 1 mm'),
        findsOneWidget,
        reason: label,
      );
    }
    handle.dispose();
  });

  testWidgets('Toast queue shows messages in order', (tester) async {
    final t = ToastController(duration: const Duration(milliseconds: 100));
    addTearDown(t.dispose);
    final seen = <String>[];
    t.addListener(() {
      if (t.current != null) seen.add(t.current!.text);
    });
    t.show('uno');
    t.show('dos');
    await tester.pump(const Duration(milliseconds: 150));
    expect(t.current!.text, 'dos');
    await tester.pump(const Duration(milliseconds: 150));
    expect(seen, ['uno', 'dos']);
    expect(t.current, isNull);
  });

  testWidgets('Skeleton is static with disableAnimations', (tester) async {
    await tester.pumpWidget(
      themed(
        const SizedBox(width: 100, child: Skeleton()),
        disableAnimations: true,
      ),
    );
    expect(
      find.descendant(
        of: find.byType(Skeleton),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    await tester.pumpWidget(
      themed(const SizedBox(width: 100, child: Skeleton())),
    );
    expect(
      find.descendant(
        of: find.byType(Skeleton),
        matching: find.byType(FadeTransition),
      ),
      findsOneWidget,
    );
  });

  testWidgets('fonts resolve for AppText (display and ui)', (tester) async {
    await tester.pumpWidget(
      themed(
        const Column(
          children: [
            AppText('Mi semana', variant: TextVariant.titleLg),
            AppText('Hola', variant: TextVariant.bodyMd),
          ],
        ),
      ),
    );
    final styles = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.style!.fontFamily)
        .toList();
    expect(styles, ['Newsreader', 'WorkSans']);
    final ctx = tester.element(find.byType(AppText).first);
    expect(tokensOf(ctx).typo.eyebrow.fontStyle, FontStyle.italic);
  });
}
