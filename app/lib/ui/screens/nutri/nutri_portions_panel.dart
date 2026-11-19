import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/food_group.dart';
import '../../../domain/models/portions.dart';
import '../../../theme/food_color.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_icon_button.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/list_item.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_divider.dart';
import '../../components/primitives/app_grid.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';

/// "Porciones" tab: daily portions per group with steppers and publish.
class NutriPortionsPanel extends StatelessWidget {
  const NutriPortionsPanel({
    super.key,
    required this.targets,
    required this.minimums,
    required this.publishing,
    required this.onStep,
    required this.onPublish,
    this.wide = false,
  });

  final Portions targets;
  final Portions minimums;
  final bool publishing;
  final void Function(FoodGroup group, double delta) onStep;
  final VoidCallback onPublish;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final Widget publish = AppButton(
      key: const Key('publishPlanButton'),
      label: S.publishPlan,
      fullWidth: !wide,
      loading: publishing,
      onPressed: publishing ? null : onPublish,
    );
    return AppStack(
      gap: t.space.s3,
      children: <Widget>[
        AppCard(
          padding: t.space.s5,
          child: AppStack(
            gap: t.space.s2,
            children: <Widget>[
              const Eyebrow(S.tabPortions),
              const AppText(
                S.portionsBody,
                variant: TextVariant.bodySm,
                tone: TextTone.secondary,
              ),
              AppGrid(
                columns: wide ? 2 : 1,
                gap: wide ? t.space.s7 : t.space.s0,
                children: <Widget>[
                  for (final FoodGroup g in FoodGroup.values) _row(t, g),
                ],
              ),
              const AppDivider(),
              AppText(
                S.portionsKcal(formatInt(targets.kcal.round())),
                key: const Key('portionsKcal'),
                variant: TextVariant.titleMd,
              ),
            ],
          ),
        ),
        wide
            ? Align(alignment: Alignment.centerRight, child: publish)
            : publish,
      ],
    );
  }

  Widget _row(AppTokens t, FoodGroup g) {
    final String label = groupBudgetLabel(g);
    final double value = targets[g];
    return ListItem(
      leading: SizedBox(
        width: t.size.dotLg,
        height: t.size.dotLg,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: foodColor(t.colors, g).solid,
            shape: BoxShape.circle,
          ),
        ),
      ),
      title: label,
      subtitle: minimums[g] > 0
          ? S.portionMinimum(formatPortion(minimums[g]))
          : null,
      trailing: AppStack(
        direction: Axis.horizontal,
        gap: t.space.s2,
        children: <Widget>[
          AppIconButton(
            key: Key('minus-${g.name}'),
            icon: AppIconName.remove,
            size: IconButtonSize.sm,
            variant: IconButtonVariant.outline,
            semanticLabel: S.decrease(label),
            onPressed: value <= minimums[g] ? null : () => onStep(g, -0.5),
          ),
          SizedBox(
            width: t.space.s7,
            child: AppText(
              formatPortion(value),
              key: Key('portion-${g.name}'),
              variant: TextVariant.label,
              textAlign: TextAlign.center,
            ),
          ),
          AppIconButton(
            key: Key('plus-${g.name}'),
            icon: AppIconName.add,
            size: IconButtonSize.sm,
            variant: IconButtonVariant.outline,
            semanticLabel: S.increase(label),
            onPressed: value >= Portions.maxPerGroup
                ? null
                : () => onStep(g, 0.5),
          ),
        ],
      ),
    );
  }
}
