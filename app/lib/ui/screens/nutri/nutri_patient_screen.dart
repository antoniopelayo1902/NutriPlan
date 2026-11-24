import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/nutri_controller.dart';
import '../../../application/nutri_plan_controller.dart';
import '../../../application/progress_controller.dart';
import '../../../application/toast_controller.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/firestore/firestore_measurement_repository.dart';
import '../../../data/nutritionist_service.dart';
import '../../../data/plan_menu_service.dart';
import '../../../domain/models/food_group.dart';
import '../../../domain/models/measurement.dart';
import '../../../domain/models/patient_summary.dart';
import '../../../domain/models/portions.dart';
import '../../../domain/services/measurement_trend.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/confirm_dialog.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/domain/body_composition_card.dart';
import '../../components/domain/measurement_history_card.dart';
import '../../components/primitives/app_stack.dart';
import '../page_frame.dart';
import 'measurement_form_screen.dart';
import 'nutri_measurements_panel.dart';
import 'nutri_panel_loading.dart';
import 'nutri_patient_header.dart';
import 'nutri_plan_panel.dart';
import 'nutri_portions_panel.dart';

enum _Tab { measures, history, plan, portions }

/// Detalle de un paciente para el nutriólogo: sus medidas (CRUD), su
/// historial, el plan de comidas que le arma y las porciones.
class NutriPatientScreen extends StatefulWidget {
  const NutriPatientScreen({
    super.key,
    required this.patient,
    this.embedded = false,
    this.onUnlinked,
  });

  final PatientSummary patient;

  /// True inside the web two-pane layout: no back button, and unlinking
  /// calls [onUnlinked] instead of popping the route.
  final bool embedded;
  final VoidCallback? onUnlinked;

  @override
  State<NutriPatientScreen> createState() => _NutriPatientScreenState();
}

class _NutriPatientScreenState extends State<NutriPatientScreen> {
  late final FirestoreMeasurementRepository _repo;
  late final ProgressController _progress;
  late final NutriPlanController _plan;
  _Tab _tab = _Tab.measures;
  MeasurementMetric _metric = MeasurementMetric.weight;

  Portions? _targets;
  Portions _minimums = Portions.zero;
  bool _targetsLoading = true;
  bool _publishing = false;

  String get _uid => widget.patient.uid;

  @override
  void initState() {
    super.initState();
    _repo = FirestoreMeasurementRepository(uid: _uid);
    // Reusa el controller de Progreso, pero con los datos de este paciente.
    _progress = ProgressController(_repo)..load();
    _plan = NutriPlanController(
      loadCatalog: PlanMenuService.loadCatalog,
      loadMenu: () => PlanMenuService.loadMenu(_uid),
      publish: (menu) => PlanMenuService.publish(
        patientUid: _uid,
        nutriUid: context.read<NutriController>().uid,
        menu: menu,
      ),
    )..load();
    _loadTargets();
  }

