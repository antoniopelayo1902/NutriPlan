import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/toast_controller.dart';
import '../../../core/clock.dart';
import '../../../core/format/es_mx_format.dart';
import '../../../core/i18n/strings_es_mx.dart';
import '../../../data/firestore/firestore_measurement_repository.dart';
import '../../../domain/models/measurement.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../../components/actions/app_button.dart';
import '../../components/actions/app_text_field.dart';
import '../../components/data_display/eyebrow.dart';
import '../../components/primitives/app_card.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../page_frame.dart';

/// Formulario de una medida: vacío para crear o con datos para editar.
/// Es la parte Create y Update del CRUD de medidas.
class MeasurementFormScreen extends StatefulWidget {
  const MeasurementFormScreen({
    super.key,
    required this.repository,
    this.measurement,
  });

  final FirestoreMeasurementRepository repository;
  final Measurement? measurement;

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _fat = TextEditingController();
  final TextEditingController _muscle = TextEditingController();
  final TextEditingController _waist = TextEditingController();
  final TextEditingController _hip = TextEditingController();
  final TextEditingController _tricipital = TextEditingController();
  final Map<String, String> _errors = <String, String>{};
  bool _saving = false;

  bool get _editing => widget.measurement != null;

  /// Número para el campo: 71.2 -> "71.2" (sin ceros de más).
  static String _text(double? v) {
    if (v == null) return '';
    final String fixed = v.toStringAsFixed(2);
    return fixed.replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  void initState() {
    super.initState();
    final Measurement? m = widget.measurement;
    if (m == null) return;
    _weight.text = _text(m.weightKg);
    _height.text = _text(m.heightM);
    _fat.text = _text(m.bodyFatPct);
    _muscle.text = _text(m.muscleKg);
    _waist.text = _text(m.circumferences.cintura);
    _hip.text = _text(m.circumferences.cadera);
    _tricipital.text = _text(m.skinfolds.tricipital);
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _weight,
      _height,
      _fat,
      _muscle,
      _waist,
      _hip,
      _tricipital,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Lee un número (acepta coma o punto). Null si está vacío.
  static double? _parse(TextEditingController c) {
    final String raw = c.text.trim().replaceAll(',', '.');
    return raw.isEmpty ? null : double.tryParse(raw);
  }

  /// Valida un campo: obligatorio o no, y siempre mayor a 0.
  double? _check(String key, TextEditingController c, {bool required = true}) {
    final double? v = _parse(c);
    final bool empty = c.text.trim().isEmpty;
    if ((required && empty) || (!empty && (v == null || v <= 0))) {
      _errors[key] = S.fieldInvalid;
    }
    return v;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    _errors.clear();
    final double? weight = _check('weight', _weight);
    final double? height = _check('height', _height);
    final double? fat = _check('fat', _fat);
    final double? muscle = _check('muscle', _muscle);
    final double? waist = _check('waist', _waist, required: false);
    final double? hip = _check('hip', _hip, required: false);
    final double? tri = _check('tricipital', _tricipital, required: false);
    if (_errors.isNotEmpty) {
      setState(() {});
      return;
    }
    final Measurement? old = widget.measurement;
    // Al editar se conservan los pliegues y perímetros que no están aquí.
    final Measurement m = Measurement(
      id: old?.id ?? 'nueva',
      patientId: widget.repository.uid,
      date: old?.date ?? dateOnly(DateTime.now()),
      weightKg: weight!,
      heightM: height!,
      bodyFatPct: fat!,
      muscleKg: muscle!,
      skinfolds: Skinfolds(
        tricipital: tri,
        bicipital: old?.skinfolds.bicipital,
        subescapular: old?.skinfolds.subescapular,
        suprailiaco: old?.skinfolds.suprailiaco,
      ),
      circumferences: Circumferences(
        brazo: old?.circumferences.brazo,
        cintura: waist,
        cadera: hip,
        muslo: old?.circumferences.muslo,
        pantorrilla: old?.circumferences.pantorrilla,
      ),
    );
    setState(() => _saving = true);
    final ToastController toast = context.read<ToastController>();
    try {
      if (_editing) {
        await widget.repository.update(m);
      } else {
        await widget.repository.add(m);
      }
      toast.show(_editing ? S.measurementUpdated : S.measurementSaved);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      toast.show(S.actionFailed);
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String key, TextEditingController c, String label) =>
      AppTextField(
        key: Key('field-$key'),
        controller: c,
        label: label,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        errorText: _errors[key],
        // Al corregir el campo se quita su error.
        onChanged: (String _) {
          if (_errors.remove(key) != null) setState(() {});
        },
      );

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final DateTime date = widget.measurement?.date ?? DateTime.now();
    return PageFrame(
      eyebrow: S.patientEyebrow,
      title: _editing ? S.editMeasurement : S.newMeasurement,
      children: <Widget>[
        AppCard(
          child: AppStack(
            gap: t.space.s3,
            children: <Widget>[
              const Eyebrow(S.measurementDateLabel),
              AppText(
                S.fullDate(formatLongDate(date), date.year),
                tone: TextTone.secondary,
              ),
              _field('weight', _weight, S.fieldWeight),
              _field('height', _height, S.fieldHeight),
              _field('fat', _fat, S.fieldBodyFat),
              _field('muscle', _muscle, S.fieldMuscle),
              _field('waist', _waist, S.fieldWaist),
              _field('hip', _hip, S.fieldHip),
              _field('tricipital', _tricipital, S.fieldTricipital),
            ],
          ),
        ),
        AppButton(
          key: const Key('saveMeasurementButton'),
          label: S.save,
          fullWidth: true,
          loading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }
}
