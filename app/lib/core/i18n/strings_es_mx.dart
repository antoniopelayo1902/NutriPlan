/// Every visible string of the app (Spanish, Mexico). Nothing else in lib/
/// may contain user-facing copy.
abstract final class S {
  // App
  static const String appName = 'NutriPlan';

  // Tabs
  static const String tabSemana = 'Semana';
  static const String tabHoy = 'Hoy';
  static const String tabCambiar = 'Cambiar';
  static const String tabMovimiento = 'Movimiento';
  static const String tabProgreso = 'Progreso';

  // Calendar
  static const List<String> weekdays = <String>[
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];
  static const List<String> weekdayInitials = <String>[
    'L',
    'M',
    'M',
    'J',
    'V',
    'S',
    'D',
  ];
  static const List<String> months = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  // Common
  static const String retry = 'Reintentar';
  static const String noValue = '—';
  static const String noMeasurementsTitle = 'Aún no hay mediciones';
  static const String noMeasurementsBody =
      'Tu nutriólogo las registrará en tu siguiente consulta.';
  static const String errorTitle = 'No pudimos cargar tu información';
  static const String errorBody = 'Revisa tu conexión e intenta de nuevo.';
  static const String noPlanTitle = 'Tu nutriólogo aún no publica tu plan';
  static const String noPlanBody = 'Cuando lo publique, lo verás aquí.';
  static const String toastRegionLabel = 'Aviso';
  static const String patientInitialsFallback = 'LM';
  static const String avatarLabel = 'Perfil de la paciente';

  // Meal slots
  static const String slotDesayuno = 'Desayuno';
  static const String slotColacion = 'Colación';
  static const String slotComida = 'Comida';
  static const String slotCena = 'Cena';

  // Food groups: tags (singular, plural) and budget labels
  static const Map<String, List<String>> groupTags = <String, List<String>>{
    'verdura': <String>['Verdura', 'Verduras'],
    'fruta': <String>['Fruta', 'Frutas'],
    'cereal': <String>['Cereal', 'Cereales'],
    'aoa': <String>['Origen animal', 'Origen animal'],
    'leguminosa': <String>['Leguminosa', 'Leguminosas'],
    'leche': <String>['Leche', 'Leches'],
    'grasa': <String>['Grasa', 'Grasas'],
    'azucar': <String>['Azúcar', 'Azúcares'],
  };
  static const Map<String, String> groupBudget = <String, String>{
    'verdura': 'Verduras',
    'fruta': 'Frutas',
    'cereal': 'Cereales y tubérculos',
    'aoa': 'Origen animal',
    'leguminosa': 'Leguminosas',
    'leche': 'Leche',
    'grasa': 'Aceites y grasas',
    'azucar': 'Azúcares',
  };

  // Semana
  static const String semanaEyebrow = 'Plan semanal';
  static const String semanaTitle = 'Mi semana';
  static const String mealChange = 'Cambiar';
  static const String mealMark = 'Marcar';
  static const String mealDone = 'Hecho';
  static const String badgeSwapped = 'cambiado';
  static String planFooter(String nutri, String date, int weeks) =>
      'Plan de $nutri · publicado el $date · vigente $weeks '
      '${weeks == 1 ? 'semana' : 'semanas'}';
  static String dayLabel(String weekday, int day, String status) =>
      '$weekday $day, $status';
  static const String dayComplete = 'completo';
  static const String dayPartial = 'parcial';
  static const String dayPending = 'pendiente';

  // Hoy
  static const String hoyTitle = 'Hoy';
  static const String budgetEyebrow = 'Porciones de hoy';
  static String budgetCovered(int pct) => '$pct% cubierto';
  static const String covered = 'cubierto';
  static String budgetRow(String done, String target) => '$done de $target';
  static String nextMealEyebrow(String slot, String time) =>
      'Siguiente · $slot · $time';
  static const String craveSomethingElse = 'Se me antoja otra cosa';
  static const String allMealsDone =
      'Completaste todas tus comidas de hoy. Buen trabajo.';
  static String swapsCallout(int n) {
    if (n == 0) {
      return 'Aún no haces intercambios esta semana. Cambiar de comida '
          'también cuenta como avance.';
    }
    return 'Llevas $n ${n == 1 ? 'intercambio' : 'intercambios'} esta semana '
        'y sigues dentro del plan.';
  }

