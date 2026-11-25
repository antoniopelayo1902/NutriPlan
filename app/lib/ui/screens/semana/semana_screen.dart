import 'package:flutter/widgets.dart';

import '../../../application/app_controllers.dart';
import '../../../core/clock.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../core/i18n/strings_flow_es_mx.dart';
import '../../../domain/models/plan.dart';
import '../../../domain/services/adherence.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/data_display/callout.dart';
import '../../components/data_display/day_picker.dart';
import '../../components/domain/day_summary.dart';
import '../../components/domain/meal_card.dart';
import '../../components/primitives/app_stack.dart';
import '../async_gate.dart';
import '../screen_frame.dart';

class SemanaScreen extends StatelessWidget {
  const SemanaScreen({super.key, required this.controllers});

  final AppControllers controllers;

  String _statusLabel(DayStatus s) {
    switch (s) {
      case DayStatus.complete:
        return S.dayComplete;
      case DayStatus.partial:
        return S.dayPartial;
      case DayStatus.pending:
        return S.dayPending;
    }
  }

  Future<void> _toggle(DateTime date, String mealId) async {
    await controllers.plan.toggleDone(date, mealId);
    if (controllers.plan.hasError) controllers.toast.show(S.actionFailed);
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ScreenFrame(
      controllers: controllers,
      eyebrow: S.semanaEyebrow,
      title: S.semanaTitle,
      children: <Widget>[
        ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            controllers.plan,
            controllers.shell,
            controllers.profile,
          ]),
          builder: (BuildContext context, Widget? _) {
            final Plan? plan = controllers.plan.plan;
            return AsyncGate(
              loading: controllers.plan.loading,
              hasError: controllers.plan.hasError && plan == null,
              empty: plan == null,
              // Sin nutriólogo no hay quien publique el plan: dice cómo vincularse.
              emptyTitle: controllers.profile.hasNutritionist
                  ? S.noPlanTitle
                  : S.noPlanNoNutritionistTitle,
              emptyBody: controllers.profile.hasNutritionist
                  ? S.noPlanBody
                  : S.noNutritionistCallout,
              onRetry: controllers.plan.retry,
              builder: (BuildContext context) {
                final Plan p = plan!;
                final DateTime today = controllers.plan.today;
                final DateTime selected =
                    controllers.shell.selectedDay ?? today;
                final DayPlan day = p.dayOn(selected) ?? p.days.first;
                final int selectedIndex = p.days.indexOf(day);
                return AppStack(
                  gap: t.space.s5,
                  children: <Widget>[
                    DayPicker(
                      selected: selectedIndex,
                      onSelect: (int i) =>
                          controllers.shell.selectDay(p.days[i].date),
                      days: <DayPickerDay>[
                        for (int i = 0; i < p.days.length; i++)
                          DayPickerDay(
                            label:
                                S.weekdayInitials[p.days[i].date.weekday - 1],
                            number: p.days[i].date.day,
                            status: dayStatus(p.days[i], today),
                            semanticLabel: S.dayLabel(
                              weekdayName(p.days[i].date.weekday),
                              p.days[i].date.day,
                              _statusLabel(dayStatus(p.days[i], today)),
                            ),
                          ),
                      ],
                    ),
                    AppStack(
                      gap: t.space.s3,
                      children: <Widget>[
                        DaySummary(
                          SFlow.daySummary(
                            formatLongDate(day.date),
                            day.meals.where((Meal m) => m.done).length,
                            day.meals.length,
                          ),
                        ),
                        for (final Meal m in day.meals)
                          MealCard(
                            slotLabel: slotLabel(m.slot),
                            time: formatTime(m.time),
                            dish: m.dish,
                            portions: m.portions,
                            done: m.done,
                            swapped: m.swapped,
                            onChange: m.done
                                ? null
                                : () => controllers.shell.openSwap(
                                    day.date,
                                    m.id,
                                  ),
                            onToggle: day.date.isAfter(today)
                                ? null
                                : () => _toggle(day.date, m.id),
                          ),
                      ],
                    ),
                    if (controllers.profile.hasNutritionist)
                      Callout(
                        S.planFooter(
                          controllers.profile.nutritionistName,
                          formatDayMonth(dateOnly(p.publishedAt)),
                          p.weeks,
                        ),
                        tone: CalloutTone.neutralDashed,
                      )
                    else
                      const Callout(
                        S.noNutritionistCallout,
                        key: Key('noNutritionistCallout'),
                        tone: CalloutTone.accentSoft,
                      ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
