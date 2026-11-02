import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/services/portion_budget.dart';
import '../../../theme/food_color.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/eyebrow.dart';
import '../data_display/metric.dart';
import '../data_display/progress_bar.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';

/// Today's portions: percentage covered plus one bar per food group.
class PortionBudgetCard extends StatelessWidget {
  const PortionBudgetCard({super.key, required this.budget});

  final PortionBudget budget;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s4,
        children: <Widget>[
          const Eyebrow(S.budgetEyebrow),
          Metric(
            value: '${formatInt(budget.pctCovered)}%',
            unit: S.covered,
            size: MetricSize.lg,
          ),
          for (final BudgetRow r in budget.rows)
            ProgressBar(
              value: r.consumed,
              max: r.target,
              food: foodColor(t.colors, r.group),
              label: groupBudgetLabel(r.group),
              valueLabel: S.budgetRow(
                formatPortion(r.consumed),
                formatPortion(r.target),
              ),
            ),
        ],
      ),
    );
  }
}