  // Cambiar
  static const String cambiarEyebrow = 'Equivalentes';
  static const String cambiarTitle = '¿Otra cosa?';
  static const String pickMealTitle = '¿Cuál comida quieres cambiar?';
  static String changingEyebrow(String slot, String date) =>
      'Cambiando · $slot · $date';
  static const String filterAll = 'Todas';
  static const String filterFits = 'Solo lo que cabe';
  static const String filterAdjust = 'Ajustables';
  static const String filterLabel = 'Filtrar alternativas';
  static const String fitYes = 'cabe hoy';
  static const String fitAdjust = 'ajusta';
  static const String fitNo = 'no cabe';
  static const String trafficCaption =
      'Cabe hoy: encaja en tus porciones del día. Ajusta: cabe si movemos '
      'una porción de otra comida. No cabe: rebasa tus porciones.';
  static const String emptyFilterTitle = 'Sin opciones en este filtro';
  static const String emptyFilterBody =
      'Prueba con otro filtro para ver más alternativas.';
  static const String toastSwapYes =
      'Cambio aplicado. Tus porciones siguen cuadrando.';
  static String toastSwapAdjust(String amount, String group, String slot) =>
      'Cambio aplicado. Moví $amount porción de $group de tu '
      '${slot.toLowerCase()} para que todo cuadre.';
  static String toastSwapNo(String nutri) =>
      'Esa opción rebasa tus porciones del día. $nutri puede autorizarla.';
  static const String toastSwapNoApproval =
      'Ya le avisamos para que la revise.';
  static const String backToPlan = 'Volver a elegir comida';

  // Movimiento
  static const String movimientoEyebrow = 'Actividad física';
  static const String movimientoTitle = 'Movimiento';
  static const String weekEyebrow = 'Esta semana';
  static String minutesValue(String n) => '$n min';
  static String goalPct(int pct, int goal) => '$pct% de $goal min';
  static const String quickLogEyebrow = 'Registro rápido';
  static const String quickLogCaption = 'Un toque y queda registrada.';
  static String quickLogChip(String type, int min) => '$type · $min min';
  static String toastLogged(String type, int min) =>
      'Registraste $type · $min min.';
  static const String toastLogRemoved = 'Sesión eliminada.';
  static const String sessionsEyebrow = 'Sesiones de esta semana';
  static String sessionSubtitle(String day, int kcal) => '$day · $kcal kcal';
  static const String actionFailed =
      'No se pudo guardar el cambio. Intenta de nuevo.';
  static const String removeSession = 'Eliminar sesión';
  static String activityGoalFooter(String nutri, int sessions, int minutes) =>
      'Meta indicada por $nutri: $sessions sesiones · $minutes min';
  static const String activityEmpty = 'Aún no registras actividad esta semana';
  static const String activityEmptyBody =
      'Toca una actividad de arriba para registrarla.';
  static const Map<String, String> activityNames = <String, String>{
    'caminata': 'Caminata',
    'fuerza': 'Fuerza',
    'bici': 'Bici',
    'yoga': 'Yoga',
  };
  static String sessionsCount(int done, int goal) => '$done de $goal sesiones';

  // Progreso
  static const String progresoEyebrow = 'Tu avance';
  static const String progresoTitle = 'Progreso';
  static const String segmentWeek = 'Esta semana';
  static const String segmentMonth = 'Mes con mes';
  static const String adherenceEyebrow = 'Adherencia semanal';
  static String adherenceDelta(String signed) =>
      '$signed pts vs. semana pasada';
  static const String varietyCaption = 'alimentos distintos esta semana';
  static const String varietyLabel = 'Variedad';
  static const String weightChangeLabel = 'Cambio de peso';
  static String weightChangeCaption(String nutri) => 'registrado por $nutri';
  static const String streakEyebrow = 'Racha';
  static String streakDays(int n) =>
      '$n ${n == 1 ? 'día seguido' : 'días seguidos'}';
  static String streakUnit(int n) => n == 1 ? 'día seguido' : 'días seguidos';
  static const String streakCaption = 'con todas tus comidas completas';
  static const String achievementStreak3 = 'Racha de 3 días';
  static const String achievementVariety5 = 'Variedad 5+';
  static const String achievementFirstSwap = 'Primer intercambio';
  static const String achievementAdherence80 = 'Adherencia 80%';
  static const String progressCallout =
      'Tu variedad subió porque usaste equivalentes. Cambiar de comida '
      'cuenta como avance, no como falla.';
  static String chartSummary(String items) => 'Gráfica: $items';

