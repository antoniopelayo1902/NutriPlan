import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/nutri_controller.dart';
import '../../../application/progress_controller.dart';
import '../../../application/toast_controller.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/firestore/firestore_measurement_repository.dart';
import '../../../data/nutritionist_service.dart';
import '../../../domain/models/food_group.dart';
import '../../../domain/models/measurement.dart';
import '../../../domain/models/patient_summary.dart';
import '../../../domain/models/portions.dart';
import '../../../domain/services/measurement_trend.dart';
import '../../../theme/food_color.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_icon_button.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/confirm_dialog.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/list_item.dart';
import '../../components/domain/body_composition_card.dart';
import '../../components/domain/measurement_history_card.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_divider.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../../components/primitives/skeleton.dart';
import '../page_frame.dart';
import 'measurement_form_screen.dart';

enum _Tab { measures, history, portions }

/// Detalle de un paciente para la nutrióloga: sus medidas (CRUD), su
/// historial y las porciones de su plan.
class NutriPatientScreen extends StatefulWidget {
  const NutriPatientScreen({super.key, required this.patient});

  final PatientSummary patient;

  @override
  State<NutriPatientScreen> createState() => _NutriPatientScreenState();
}

class _NutriPatientScreenState extends State<NutriPatientScreen> {
  late final FirestoreMeasurementRepository _repo;
  late final ProgressController _progress;
  _Tab _tab = _Tab.measures;
  MeasurementMetric _metric = MeasurementMetric.weight;

  Portions? _targets;
  bool _targetsLoading = true;
  bool _publishing = false;

  String get _uid => widget.patient.uid;

  @override
  void initState() {
    super.initState();
    _repo = FirestoreMeasurementRepository(uid: _uid);
    // Reusa el controller de Progreso, pero con los datos de este paciente.
    _progress = ProgressController(_repo)..load();
    _loadTargets();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    try {
      final Portions? targets = await NutritionistService.loadTargets(_uid);
      if (mounted) setState(() => _targets = targets);
    } catch (_) {
      if (mounted) setState(() => _targets = null);
    } finally {
      if (mounted) setState(() => _targetsLoading = false);
    }
  }

  /// Swipe down: vuelve a leer medidas y porciones de Firestore.
  Future<void> _refresh() async {
    await Future.wait(<Future<void>>[_progress.refresh(), _loadTargets()]);
  }

