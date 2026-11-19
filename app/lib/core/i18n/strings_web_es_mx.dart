/// Spanish (MX) copy for the nutritionist web layout. Gender-neutral.
abstract final class SWeb {
  static const String addPatient = 'Agregar paciente';
  static const String addPatientTitle = 'Nuevo paciente';
  static const String addPatientBody =
      'Captura sus datos para llevar sus medidas y su plan desde aquí.';
  static const String addPatientNote =
      'Es un registro tuyo: el paciente no tendrá cuenta en la app.';
  static const String addPatientName = 'Nombre completo';
  static const String addPatientEmail = 'Correo (opcional)';
  static const String addPatientObjective = 'Objetivo (opcional)';
  static const String addPatientNameRequired = 'Escribe su nombre.';
  static const String addPatientCreate = 'Crear paciente';
  static const String addPatientOr = 'o vincula a alguien con su propia cuenta';
  static const String addPatientDone = 'Paciente agregado';
  static String webGreeting(String name) => 'Hola, $name';
  static const String webGreetingFallback = 'Hola';
  static const String webGreetingSub = 'Qué gusto verte de nuevo.';
  static const String webSearchPatients = 'Buscar paciente';
  static const String webNoMatches =
      'Ningún paciente coincide con tu búsqueda.';
  static const String webEmptyNoPatientsBody =
      'Cuando alguien se vincule contigo con tu código QR, lo verás aquí.';
  static const String webBrandTagline = 'Cuidar de tus pacientes, con calma.';
  static const String webBrandBody =
      'Da seguimiento a su progreso, registra sus medidas y publica su plan '
      'desde un solo lugar.';
  static const String webBrandPoint1 = 'Medidas e historial de cada paciente';
  static const String webBrandPoint2 = 'Porciones y plan siempre al día';
  static const String webBrandPoint3 = 'Vinculación rápida con código QR';
  static const String webLoginWelcome = 'Qué gusto verte';
  static const String webStatWeight = 'Peso actual';
  static const String webStatBmi = 'IMC';
  static const String webStatPlan = 'Plan diario';
  static const String webStatEmpty = '—';
  static const String webStatNoObjective = 'Sin objetivo registrado';
  static const String webOnlyNutriTitle = 'Solo para nutriólogos';
  static const String webOnlyNutriBody =
      'La versión web es para nutriólogos. Usa la app móvil para ver tu plan.';
  static const String selectPatientTitle = 'Elige un paciente';
  static const String selectPatientBody =
      'Selecciona a alguien de la lista para ver sus medidas y su plan.';
}