  // Month view
  static const String metricWeight = 'Peso';
  static const String metricBodyFat = '% de grasa';
  static const String metricMuscle = 'Masa muscular';
  static const String metricWaist = 'Cintura';
  static const String metricTricipital = 'Pliegue tricipital';
  static const String unitKg = 'kg';
  static const String unitPct = '%';
  static const String unitCm = 'cm';
  static const String unitMm = 'mm';
  static const String unitM = 'm';
  static const String unitKcal = 'kcal';
  static const String unitMin = 'min';
  static String historyEyebrow(String metric, String from, String to) =>
      '$metric · $from a $to';
  static String deltaVs(String delta, String unit, String month) =>
      '$delta $unit vs. $month';
  static const String measurementImproving = 'Mejorando';
  static const String measurementWatch = 'Para vigilar';
  static const String bodyEyebrow = 'Composición corporal';
  static String bodyCaption(String nutri, String date) =>
      'Medido por $nutri el $date';
  static const String monthsEyebrow = 'Mes por mes';
  static String measuredOn(String date) => 'medido el $date';
  static const String labelWeight = 'Peso';
  static const String labelHeight = 'Talla';
  static const String labelFat = 'Grasa';
  static const String labelMuscle = 'Músculo';
  static const Map<String, String> siteLabels = <String, String>{
    'tricipital': 'Tricipital',
    'bicipital': 'Bicipital',
    'subescapular': 'Subescapular',
    'suprailiaco': 'Suprailiaco',
    'brazo': 'Brazo',
    'cintura': 'Cintura',
    'cadera': 'Cadera',
    'muslo': 'Muslo',
  };
  static String monthSummary(
    String month,
    String weight,
    String fat,
    String waist,
  ) =>
      'Desde $month tu peso cambió $weight, tu grasa corporal $fat y tu '
      'cintura $waist. Cada medida cuenta como avance.';
  static const String monthSummaryFlat =
      'Tus medidas se mantienen estables. Seguimos con el plan.';

  // Login (Firebase Authentication)
  static const String loginEyebrow = 'Bienvenida a';
  static const String loginSubtitle =
      'Tu plan de alimentación por equivalentes, siempre a la mano.';
  static const String loginCardTitle = 'Inicia sesión';
  static const String loginEmail = 'Correo';
  static const String loginPassword = 'Contraseña';
  static const String loginSubmit = 'Entrar';
  static const String loginGoogle = 'Entrar con Google';
  static const String loginRegister = 'Crear cuenta';
  static const String loginForgot = 'Olvidé mi contraseña';
  static const String loginMissingFields = 'Escribe tu correo y tu contraseña.';
  static const String loginMissingEmail =
      'Escribe tu correo para enviarte el enlace.';
  static String loginResetSent(String email) =>
      'Te enviamos un correo a $email para cambiar tu contraseña.';
  static const String signOut = 'Cerrar sesión';
  static String signedInAs(String email) => 'Sesión iniciada como $email';
  static const String authInvalidEmail = 'El correo no es válido.';
  static const String authUserDisabled = 'Esta cuenta está deshabilitada.';
  static const String authWrongCredentials = 'Correo o contraseña incorrectos.';
  static const String authEmailInUse = 'Ya existe una cuenta con ese correo.';
  static const String authWeakPassword =
      'La contraseña debe tener al menos 6 caracteres.';
  static const String authNoNetwork = 'No hay conexión a internet.';
  static const String authTooManyRequests =
      'Demasiados intentos. Espera un momento.';
  static const String authGoogleFailed = 'No se pudo entrar con Google.';
  static const String authUnknown = 'Ocurrió un error. Intenta de nuevo.';