  /// Abre el formulario: vacío para crear, con datos para editar.
  Future<void> _openForm([Measurement? m]) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext _) =>
            MeasurementFormScreen(repository: _repo, measurement: m),
      ),
    );
    await _progress.refresh();
  }

  /// Delete con alerta de confirmación.
  Future<void> _delete(Measurement m) async {
    final ToastController toast = context.read<ToastController>();
    final bool sure = await showConfirmDialog(
      context,
      title: S.deleteMeasurementTitle(formatDayMonth(m.date)),
      body: S.deleteMeasurementBody,
      confirmLabel: S.delete,
    );
    if (!sure) return;
    try {
      await _repo.remove(m.id);
      await _progress.refresh();
      toast.show(S.measurementDeleted);
    } catch (_) {
      toast.show(S.actionFailed);
    }
  }

  /// Sube o baja media porción de un grupo (entre 0 y 20).
  void _step(FoodGroup g, double delta) {
    final Portions current = _targets!;
    final double next = (current[g] + delta).clamp(0, Portions.maxPerGroup);
    setState(() => _targets = current.withGroup(g, next));
  }

  Future<void> _publish() async {
    final ToastController toast = context.read<ToastController>();
    final String nutriUid = context.read<NutriController>().uid;
    setState(() => _publishing = true);
    try {
      await NutritionistService.publishTargets(
        patientUid: _uid,
        nutriUid: nutriUid,
        targets: _targets!,
      );
      toast.show(S.planPublished);
    } catch (_) {
      toast.show(S.actionFailed);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _unlink() async {
    final NutriController nutri = context.read<NutriController>();
    final ToastController toast = context.read<ToastController>();
    final bool sure = await showConfirmDialog(
      context,
      title: S.unlinkTitle(widget.patient.name),
      body: S.unlinkBody,
      confirmLabel: S.unlinkAction,
    );
    if (!sure) return;
    final bool ok = await nutri.unlink(_uid);
    toast.show(ok ? S.patientUnlinked : S.actionFailed);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return PageFrame(
      eyebrow: S.patientEyebrow,
      title: widget.patient.name,
      onRefresh: _refresh,
      children: <Widget>[
        SegmentedControl<_Tab>(
          fullWidth: true,
          value: _tab,
          // setState redibuja la pestaña elegida.
          onChanged: (_Tab v) => setState(() => _tab = v),
          options: const <SegmentOption<_Tab>>[
            SegmentOption<_Tab>(_Tab.measures, S.tabMeasures),
            SegmentOption<_Tab>(_Tab.history, S.tabHistory),
            SegmentOption<_Tab>(_Tab.portions, S.tabPortions),
          ],
        ),
        ListenableBuilder(
          listenable: _progress,
          builder: (BuildContext context, Widget? _) {
            switch (_tab) {
              case _Tab.measures:
                return _measures(t);
              case _Tab.history:
                return _history(t);
              case _Tab.portions:
                return _portions(t);
            }
          },
        ),
        AppButton(
          key: const Key('unlinkButton'),
          label: S.unlinkPatient,
          variant: ButtonVariant.ghost,
          fullWidth: true,
          onPressed: _unlink,
        ),
      ],
    );
  }

  Widget _loading(AppTokens t) => AppStack(
    gap: t.space.s3,
    children: <Widget>[
      for (int i = 0; i < 2; i++)
        Skeleton(height: t.size.skeletonCard, radius: t.radius.xl),
    ],
  );

  Widget _measures(AppTokens t) {
    if (_progress.loading) return _loading(t);
    final List<Measurement> all = _progress.measurements.reversed.toList();
    return AppStack(
      gap: t.space.s3,
      children: <Widget>[
        AppButton(
          key: const Key('addMeasurementButton'),
          label: S.addMeasurement,
          iconLeft: AppIconName.add,
          variant: ButtonVariant.outlineAccent,
          fullWidth: true,
          onPressed: () => _openForm(),
        ),
        if (all.isEmpty)
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
                for (int i = 0; i < all.length; i++) ...<Widget>[
                  if (i > 0) const AppDivider(),
                  _measurementRow(t, all[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _measurementRow(AppTokens t, Measurement m) {
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
            onPressed: () => _openForm(m),
          ),
          AppIconButton(
            key: Key('deleteMeasurement-${m.id}'),
            icon: AppIconName.delete,
            size: IconButtonSize.sm,
            semanticLabel: S.deleteMeasurement,
            onPressed: () => _delete(m),
          ),
        ],
      ),
    );
  }

  Widget _history(AppTokens t) {
    if (_progress.loading) return _loading(t);
    final MetricTrend? trend =
        _progress.trend(_metric) ?? _progress.trend(MeasurementMetric.weight);
    if (trend == null || _progress.latest == null) {
      return const EmptyState(
        title: S.noMeasurementsTitle,
        body: S.noMeasurementsBody,
      );
    }
    final String nutri =
        context.read<NutriController>().displayName ?? S.roleNutritionist;
    return AppStack(
      gap: t.space.s3,
      children: <Widget>[
        MeasurementHistoryCard(
          metric: trend.metric,
          trend: trend,
          onMetricChanged: (MeasurementMetric m) => setState(() => _metric = m),
        ),
        BodyCompositionCard(
          measurement: _progress.latest!,
          nutritionistName: nutri,
        ),
      ],
    );
  }

  Widget _portions(AppTokens t) {
    if (_targetsLoading) return _loading(t);
    final Portions? targets = _targets;
    if (targets == null) {
      return const EmptyState(title: S.noPatientPlan);
    }
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
              for (final FoodGroup g in FoodGroup.values)
                _portionRow(t, g, targets[g]),
              const AppDivider(),
              AppText(
                S.portionsKcal(formatInt(targets.kcal.round())),
                key: const Key('portionsKcal'),
                variant: TextVariant.titleMd,
              ),
            ],
          ),
        ),
        AppButton(
          key: const Key('publishPlanButton'),
          label: S.publishPlan,
          fullWidth: true,
          loading: _publishing,
          onPressed: _publishing ? null : _publish,
        ),
      ],
    );
  }

  Widget _portionRow(AppTokens t, FoodGroup g, double value) {
    final String label = groupBudgetLabel(g);
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
      trailing: AppStack(
        direction: Axis.horizontal,
        gap: t.space.s2,
        align: CrossAxisAlignment.center,
        children: <Widget>[
          AppIconButton(
            key: Key('minus-${g.name}'),
            icon: AppIconName.remove,
            size: IconButtonSize.sm,
            variant: IconButtonVariant.outline,
            semanticLabel: S.decrease(label),
            onPressed: value <= 0 ? null : () => _step(g, -0.5),
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
                : () => _step(g, 0.5),
          ),
        ],
      ),
    );
  }
}
