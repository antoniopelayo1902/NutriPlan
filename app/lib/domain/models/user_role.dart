/// Tipo de cuenta. Se elige al registrarse y se guarda en users/{uid}.role.
enum UserRole {
  patient,
  nutritionist;

  /// Cuentas viejas sin rol se toman como paciente.
  static UserRole parse(Object? raw) =>
      raw == UserRole.nutritionist.name ? nutritionist : patient;
}