  // Sesión (después del login)
  static const String loadingAccount = 'Preparando tu plan…';
  static const String accountErrorTitle = 'No pudimos cargar tus datos';
  static const String accountErrorBody =
      'Revisa tu conexión a internet e intenta de nuevo.';
  static const String back = 'Regresar';
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';

  // Perfil
  static const String openProfile = 'Abrir mi perfil';
  static const String profileEyebrow = 'Tu cuenta';
  static const String profileTitle = 'Mi perfil';
  static const String changePhoto = 'Cambiar foto';
  static const String photoUpdated = 'Foto de perfil actualizada';
  static const String photoFailed = 'No se pudo abrir la galería.';
  static const String nameLabel = 'Nombre';
  static const String saveName = 'Guardar nombre';
  static const String nameSaved = 'Nombre guardado';
  static const String nameRequired = 'Escribe tu nombre.';
  static const String emailLabel = 'Correo';
  static const String nutritionistLabel = 'Tu nutrióloga';
  static const String tokenLabel = 'Token del dispositivo';
  static const String tokenSaved = 'Guardado en Firebase';
  static const String tokenMissing = 'No disponible en este dispositivo';
  static const String accountEyebrow = 'Cuenta';
  static const String deleteAccount = 'Eliminar cuenta';
  static const String deleteAccountTitle = '¿Eliminar tu cuenta?';
  static const String deleteAccountBody =
      'Se borrarán tu plan, tus sesiones y tus medidas. Esta acción no se '
      'puede deshacer.';
  static const String deleteAccountRecentLogin =
      'Por seguridad, cierra sesión, vuelve a entrar y elimina tu cuenta.';

  // Factor WOW: compartir e importar el plan con un QR
  static const String wowEyebrow = 'Compartir plan';
  static const String wowBody =
      'Comparte tu plan con un código QR o importa el de otra persona.';
  static const String sharePlan = 'Mi código QR';
  static const String sharePlanTitle = 'Mi código';
  static const String sharePlanBody =
      'Muestra este código para que otra persona importe tu plan de la '
      'semana.';
  static const String copyCode = 'Copiar código';
  static const String codeCopied = 'Código copiado';
  static const String scanPlan = 'Importar plan con QR';
  static const String scanTitle = 'Escanear código';
  static const String scanBody =
      'Apunta la cámara al código QR de otro plan o elige una foto del '
      'código.';
  static const String cameraUnavailable =
      'La cámara no está disponible en este dispositivo. Elige una imagen '
      'de la galería.';
  static const String pickQrImage = 'Elegir imagen de la galería';
  static const String pasteCode = 'Pegar código copiado';
  static const String scanHint = 'Apunta aquí al código QR';
  static const String clipboardEmpty = 'No hay un código copiado.';
  static const String invalidCode = 'Ese código no es de NutriPlan.';
  static const String noCodeFound = 'No se encontró un código en la imagen.';
  static const String galleryScanUnavailable =
      'Leer el QR de una foto solo funciona en un teléfono. Usa «Pegar '
      'código copiado».';
  static const String ownCode = 'Ese es tu propio código.';
  static const String importTitle = '¿Importar este plan?';
  static const String importBody =
      'Tu plan de esta semana se reemplazará por el del código.';
  static const String importAction = 'Importar';
  static const String planImported = 'Plan importado';
  static const String importFailed = 'No se pudo importar el plan.';

  // Movimiento: crear, editar y eliminar sesiones
  static const String addSession = 'Agregar sesión';
  static const String newSession = 'Nueva sesión';
  static const String editSession = 'Editar sesión';
  static const String activityTypeLabel = 'Tipo de actividad';
  static const String minutesLabel = 'Minutos';
  static const String sessionDayLabel = 'Día';
  static const String minutesInvalid = 'Escribe entre 1 y 600 minutos.';
  static const String sessionSaved = 'Sesión guardada';
  static const String sessionUpdated = 'Sesión actualizada';
  static const String deleteSessionTitle = '¿Eliminar esta sesión?';
  static String deleteSessionBody(String activity, int minutes) =>
      'Se borrará la sesión de $activity de $minutes min.';
  static String dayChip(String initial, int day) => '$initial $day';
}
