import 'package:flutter/widgets.dart';

import '../../../application/app_controllers.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/measurement.dart';
import '../../../domain/models/plan.dart';
import '../../../domain/services/adherence.dart';
import '../../../domain/services/measurement_trend.dart';
import '../../../domain/services/progress.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/bar_chart.dart';
import '../../components/data_display/callout.dart';
import '../../components/data_display/metric.dart';
import '../../components/domain/body_composition_card.dart';
import '../../components/domain/measurement_history_card.dart';
import '../../components/domain/monthly_measurements_card.dart';
import '../../components/domain/streak_card.dart';
import '../../components/domain/weekly_adherence_card.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_grid.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../../components/actions/app_button.dart';
import '../async_gate.dart';
import '../login/auth_gate.dart';
import '../screen_frame.dart';

enum _View { week, month }

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key, required this.controllers});

  final AppControllers controllers;

  @override
  State<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  _View _view = _View.week;
  MeasurementMetric _metric = MeasurementMetric.weight;

  AppControllers get c => widget.controllers;

  String _achievementLabel(Achievement a) {
    switch (a) {
      case Achievement.streak3:
        return S.achievementStreak3;
      case Achievement.variety5:
        return S.achievementVariety5;
      case Achievement.firstSwap:
        return S.achievementFirstSwap;
      case Achievement.adherence80:
        return S.achievementAdherence80;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ScreenFrame(
      controllers: c,
      eyebrow: S.progresoEyebrow,
      title: S.progresoTitle,
      children: <Widget>[
        SegmentedControl<_View>(
          fullWidth: true,
          value: _view,
          onChanged: (_View v) => setState(() => _view = v),
          options: const <SegmentOption<_View>>[
            SegmentOption<_View>(_View.week, S.segmentWeek),
            SegmentOption<_View>(_View.month, S.segmentMonth),
          ],
        ),
        ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            c.plan,
            c.progress,
            c.profile,
          ]),
          builder: (BuildContext context, Widget? _) =>
              _view == _View.week ? _week(t) : _month(t),
        ),
        ?_signOut(context, t),
      ],
    );
  }

  /// Only when the app runs behind the Firebase login.
  Widget? _signOut(BuildContext context, AppTokens t) {
    final AuthScope? auth = AuthScope.maybeOf(context);
    if (auth == null) return null;
    return AppStack(
      gap: t.space.s2,
      children: <Widget>[
        AppText(
          S.signedInAs(auth.email),
          variant: TextVariant.caption,
          tone: TextTone.muted,
          textAlign: TextAlign.center,
        ),
        AppButton(
          key: const Key('signOutButton'),
          label: S.signOut,
          variant: ButtonVariant.outlineNeutral,
          fullWidth: true,
          onPressed: auth.signOut,
        ),
      ],
    );
  }

  Widget _week(AppTokens t) {
    final Plan? plan = c.plan.plan;
    return AsyncGate(
      loading: c.plan.loading,
      hasError: c.plan.hasError && plan == null,
      empty: plan == null,
      onRetry: c.plan.retry,
      skeletons: 2,
      builder: (BuildContext context) {
        final Plan p = plan!;
        final DateTime today = c.plan.today;
        final int delta = c.plan.adherenceDeltaPts;
        final MetricTrend? weight = c.progress.trend(MeasurementMetric.weight);
        final String nutri = c.profile.nutritionist?.name ?? '';
        return AppStack(
          gap: t.space.s3,
          children: <Widget>[
            WeeklyAdherenceCard(
              pctLabel: '${formatInt(c.plan.weekAdherencePct)}%',
              deltaLabel: S.adherenceDelta(formatSignedInt(delta)),
              deltaTone: delta >= 0 ? TextTone.success : TextTone.warning,
              days: <BarDatum>[
                for (final DayPlan d in p.days)
                  BarDatum(
                    label: S.weekdayInitials[d.date.weekday - 1],
                    value: dayAdherencePct(d).toDouble(),
                    valueLabel: '${dayAdherencePct(d)}%',
                    state: dayAdherencePct(d) == 0
                        ? BarState.empty
                        : (d.date == today ? BarState.current : BarState.past),
                  ),
              ],
            ),
            AppGrid(
              columns: 2,
              gap: t.space.s3,
              children: <Widget>[
                AppCard(
                  child: Metric(
                    label: S.varietyLabel,
                    value: '${c.plan.variety}',
                    size: MetricSize.md,
                    caption: S.varietyCaption,
                  ),
                ),
                AppCard(
                  child: Metric(
                    label: S.weightChangeLabel,
                    value: weight == null
                        ? S.noValue
                        : formatSigned(weight.delta),
                    unit: weight == null ? null : S.unitKg,
                    size: MetricSize.md,
                    caption: S.weightChangeCaption(nutri),
                  ),
                ),
              ],
            ),
            if (c.flags.motivational)
              StreakCard(
                days: c.plan.streak,
                badges: <String>[
                  for (final Achievement a in c.plan.earned)
                    _achievementLabel(a),
                ],
              ),
            const Callout(S.progressCallout, tone: CalloutTone.accentSoft),
          ],
        );
      },
    );
  }

  Widget _month(AppTokens t) {
    final List<Measurement> all = c.progress.measurements;
    return AsyncGate(
      loading: c.progress.loading,
      hasError: c.progress.hasError && all.isEmpty,
      empty: all.isEmpty,
      emptyTitle: S.noMeasurementsTitle,
      emptyBody: S.noMeasurementsBody,
      skeletons: 2,
      onRetry: c.progress.retry,
      builder: (BuildContext context) {
        final MetricTrend trend =
            c.progress.trend(_metric) ??
            c.progress.trend(MeasurementMetric.weight)!;
        final String nutri = c.profile.nutritionist?.name ?? '';
        final MetricTrend? weight = c.progress.trend(MeasurementMetric.weight);
        final MetricTrend? fat = c.progress.trend(MeasurementMetric.bodyFat);
        final MetricTrend? waist = c.progress.trend(MeasurementMetric.waist);
        final String summary = (weight == null || fat == null || waist == null)
            ? S.monthSummaryFlat
            : S.monthSummary(
                monthName(weight.dates.first.month),
                formatWithUnit(formatSigned(weight.delta), S.unitKg),
                formatWithUnit(formatSigned(fat.delta), S.unitPct),
                formatWithUnit(formatSigned(waist.delta), S.unitCm),
              );
        return AppStack(
          gap: t.space.s3,
          children: <Widget>[
            MeasurementHistoryCard(
              metric: _metric,
              trend: trend,
              onMetricChanged: (MeasurementMetric m) =>
                  setState(() => _metric = m),
            ),
            BodyCompositionCard(measurement: all.last, nutritionistName: nutri),
            MonthlyMeasurementsCard(measurements: all.reversed.toList()),
            Callout(summary, tone: CalloutTone.success),
          ],
        );
      },
    );
  }
}
