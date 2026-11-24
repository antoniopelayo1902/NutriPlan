import 'package:flutter/widgets.dart';

import '../../../application/nutri_plan_controller.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/equivalent_option.dart';
import '../../../domain/models/plan.dart';
import '../../../domain/models/week_menu.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_chip.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/callout.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/domain/portion_tags.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_grid.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import 'nutri_panel_loading.dart';

/// Pestaña "Plan": el nutriólogo arma el menú de la semana con platillos
/// del catálogo y lo publica.
class NutriPlanPanel extends StatelessWidget {
  const NutriPlanPanel({
    super.key,
    required this.controller,
    required this.onPublish,
    this.wide = false,
  });

  final NutriPlanController controller;
  final VoidCallback onPublish;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        final NutriPlanController c = controller;
        if (c.loading) return const NutriPanelLoading();
        if (c.hasError) {
          return EmptyState(
            title: S.planEditorError,
            action: AppButton(label: S.retry, onPressed: c.load),
          );
        }
        if (c.catalogEmpty) {
          return const EmptyState(
            title: S.catalogEmptyTitle,
            body: S.catalogEmptyBody,
          );
        }
        final WeekMenu menu = c.menu;
        final Widget publish = AppButton(
          key: const Key('publishMenuButton'),
          label: S.publishMenu,
          fullWidth: !wide,
          loading: c.publishing,
          onPressed: menu.complete && !c.publishing ? onPublish : null,
        );
        return AppStack(
          gap: t.space.s3,
          children: <Widget>[
            const AppText(
              S.planEditorBody,
              variant: TextVariant.bodySm,
              tone: TextTone.secondary,
            ),
            SegmentedControl<int>(
              fullWidth: !wide,
              value: c.day,
              onChanged: c.selectDay,
              options: <SegmentOption<int>>[
                for (int d = 0; d < WeekMenu.days; d++)
                  SegmentOption<int>(d, S.weekdayInitials[d]),
              ],
            ),
            AppGrid(
              columns: wide ? 2 : 1,
              gap: t.space.s3,
              children: <Widget>[
                for (final MealSlot slot in MealSlot.values)
                  _slotCard(t, c, slot),
              ],
            ),
            AppButton(
              key: const Key('copyDayButton'),
              label: S.copyDayToWeek,
              variant: ButtonVariant.outlineNeutral,
              fullWidth: !wide,
              onPressed: c.copyDayToWeek,
            ),
            Callout(
              menu.complete ? S.menuComplete : S.menuMissing(menu.missing),
              tone: menu.complete ? CalloutTone.success : CalloutTone.message,
            ),
            wide
                ? Align(alignment: Alignment.centerRight, child: publish)
                : publish,
          ],
        );
      },
    );
  }

  Widget _slotCard(AppTokens t, NutriPlanController c, MealSlot slot) {
    final EquivalentOption? chosen = c.menu.pick(c.day, slot);
    return AppCard(
      key: Key('menuSlot-${slot.name}'),
      child: AppStack(
        gap: t.space.s2,
        children: <Widget>[
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s2,
            children: <Widget>[
              Eyebrow(slotLabel(slot)),
              AppText(
                formatTime(mealTimes[slot]!),
                variant: TextVariant.caption,
                tone: TextTone.muted,
              ),
            ],
          ),
          AppText(
            chosen?.dish ?? S.pickDish,
            variant: TextVariant.bodyLg,
            tone: chosen == null ? TextTone.muted : TextTone.primary,
          ),
          if (chosen != null) PortionTags(chosen.portions),
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s2,
            wrap: true,
            children: <Widget>[
              for (final EquivalentOption o in c.catalogFor(slot))
                AppChip(
                  key: Key('dish-${o.id}'),
                  label: o.dish,
                  size: ChipSize.sm,
                  selected: chosen?.id == o.id,
                  onPressed: () => c.pick(o),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
