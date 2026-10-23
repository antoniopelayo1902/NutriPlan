import '../errors.dart';

/// Skinfold thicknesses in millimetres.
class Skinfolds {
  const Skinfolds({
    this.tricipital,
    this.bicipital,
    this.subescapular,
    this.suprailiaco,
  });

  final double? tricipital;
  final double? bicipital;
  final double? subescapular;
  final double? suprailiaco;
}

/// Circumferences in centimetres.
class Circumferences {
  const Circumferences({
    this.brazo,
    this.cintura,
    this.cadera,
    this.muslo,
    this.pantorrilla,
  });

  final double? brazo;
  final double? cintura;
  final double? cadera;
  final double? muslo;
  final double? pantorrilla;
}

class Measurement {
  Measurement({
    required this.id,
    required this.patientId,
    required this.date,
    required this.weightKg,
    required this.heightM,
    required this.bodyFatPct,
    required this.muscleKg,
    this.skinfolds = const Skinfolds(),
    this.circumferences = const Circumferences(),
  }) {
    if (id.isEmpty || patientId.isEmpty) {
      throw const DomainValidationError('Measurement ids are required');
    }
    final List<double?> all = <double?>[
      weightKg,
      heightM,
      bodyFatPct,
      muscleKg,
      skinfolds.tricipital,
      skinfolds.bicipital,
      skinfolds.subescapular,
      skinfolds.suprailiaco,
      circumferences.brazo,
      circumferences.cintura,
      circumferences.cadera,
      circumferences.muslo,
      circumferences.pantorrilla,
    ];
    for (final double? v in all) {
      if (v != null && (v.isNaN || v <= 0)) {
        throw const DomainValidationError('Measurements must be positive');
      }
    }
  }

  final String id;
  final String patientId;
  final DateTime date;
  final double weightKg;
  final double heightM;
  final double bodyFatPct;
  final double muscleKg;
  final Skinfolds skinfolds;
  final Circumferences circumferences;
}
