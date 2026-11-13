import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/activity_controller.dart';
import '../../../application/app_controllers.dart';
import '../../../application/toast_controller.dart';
import '../../../core/clock.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../domain/models/activity.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_chip.dart';
import '../../components/actions/app_text_field.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_stack.dart';
import '../page_frame.dart';

/// Formulario para crear una sesión nueva o editar una que ya existe
/// (si llega [log]). Es la parte Create y Update del CRUD.
class ActivityFormScreen extends StatefulWidget {
  const ActivityFormScreen({super.key, this.log});

  final ActivityLog? log;

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final TextEditingController _minutes = TextEditingController();
  late ActivityKind _kind;
  late DateTime _date;
  late Clock _clock;
  String? _minutesError;
  bool _saving = false;

  bool get _editing => widget.log != null;

  @override
  void initState() {
    super.initState();
    final ActivityController c = context.read<ActivityController>();
    _clock = context.read<AppControllers>().clock;
    final ActivityLog? log = widget.log;
    final ActivityType first = c.goal!.types.first;
    _kind = log?.kind ?? first.kind;
    _date = log?.date ?? dateOnly(_clock());
    _minutes.text = '${log?.minutes ?? first.defaultMin}';
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  /// Al cambiar el tipo en una sesión nueva, se ponen sus minutos sugeridos.
  void _selectKind(ActivityType type) {
    setState(() {
      _kind = type.kind;
      if (!_editing) _minutes.text = '${type.defaultMin}';
    });
  }

  /// Valida los minutos y guarda en Firestore (create o update).
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final int? minutes = int.tryParse(_minutes.text.trim());
    if (minutes == null ||
        minutes < ActivityType.minMinutes ||
        minutes > ActivityType.maxMinutes) {
      setState(() => _minutesError = S.minutesInvalid);
      return;
    }
    setState(() {
      _minutesError = null;
      _saving = true;
    });
    final ActivityController c = context.read<ActivityController>();
    final ToastController toast = context.read<ToastController>();
    final ActivityLog? saved = _editing
        ? await c.edit(widget.log!.id, _kind, minutes, _date)
        : await c.create(_kind, minutes, _date);
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved == null) {
      toast.show(S.actionFailed);
      return;
    }
    toast.show(_editing ? S.sessionUpdated : S.sessionSaved);
    Navigator.pop(context);
  }

  /// Días de esta semana hasta hoy (no se registran días futuros).
  List<DateTime> _days() {
    final DateTime today = dateOnly(_clock());
    final DateTime monday = mondayOf(today);
    return <DateTime>[
      for (int i = 0; i <= today.difference(monday).inDays; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final List<ActivityType> types = context
        .watch<ActivityController>()
        .goal!
        .types;
    final List<DateTime> days = _days();
    // Si la sesión es de otra semana, se conserva su fecha como opción.
    if (!days.any((DateTime d) => sameDay(d, _date))) days.insert(0, _date);
    return PageFrame(
      eyebrow: S.movimientoEyebrow,
      title: _editing ? S.editSession : S.newSession,
      children: <Widget>[
        AppCard(
          child: AppStack(
            gap: t.space.s4,
            children: <Widget>[
              const Eyebrow(S.activityTypeLabel),
              Wrap(
                spacing: t.space.s2,
                runSpacing: t.space.s2,
                children: <Widget>[
                  for (final ActivityType type in types)
                    AppChip(
                      key: Key('kind-${type.kind.name}'),
                      label: S.activityNames[type.kind.name]!,
                      selected: type.kind == _kind,
                      onPressed: () => _selectKind(type),
                    ),
                ],
              ),
              AppTextField(
                key: const Key('minutesField'),
                controller: _minutes,
                label: S.minutesLabel,
                keyboardType: TextInputType.number,
                errorText: _minutesError,
                onChanged: (String _) {
                  if (_minutesError != null) {
                    setState(() => _minutesError = null);
                  }
                },
              ),
              const Eyebrow(S.sessionDayLabel),
              Wrap(
                spacing: t.space.s2,
                runSpacing: t.space.s2,
                children: <Widget>[
                  for (final DateTime d in days)
                    AppChip(
                      key: Key('day-${d.day}'),
                      label: S.dayChip(S.weekdayInitials[d.weekday - 1], d.day),
                      size: ChipSize.sm,
                      selected: sameDay(d, _date),
                      onPressed: () => setState(() => _date = d),
                    ),
                ],
              ),
            ],
          ),
        ),
        AppButton(
          key: const Key('saveSessionButton'),
          label: S.save,
          fullWidth: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
