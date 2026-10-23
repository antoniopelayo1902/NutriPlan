import 'package:flutter/widgets.dart';

import '../../../application/app_controllers.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/plan.dart';
import '../../../domain/services/portion_budget.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/data_display/callout.dart';
import '../../components/domain/next_meal_card.dart';
import '../../components/domain/portion_budget_card.dart';
import '../../components/primitives/app_stack.dart';
import '../async_gate.dart';
import '../screen_frame.dart';

class HoyScreen extends StatelessWidget {
  const HoyScreen({super.key, required this.controllers});

  final AppControllers controllers;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ListenableBuilder(
      listenable: controllers.plan,
      builder: (BuildContext context, Widget? _) {
        final DateTime today = controllers.plan.today;
        final DayPlan? day = controllers.plan.todayPlan;
        final PortionBudget? budget = controllers.plan.budget;
        return ScreenFrame(
          controllers: controllers,
          eyebrow: formatLongDate(today),
          title: S.hoyTitle,
          children: <Widget>[
            AsyncGate(
              loading: controllers.plan.loading,
              hasError:
                  controllers.plan.hasError && controllers.plan.plan == null,
              empty: day == null || budget == null,
              onRetry: controllers.plan.retry,
              builder: (BuildContext context) {
                final Meal? next = _firstPending(day!);
                return AppStack(
                  gap: t.space.s3,
                  children: <Widget>[
                    PortionBudgetCard(budget: budget!),
                    if (next != null)
                      NextMealCard(
                        eyebrow: S.nextMealEyebrow(
                          slotLabel(next.slot),
                          formatTime(next.time),
                        ),
                        dish: next.dish,
                        portions: next.portions,
                        onCrave: () =>
                            controllers.shell.openSwap(day.date, next.id),
                      )
                    else
                      const Callout(S.allMealsDone, tone: CalloutTone.success),
                    Callout(S.swapsCallout(controllers.plan.swaps)),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Meal? _firstPending(DayPlan day) {
    for (final Meal m in day.meals) {
      if (!m.done) return m;
    }
    return null;
  }
}
