import 'package:flutter/material.dart';

import '../../../application/app_controllers.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/activity.dart';
import '../../../domain/services/activity_summary.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_icon_button.dart';
import '../../components/data_display/callout.dart';
import '../../components/data_display/confirm_dialog.dart';
import '../../components/data_display/empty_state.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/list_item.dart';
import '../../components/domain/activity_summary_card.dart';
import '../../components/domain/quick_log_grid.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_divider.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../async_gate.dart';
import '../screen_frame.dart';
import 'activity_form_screen.dart';

class MovimientoScreen extends StatelessWidget {
  const MovimientoScreen({super.key, required this.controllers});

  final AppControllers controllers;

  Color _kindColor(SemanticColors c, ActivityKind k) {
    switch (k) {
      case ActivityKind.caminata:
        return c.dayComplete;
      case ActivityKind.fuerza:
        return c.accent;
      case ActivityKind.bici:
        return c.dayPartial;
      case ActivityKind.yoga:
        return c.infoFg;
    }
  }

  Future<void> _log(ActivityType type) async {
    final ActivityLog? log = await controllers.activity.quickLog(type);
    controllers.toast.show(
      log == null
          ? S.actionFailed
          : S.toastLogged(S.activityNames[type.kind.name]!, log.minutes),
    );
  }

  /// Delete del CRUD: primero una alerta para confirmar.
  Future<void> _remove(BuildContext context, ActivityLog log) async {
    final bool sure = await showConfirmDialog(
      context,
      title: S.deleteSessionTitle,
      body: S.deleteSessionBody(
        S.activityNames[log.kind.name]!.toLowerCase(),
        log.minutes,
      ),
      confirmLabel: S.delete,
    );
    if (!sure) return;
    final bool ok = await controllers.activity.remove(log.id);
    controllers.toast.show(ok ? S.toastLogRemoved : S.actionFailed);
  }

  /// Abre el formulario: vacío para crear, con datos para editar.
  void _openForm(BuildContext context, [ActivityLog? log]) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext _) => ActivityFormScreen(log: log),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ScreenFrame(
      controllers: controllers,
      eyebrow: S.movimientoEyebrow,
      title: S.movimientoTitle,
      children: <Widget>[
        ListenableBuilder(
          listenable: Listenable.merge(<Listenable>[
            controllers.activity,
            controllers.profile,
          ]),
          builder: (BuildContext context, Widget? _) {
            final ActivitySummary? summary = controllers.activity.summary;
            final ActivityGoal? goal = controllers.activity.goal;
            return AsyncGate(
              loading: controllers.activity.loading,
              hasError: controllers.activity.hasError && summary == null,
              empty: summary == null || goal == null,
              skeletons: 2,
              onRetry: controllers.activity.retry,
              builder: (BuildContext context) {
                final DateTime today = controllers.clock();
                return AppStack(
                  gap: t.space.s3,
                  children: <Widget>[
                    ActivitySummaryCard(
                      summary: summary!,
                      todayIndex: today.weekday - DateTime.monday,
                    ),
                    QuickLogGrid(
                      options: <QuickLogOption>[
                        for (final ActivityType type in goal!.types)
                          QuickLogOption(
                            S.quickLogChip(
                              S.activityNames[type.kind.name]!,
                              type.defaultMin,
                            ),
                            () => _log(type),
                          ),
                      ],
                    ),
                    _sessions(context, t, summary, goal),
                    Callout(
                      // Sin nutriólogo la meta es la sugerida por la app.
                      controllers.profile.hasNutritionist
                          ? S.activityGoalFooter(
                              controllers.profile.nutritionistName,
                              goal.sessions,
                              goal.minutes,
                            )
                          : S.activityGoalSuggested(
                              goal.sessions,
                              goal.minutes,
                            ),
                      tone: CalloutTone.neutralDashed,
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

  Widget _sessions(
    BuildContext context,
    AppTokens t,
    ActivitySummary summary,
    ActivityGoal goal,
  ) {
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s2,
        children: <Widget>[
          const Eyebrow(S.sessionsEyebrow),
          AppButton(
            key: const Key('addSessionButton'),
            label: S.addSession,
            iconLeft: AppIconName.add,
            variant: ButtonVariant.outlineAccent,
            fullWidth: true,
            onPressed: () => _openForm(context),
          ),
          if (summary.logs.isEmpty)
            const EmptyState(title: S.activityEmpty, body: S.activityEmptyBody)
          else
            for (int i = 0; i < summary.logs.length; i++) ...<Widget>[
              if (i > 0) const AppDivider(),
              ListItem(
                leading: SizedBox(
                  width: t.size.dotLg,
                  height: t.size.dotLg,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _kindColor(t.colors, summary.logs[i].kind),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                title: S.activityNames[summary.logs[i].kind.name]!,
                subtitle: S.sessionSubtitle(
                  weekdayName(summary.logs[i].date.weekday),
                  summary.logs[i].kcal,
                ),
                trailing: AppStack(
                  direction: Axis.horizontal,
                  gap: t.space.s1,
                  children: <Widget>[
                    AppText(
                      formatMinutes(summary.logs[i].minutes),
                      variant: TextVariant.label,
                    ),
                    AppIconButton(
                      key: Key('edit-${summary.logs[i].id}'),
                      icon: AppIconName.edit,
                      size: IconButtonSize.sm,
                      semanticLabel: S.editSession,
                      onPressed: () => _openForm(context, summary.logs[i]),
                    ),
                    AppIconButton(
                      key: Key('remove-${summary.logs[i].id}'),
                      icon: AppIconName.delete,
                      size: IconButtonSize.sm,
                      semanticLabel: S.removeSession,
                      onPressed: () => _remove(context, summary.logs[i]),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