  @override
  void dispose() {
    _progress.dispose();
    _plan.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    try {
      final Portions? targets = await NutritionistService.loadTargets(_uid);
      final Portions minimums = await NutritionistService.loadMinimums(_uid);
      if (mounted) {
        setState(() {
          _targets = targets;
          _minimums = minimums;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _targets = null);
    } finally {
      if (mounted) setState(() => _targetsLoading = false);
    }
  }

  /// Swipe down: vuelve a leer medidas y porciones de Firestore.
  Future<void> _refresh() async {
    await Future.wait(<Future<void>>[
      _progress.refresh(),
      _loadTargets(),
      _plan.load(),
    ]);
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

  /// Sube o baja media porción de un grupo (entre el mínimo y 20).
  void _step(FoodGroup g, double delta) {
    final Portions current = _targets!;
    final double next = (current[g] + delta).clamp(
      _minimums[g],
      Portions.maxPerGroup,
    );
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

  /// Publica el menú; las porciones se vuelven a leer porque pueden subir.
  Future<void> _publishMenu() async {
    final ToastController toast = context.read<ToastController>();
    final bool ok = await _plan.publish();
    toast.show(ok ? S.menuPublished : S.actionFailed);
    if (ok) await _loadTargets();
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
    if (!ok || !mounted) return;
    if (widget.embedded) {
      widget.onUnlinked?.call();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final bool wide = widget.embedded;
    final Widget tabs = SegmentedControl<_Tab>(
      fullWidth: !wide,
      value: _tab,
      // setState redibuja la pestaña elegida.
      onChanged: (_Tab v) => setState(() => _tab = v),
      options: const <SegmentOption<_Tab>>[
        SegmentOption<_Tab>(_Tab.measures, S.tabMeasures),
        SegmentOption<_Tab>(_Tab.history, S.tabHistory),
        SegmentOption<_Tab>(_Tab.plan, S.tabPlan),
        SegmentOption<_Tab>(_Tab.portions, S.tabPortions),
      ],
    );
    final Widget unlink = AppButton(
      key: const Key('unlinkButton'),
      label: S.unlinkPatient,
      variant: ButtonVariant.ghost,
      fullWidth: !wide,
      onPressed: _unlink,
    );
    return PageFrame(
      eyebrow: S.patientEyebrow,
      title: widget.patient.name,
      showBack: !wide,
      wide: wide,
      onRefresh: _refresh,
      header: wide
          ? ListenableBuilder(
              listenable: _progress,
              builder: (BuildContext context, Widget? _) => NutriPatientHeader(
                patient: widget.patient,
                latest: _progress.latest,
                dailyKcal: _targets?.kcal,
              ),
            )
          : null,
      children: <Widget>[
        wide ? Align(alignment: Alignment.centerLeft, child: tabs) : tabs,
        ListenableBuilder(
          listenable: _progress,
          builder: (BuildContext context, Widget? _) {
            switch (_tab) {
              case _Tab.measures:
                return _measures();
              case _Tab.history:
                return _history(t);
              case _Tab.plan:
                return NutriPlanPanel(
                  controller: _plan,
                  wide: widget.embedded,
                  onPublish: _publishMenu,
                );
              case _Tab.portions:
                return _portions();
            }
          },
        ),
        wide ? Align(alignment: Alignment.centerLeft, child: unlink) : unlink,
      ],
    );
  }

  Widget _measures() {
    if (_progress.loading) return const NutriPanelLoading();
    return NutriMeasurementsPanel(
      measurements: _progress.measurements.reversed.toList(),
      wide: widget.embedded,
      onAdd: _openForm,
      onEdit: _openForm,
      onDelete: _delete,
    );
  }

  Widget _history(AppTokens t) {
    if (_progress.loading) return const NutriPanelLoading();
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
    final Widget chart = MeasurementHistoryCard(
      metric: trend.metric,
      trend: trend,
      onMetricChanged: (MeasurementMetric m) => setState(() => _metric = m),
    );
    final Widget body = BodyCompositionCard(
      measurement: _progress.latest!,
      nutritionistName: nutri,
    );
    return AppStack(
      direction: widget.embedded ? Axis.horizontal : Axis.vertical,
      gap: widget.embedded ? t.space.s5 : t.space.s3,
      align: CrossAxisAlignment.start,
      children: <Widget>[
        widget.embedded ? Expanded(flex: 3, child: chart) : chart,
        widget.embedded ? Expanded(flex: 2, child: body) : body,
      ],
    );
  }

  Widget _portions() {
    if (_targetsLoading) return const NutriPanelLoading();
    final Portions? targets = _targets;
    if (targets == null) {
      return const EmptyState(title: S.noPatientPlan);
    }
    return NutriPortionsPanel(
      targets: targets,
      minimums: _minimums,
      publishing: _publishing,
      wide: widget.embedded,
      onStep: _step,
      onPublish: _publish,
    );
  }
}
