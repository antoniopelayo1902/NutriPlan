import '../errors.dart';

class Nutritionist {
  Nutritionist({required this.id, required this.name}) {
    if (id.isEmpty || name.isEmpty) {
      throw const DomainValidationError(
        'Nutritionist id and name are required',
      );
    }
  }

  final String id;

  /// Display name including the title, for example "Nut. Ana Rivas".
  final String name;
}

class Patient {
  Patient({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.sex,
    required this.objective,
    this.nutritionistId,
    this.profileComplete = true,
  }) {
    if (id.isEmpty || name.trim().isEmpty) {
      throw const DomainValidationError('Patient id and name are required');
    }
  }

  final String id;
  final String name;
  final DateTime birthDate;
  final String sex;
  final String objective;

  /// Null mientras el paciente no se vincula con un nutriólogo.
  final String? nutritionistId;

  /// False justo después del registro, hasta que llena sus datos.
  final bool profileComplete;

  /// Up to two initials from the name, upper-cased.
  String get initials {
    final List<String> parts = name
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final String first = parts.first.substring(0, 1);
    final String second = parts.length > 1 ? parts[1].substring(0, 1) : '';
    return (first + second).toUpperCase();
  }
}
