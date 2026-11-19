import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/measurement.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_icon_button.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/data_display/list_item.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_divider.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';

/// "Medidas" tab: add button plus the editable list, newest first.
class NutriMeasurementsPanel extends StatelessWidget {
  const NutriMeasurementsPanel({
    super.key,
    required this.measurements,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.wide = false,
  });

  final List<Measurement> measurements;
  final VoidCallback onAdd;
  final ValueChanged<Measurement> onEdit;
  final ValueChanged<Measurement> onDelete;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final Widget add = AppButton(
      key: const Key('addMeasurementButton'),
      label: S.addMeasurement,
      iconLeft: AppIconName.add,
      variant: ButtonVariant.outlineAccent,
      fullWidth: !wide,
      onPressed: onAdd,
    );
    return AppStack(
      gap: t.space.s3,
      children: <Widget>[
        wide ? Align(alignment: Alignment.centerLeft, child: add) : add,
        if (measurements.isEmpty)
          const EmptyState(
            title: S.noMeasurementsTitle,
            body: S.noMeasurementsBody,
          )
        else
          AppCard(
            padding: t.space.s5,
            child: AppStack(
              gap: t.space.s2,
              children: <Widget>[
                for (int i = 0; i < measurements.length; i++) ...<Widget>[
                  if (i > 0) const AppDivider(),
                  _row(t, measurements[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _row(AppTokens t, Measurement m) {
    final double bmi = m.weightKg / (m.heightM * m.heightM);
    return ListItem(
      key: Key('measurement-${m.id}'),
      title: S.fullDate(formatDayMonth(m.date), m.date.year),
      subtitle:
          '${S.measurementSummary(formatWithUnit(formatDecimal(m.weightKg), S.unitKg), formatWithUnit(formatDecimal(m.bodyFatPct), S.unitPct), formatWithUnit(formatDecimal(m.muscleKg), S.unitKg))}'
          ' · ${S.bmiLabel(formatDecimal(bmi))}',
      trailing: AppStack(
        direction: Axis.horizontal,
        gap: t.space.s1,
        children: <Widget>[
          AppIconButton(
            key: Key('editMeasurement-${m.id}'),
            icon: AppIconName.edit,
            size: IconButtonSize.sm,
            semanticLabel: S.editMeasurement,
            onPressed: () => onEdit(m),
          ),
          AppIconButton(
            key: Key('deleteMeasurement-${m.id}'),
            icon: AppIconName.delete,
            size: IconButtonSize.sm,
            semanticLabel: S.deleteMeasurement,
            onPressed: () => onDelete(m),
          ),
        ],
      ),
    );
  }
}
