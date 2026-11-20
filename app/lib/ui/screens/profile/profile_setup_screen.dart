import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/profile_controller.dart';
import '../../../application/toast_controller.dart';
import '../../../core/clock.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_chip.dart';
import '../../components/actions/app_text_field.dart';
import '../../components/actions/segmented_control.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/data_display/screen_header.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_icon.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';

/// Último paso del registro del paciente: nombre, fecha de nacimiento, sexo
/// y objetivo. Se guarda en Firestore y después se muestra la app.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _name = TextEditingController();
  DateTime? _birthDate;
  String _sex = 'F';
  String _objective = S.objectives.first;
  String? _nameError;
  String? _dateError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name.text = context.read<ProfileController>().patient?.name ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Calendario de Material, abierto en modo de escribir la fecha.
  Future<void> _pickDate() async {
    final DateTime today = dateOnly(DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(today.year - 25, 1, 1),
      firstDate: DateTime(today.year - 100),
      lastDate: today,
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _nameError = _name.text.trim().isEmpty ? S.nameRequired : null;
      _dateError = _birthDate == null ? S.birthDateRequired : null;
    });
    if (_nameError != null || _dateError != null) return;
    setState(() => _saving = true);
    final ToastController toast = context.read<ToastController>();
    final bool ok = await context.read<ProfileController>().saveProfile(
      name: _name.text,
      birthDate: _birthDate!,
      sex: _sex,
      objective: _objective,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    // Si se guardó, la app cambia sola a las pestañas.
    if (!ok) toast.show(S.actionFailed);
  }

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Scaffold(
      key: const Key('profileSetup'),
      backgroundColor: t.colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: t.colors.bgAppGradient),
        // El fondo cubre toda la pantalla aunque el formulario sea corto.
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                t.space.s5,
                t.space.s6,
                t.space.s5,
                t.space.s8,
              ),
              child: AppStack(
                gap: t.space.s5,
                children: <Widget>[
                  const ScreenHeader(
                    eyebrow: S.setupEyebrow,
                    title: S.setupTitle,
                  ),
                  const AppText(S.setupBody, tone: TextTone.secondary),
                  AppCard(
                    child: AppStack(
                      gap: t.space.s4,
                      children: <Widget>[
                        AppTextField(
                          key: const Key('setupName'),
                          controller: _name,
                          label: S.nameLabel,
                          errorText: _nameError,
                          onChanged: (String _) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const Eyebrow(S.birthDateLabel),
                        AppButton(
                          key: const Key('setupBirthDate'),
                          label: _birthDate == null
                              ? S.birthDatePick
                              : S.fullDate(
                                  formatDayMonth(_birthDate!),
                                  _birthDate!.year,
                                ),
                          iconLeft: AppIconName.calendar,
                          variant: ButtonVariant.outlineNeutral,
                          fullWidth: true,
                          onPressed: _pickDate,
                        ),
                        if (_dateError != null)
                          AppText(
                            _dateError!,
                            key: const Key('setupDateError'),
                            variant: TextVariant.bodySm,
                            tone: TextTone.danger,
                          ),
                        const Eyebrow(S.sexLabel),
                        SegmentedControl<String>(
                          key: const Key('setupSex'),
                          fullWidth: true,
                          value: _sex,
                          onChanged: (String v) => setState(() => _sex = v),
                          options: const <SegmentOption<String>>[
                            SegmentOption<String>('F', S.sexFemale),
                            SegmentOption<String>('M', S.sexMale),
                          ],
                        ),
                        const Eyebrow(S.objectiveLabel),
                        Wrap(
                          spacing: t.space.s2,
                          runSpacing: t.space.s2,
                          children: <Widget>[
                            for (int i = 0; i < S.objectives.length; i++)
                              AppChip(
                                key: Key('objective-$i'),
                                label: S.objectives[i],
                                selected: _objective == S.objectives[i],
                                onPressed: () => setState(
                                  () => _objective = S.objectives[i],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    key: const Key('setupSave'),
                    label: S.setupSave,
                    fullWidth: true,
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
