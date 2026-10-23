import 'package:flutter/widgets.dart';

import '../../../application/app_controllers.dart';
import '../../../application/shell_controller.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/equivalent_option.dart';
import '../../../domain/models/fit.dart';
import '../../../domain/models/plan.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/domain/alternative_card.dart';
import '../../components/domain/meal_picker_card.dart';
import '../../components/domain/swap_target_card.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../async_gate.dart';
import '../screen_frame.dart';

enum _Filter { all, fits, adjust }

class CambiarScreen extends StatefulWidget {
  const CambiarScreen({super.key, required this.controllers});

  final AppControllers controllers;

  @override
  State<CambiarScreen> createState() => _CambiarScreenState();
}

class _CambiarScreenState extends State<CambiarScreen> {
  _Filter _filter = _Filter.all;

  AppControllers get c => widget.controllers;

  Future<void> _pick(
    DateTime date,
    Meal meal,
    EquivalentOption option,
    FitResult fit,
  ) async {
    final Plan? plan = c.plan.plan;
    final DayPlan? day = plan?.dayOn(date);
    final String nutri = c.profile.nutritionist?.name ?? '';
    String? movedFrom;
    if (fit.rebalance != null && day != null) {
      movedFrom = slotLabel(day.mealById(fit.rebalance!.fromMealId).slot);
    }
    final FitResult? result = await c.plan.applySwap(date, meal.id, option);
    if (result == null) {
      c.toast.show(S.actionFailed);
      return;
    }
    switch (result.fit) {
      case Fit.yes:
        c.toast.show(S.toastSwapYes);
        c.shell.finishSwap(date);
      case Fit.adjust:
        final Rebalance r = result.rebalance!;
        c.toast.show(
          S.toastSwapAdjust(
            formatPortion(r.amount),
            groupBudgetLabel(r.group).toLowerCase(),
            movedFrom ?? '',
          ),
        );
        c.shell.finishSwap(date);
      case Fit.no:
        final String extra = c.flags.swapApproval
            ? ' ${S.toastSwapNoApproval}'
            : '';
        c.toast.show('${S.toastSwapNo(nutri)}$extra');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ScreenFrame(
      controllers: c,
      eyebrow: S.cambiarEyebrow,
      title: S.cambiarTitle,
      children: <Widget>[
        ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            c.plan,
            c.shell,
            c.profile,
          ]),
          builder: (BuildContext context, Widget? _) {
            final Plan? plan = c.plan.plan;
            return AsyncGate(
              loading: c.plan.loading,
              hasError: c.plan.hasError && plan == null,
              empty: plan == null,
              onRetry: c.plan.retry,
              builder: (BuildContext context) {
                final SwapTarget? target = c.shell.pendingSwap;
                final DayPlan? day = target == null
                    ? null
                    : plan!.dayOn(target.date);
                Meal? meal;
                if (day != null) {
                  for (final Meal m in day.meals) {
                    if (m.id == target!.mealId && !m.done) meal = m;
                  }
                }
                if (meal == null) return _picker();
                return _alternatives(t, day!, meal);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _picker() {
    final DayPlan? today = c.plan.todayPlan;
    final List<Meal> open = today == null
        ? <Meal>[]
        : today.meals.where((Meal m) => !m.done).toList();
    return MealPickerCard(
      open: open,
      onPick: (Meal m) => c.shell.openSwap(today!.date, m.id),
    );
  }

  Widget _alternatives(AppTokens t, DayPlan day, Meal meal) {
    final List<MapEntry<EquivalentOption, FitResult>> all =
        <MapEntry<EquivalentOption, FitResult>>[
          for (final EquivalentOption o in c.plan.optionsFor(meal.slot))
            if (c.plan.fitFor(day.date, meal.id, o) != null)
              MapEntry<EquivalentOption, FitResult>(
                o,
                c.plan.fitFor(day.date, meal.id, o)!,
              ),
        ];
    final List<MapEntry<EquivalentOption, FitResult>> shown = all.where((e) {
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.fits:
          return e.value.fit == Fit.yes;
        case _Filter.adjust:
          return e.value.fit == Fit.adjust;
      }
    }).toList();
    return AppStack(
      gap: t.space.s3,
      children: <Widget>[
        SwapTargetCard(
          eyebrow: S.changingEyebrow(
            slotLabel(meal.slot),
            formatLongDate(day.date),
          ),
          dish: meal.dish,
          portions: meal.portions,
          onPickAnother: c.shell.clearSwap,
        ),
        SegmentedControl<_Filter>(
          fullWidth: true,
          value: _filter,
          onChanged: (_Filter f) => setState(() => _filter = f),
          options: const <SegmentOption<_Filter>>[
            SegmentOption<_Filter>(_Filter.all, S.filterAll),
            SegmentOption<_Filter>(_Filter.fits, S.filterFits),
            SegmentOption<_Filter>(_Filter.adjust, S.filterAdjust),
          ],
        ),
        const AppText(
          S.trafficCaption,
          variant: TextVariant.caption,
          tone: TextTone.muted,
        ),
        if (shown.isEmpty)
          const EmptyState(title: S.emptyFilterTitle, body: S.emptyFilterBody)
        else
          for (final MapEntry<EquivalentOption, FitResult> e in shown)
            AlternativeCard(
              dish: e.key.dish,
              portions: e.key.portions,
              fit: e.value.fit,
              onTap: () => _pick(day.date, meal, e.key, e.value),
            ),
      ],
    );
  }
}
