/// Paciente como lo ve el nutriólogo en su lista.
class PatientSummary {
  const PatientSummary({
    required this.uid,
    required this.name,
    required this.email,
    required this.objective,
  });

  final String uid;
  final String name;
  final String email;
  final String objective;
}
