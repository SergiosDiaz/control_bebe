// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mibebé';

  @override
  String get navHome => 'INICIO';

  @override
  String get navDiapers => 'PAÑALES';

  @override
  String get navFeeding => 'ALIMENTACIÓN';

  @override
  String get navWeight => 'PESO';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get deleteRecordConfirmTitle => '¿Eliminar este registro?';

  @override
  String get deleteRecordConfirmBody =>
      'Se borrará de forma permanente. Esta acción no se puede deshacer.';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonDate => 'Fecha';

  @override
  String get commonTime => 'Hora';

  @override
  String get commonTimeStart => 'Hora inicio';

  @override
  String get commonTimeEnd => 'Hora fin';

  @override
  String get commonGenderBoy => 'Niño';

  @override
  String get commonGenderGirl => 'Niña';

  @override
  String get commonSend => 'Enviar';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonExit => 'Salir';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyScrollLoadMore =>
      'Desliza hasta el final para cargar tres días más de historial.';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get timeSuffixMinute => 'min';

  @override
  String get timeSuffixHour => 'h';

  @override
  String get timeSuffixSecond => 's';

  @override
  String timeHoursOnly(Object h) {
    return '${h}h';
  }

  @override
  String timeHoursMinutes(Object h, Object m) {
    return '${h}h $m min';
  }

  @override
  String timeMinutesOnly(Object m) {
    return '$m min';
  }

  @override
  String durationMinutesSeconds(Object m, Object s) {
    return '${m}m ${s}s';
  }

  @override
  String durationHoursMinutes(Object h, Object m) {
    return '${h}h ${m}m';
  }

  @override
  String durationHoursMinutesSeconds(Object h, Object m, Object s) {
    return '${h}h ${m}m ${s}s';
  }

  @override
  String durationHoursOnly(Object h) {
    return '${h}h';
  }

  @override
  String get feedingIntervalHoursOne => '1 hora';

  @override
  String feedingIntervalHoursN(Object n) {
    return '$n horas';
  }

  @override
  String feedingIntervalHoursMinutes(Object h, Object m) {
    return '${h}h ${m}min';
  }

  @override
  String get profileDefaultBabyName => 'Bebé';

  @override
  String get profileWeightLabel => 'PESO';

  @override
  String get profileHeightLabel => 'ALTURA';

  @override
  String get babyAgeMonthsOneDaysOne => '1 MES, 1 DÍA';

  @override
  String babyAgeMonthsOneDaysN(Object days) {
    return '1 MES, $days DÍAS';
  }

  @override
  String babyAgeMonthsNDaysOne(Object months) {
    return '$months MESES, 1 DÍA';
  }

  @override
  String babyAgeMonthsNDaysN(Object days, Object months) {
    return '$months MESES, $days DÍAS';
  }

  @override
  String get monthiversaryOne => '¡Hoy cumple 1 mes!';

  @override
  String monthiversaryN(Object months) {
    return '¡Hoy cumple $months meses!';
  }

  @override
  String get monthiversarySemanticsHint =>
      'Pulsa para confeti; hasta dos veces hasta que termine';

  @override
  String get homeSummaryTitle => 'Resumen de Hoy';

  @override
  String get homeLastFeedLabel => 'ÚLTIMA TOMA';

  @override
  String homeLastFeedAgo(Object time) {
    return 'Hace $time';
  }

  @override
  String get homeNextFeedSoon => 'Próxima toma pronto';

  @override
  String homeNextFeedIn(Object time) {
    return 'Próxima toma en $time';
  }

  @override
  String get homeNoFeedingsYet =>
      'Sin tomas registradas aún. Toca para anotar la primera.';

  @override
  String get homeWeightNoRecords =>
      'No hay registros de peso. Toca para añadir el primero.';

  @override
  String homeWeightTrendGramsPerDay(Object sign, Object value) {
    return '$sign$value g/día';
  }

  @override
  String homeWeightTrendOuncesPerDay(Object sign, Object value) {
    return '$sign$value oz/día';
  }

  @override
  String homeWeightLast(Object date) {
    return 'Último: $date';
  }

  @override
  String get homeDiapersNoRecords =>
      'No hay pañales registrados. Toca para añadir el primero.';

  @override
  String homeDiapersWetDirty(Object dirty, Object wet) {
    return '$wet mojados · $dirty sucios';
  }

  @override
  String get homeDiaperChangesOne => '1 cambio';

  @override
  String homeDiaperChangesN(Object n) {
    return '$n cambios';
  }

  @override
  String get homeTipTitle => 'Consejo del día ✨';

  @override
  String get homeTipFallback =>
      'Los bebés pueden reconocer la voz de su madre desde el útero. Hablarles con calma refuerza ese vínculo.';

  @override
  String get sabiasQueNoBirthDate =>
      'Añade la fecha de nacimiento del bebé en ajustes para ver consejos según su edad.';

  @override
  String get homeConfigureProfileFirst =>
      'Configura primero el perfil del bebé en Ajustes';

  @override
  String get homePickPhoto => 'Elegir foto';

  @override
  String get homeRemovePhoto => 'Quitar foto del perfil';

  @override
  String get homePhotoRemoved => 'Foto del perfil eliminada';

  @override
  String homePhotoRemoveError(Object error) {
    return 'Error al quitar la foto: $error';
  }

  @override
  String get homePhotoUpdated => 'Foto actualizada';

  @override
  String homePhotoUploadError(Object error) {
    return 'Error al subir la foto: $error';
  }

  @override
  String get feedingTitle => 'Alimentación';

  @override
  String get feedingSessionType => 'Tipo de toma';

  @override
  String get feedingBreast => 'Pecho';

  @override
  String get feedingLeft => 'Izquierdo';

  @override
  String get feedingRight => 'Derecho';

  @override
  String get feedingBottle => 'Biberón';

  @override
  String get feedingSolidFood => 'Sólidos';

  @override
  String get solidFoodTitle => 'Alimento sólido';

  @override
  String get solidFoodNameLabel => 'Qué ha comido';

  @override
  String get solidFoodNameHint => 'Ej: puré de manzana';

  @override
  String get solidFoodQuantityLabel => 'Cantidad';

  @override
  String get solidFoodUnitGrams => 'g (gramos)';

  @override
  String get solidFoodUnitUnits => 'u (unidades)';

  @override
  String get solidFoodUnitGramShort => 'g';

  @override
  String get solidFoodUnitUnitsShort => 'u';

  @override
  String get solidFoodQuantityHintGrams => 'Ej: 40 o 0,47 (coma o punto)';

  @override
  String get solidFoodQuantityHintUnits => 'Solo número entero, ej: 2';

  @override
  String get solidFoodValidatorNameEmpty => 'Indica qué ha comido';

  @override
  String get solidFoodValidatorQuantityEmpty => 'Indica la cantidad';

  @override
  String solidFoodValidatorQuantityInvalid(Object max) {
    return 'Número entero entre 1 y $max';
  }

  @override
  String get solidFoodValidatorQuantityParse =>
      'Formato no válido: solo números y una coma o punto decimal (ej. 0,47).';

  @override
  String get solidFoodValidatorUnitsNoDecimals =>
      'En unidades usa solo números enteros, sin coma ni punto.';

  @override
  String get solidFoodValidatorGramsPositive =>
      'El peso en gramos debe ser mayor que 0.';

  @override
  String solidFoodValidatorGramsRange(Object max) {
    return 'El peso no puede superar $max g.';
  }

  @override
  String get feedingChooseSideTitle => '¿Qué lado?';

  @override
  String get feedingChooseSideSubtitle =>
      'Elige el pecho para iniciar el cronómetro.';

  @override
  String get feedingEditSolid => 'Editar sólidos';

  @override
  String get feedingStop => 'Parar';

  @override
  String feedingActiveTimer(Object side) {
    return 'Cronómetro activo: $side';
  }

  @override
  String get feedingSideLeft => 'Izquierdo';

  @override
  String get feedingSideRight => 'Derecho';

  @override
  String get feedingHistoryEmpty =>
      'Todavía no hay registros. Usa «Pecho», «Biberón» o «Sólidos» arriba para añadir la primera.';

  @override
  String get feedingSessionCountOne => '1 toma';

  @override
  String feedingSessionCountN(Object n) {
    return '$n tomas';
  }

  @override
  String get feedingEditBottle => 'Editar biberón';

  @override
  String get feedingEditSession => 'Editar toma';

  @override
  String get feedingAmountMl => 'Cantidad (ml)';

  @override
  String get hintExampleMl => 'Ej: 120';

  @override
  String get feedingStreamError =>
      'No se pudieron cargar las tomas. Reintenta o comprueba la conexión.';

  @override
  String lastFeedDetailLeftMinutes(Object minutes) {
    return 'Izquierda • $minutes min';
  }

  @override
  String get lastFeedDetailLeft => 'Izquierda';

  @override
  String lastFeedDetailRightMinutes(Object minutes) {
    return 'Derecha • $minutes min';
  }

  @override
  String get lastFeedDetailRight => 'Derecha';

  @override
  String lastFeedDetailBottleVolume(Object volume) {
    return 'Biberón • $volume';
  }

  @override
  String get lastFeedDetailSolid => 'Sólidos';

  @override
  String get diapersTitle => 'Control de Pañales';

  @override
  String get diapersChangeType => 'Tipo de cambio';

  @override
  String get diaperWet => 'Mojado';

  @override
  String get diaperDirty => 'Sucio';

  @override
  String get diaperBoth => 'Ambos';

  @override
  String get diapersRegisterButton => 'Registrar Cambio de Pañal';

  @override
  String get diapersHistoryEmpty =>
      'Todavía no hay registros. Usa «Registrar cambio de pañal» arriba para añadir el primero.';

  @override
  String get diaperChangeCountOne => '1 cambio';

  @override
  String diaperChangeCountN(Object n) {
    return '$n cambios';
  }

  @override
  String get diapersStreamError =>
      'No se pudieron cargar los pañales. Reintenta o comprueba la conexión.';

  @override
  String get diapersEditRecord => 'Editar registro';

  @override
  String get diapersTypeLabel => 'Tipo';

  @override
  String get weightTitle => 'Control de Peso';

  @override
  String get weightFieldLabelMetric => 'Peso (kg)';

  @override
  String get weightFieldLabelImperial => 'Peso (lb)';

  @override
  String get hintExampleWeight => 'Ej: 4.5';

  @override
  String get weightRegister => 'Registrar';

  @override
  String get weightValidatorEmpty => 'Introduce el peso';

  @override
  String get weightValidatorInvalid => 'Peso inválido';

  @override
  String get weightStreamError =>
      'No se pudieron cargar los pesos. Comprueba la conexión o reintenta.';

  @override
  String get weightEvolution => 'Evolución';

  @override
  String weightChartCaption(String percentile) {
    return 'Línea de referencia: $percentile peso por edad (OMS).';
  }

  @override
  String get weightChartSource =>
      'Fuente: Organización Mundial de la Salud (OMS) — Child Growth Standards. who.int/tools/child-growth-standards';

  @override
  String get weightChartLoadError => 'No se pudo cargar la gráfica de peso.';

  @override
  String get weightHistoryLoadError =>
      'No se pudo cargar el historial de peso.';

  @override
  String get weightHistoryEmpty =>
      'Todavía no hay registros. Escribe el peso y pulsa «Registrar» arriba para añadir el primero.';

  @override
  String get weightCurrentCard => 'Peso Actual';

  @override
  String get weightTrendCard => 'Tendencia diaria';

  @override
  String weightTrendGramsCompact(Object sign, Object value) {
    return '$sign${value}g';
  }

  @override
  String weightTrendOuncesCompact(Object sign, Object value) {
    return '$sign$value oz';
  }

  @override
  String get weightNoData => 'Sin datos';

  @override
  String get weightDash => '-';

  @override
  String get weightChartEmpty => 'Sin datos aún';

  @override
  String get weightChartNoDataInRange => 'No hay pesadas en este periodo';

  @override
  String get weightChartRangeAll => 'Todo';

  @override
  String get weightChartRange7d => '7 días';

  @override
  String get weightChartRange30d => '30 días';

  @override
  String get weightChartRange90d => '3 meses';

  @override
  String get weightChartRange365d => '1 año';

  @override
  String weightTooltipPercentile(String label, String value) {
    return '$label (OMS): $value';
  }

  @override
  String weightTooltipWeighIn(Object value) {
    return 'Pesada: $value';
  }

  @override
  String get weightChartPercentileSelector => 'Percentil';

  @override
  String get weightEditTitle => 'Editar peso';

  @override
  String get bottleTitle => 'Biberón';

  @override
  String get bottleValidatorEmpty => 'Introduce la cantidad';

  @override
  String get bottleValidatorInvalid => 'Cantidad inválida';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsBabyProfile => 'Perfil del Bebé';

  @override
  String get settingsShareFamily => 'Compartir Familia';

  @override
  String get settingsSuggestedFeedings => 'Tomas sugeridas';

  @override
  String get settingsName => 'Nombre';

  @override
  String get settingsBirthDate => 'Fecha de nacimiento';

  @override
  String get settingsHeight => 'Altura';

  @override
  String get settingsNoProfile => 'Sin perfil configurado';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsShareQrIntro =>
      'Invita a otros miembros de la familia escaneando el código QR.';

  @override
  String get settingsFeedingConfigureFirst =>
      'Configura primero el perfil del bebé.';

  @override
  String get settingsFeedingIntro => 'Define cada cuánto suele comer el bebé';

  @override
  String get settingsFeedingInterval => 'Intervalo entre tomas';

  @override
  String get settingsNotifyTitle => 'Activar notificaciones';

  @override
  String get settingsNotifySubtitle =>
      'Notificaciones en la hora sugerida de la siguiente toma.';

  @override
  String get settingsNotifyPermission =>
      'Activa las notificaciones en los ajustes del sistema para recibir el aviso.';

  @override
  String get settingsSignOutSection => 'Cerrar sesión';

  @override
  String get settingsSignOutButton => 'Cerrar sesión';

  @override
  String get settingsSignOutRowSubtitle => 'Cerrar sesión en este dispositivo';

  @override
  String get settingsDeleteSection => 'Eliminar cuenta';

  @override
  String get settingsDeleteIntro =>
      'Elimina tu cuenta y tus datos de acceso. Si eres el único miembro de la familia, también se eliminarán todos los datos del bebé.';

  @override
  String get settingsDeleteAccount => 'Eliminar mi cuenta';

  @override
  String get settingsDeleteAccountRowSubtitle =>
      'Eliminar la cuenta y sus datos';

  @override
  String get settingsDeleting => 'Eliminando...';

  @override
  String get settingsFamilyFirebaseOnly =>
      'Compartir familia solo disponible con Firebase.';

  @override
  String get settingsShowQr => 'Mostrar QR para invitar';

  @override
  String get settingsHideQr => 'Ocultar QR';

  @override
  String get settingsQrCaption => 'Escanea para unirte a la familia';

  @override
  String get settingsGroupBaby => 'Bebé';

  @override
  String get settingsGroupPreferences => 'Preferencias';

  @override
  String get settingsGroupFamily => 'Familia';

  @override
  String get settingsGroupAccount => 'Cuenta';

  @override
  String get settingsRowProfileTitle => 'Datos del perfil';

  @override
  String get settingsRowProfileSubtitle => 'Nombre, fecha y altura';

  @override
  String get settingsRowProfileEmpty => 'Sin configurar';

  @override
  String get settingsRowFeedingInterval => 'Intervalo entre tomas';

  @override
  String get settingsRowFeedingNotify => 'Avisar próxima toma';

  @override
  String get settingsRowUnitWeight => 'Unidad de peso';

  @override
  String get settingsRowUnitLiquid => 'Unidad de líquidos';

  @override
  String get settingsRowFamilyShare => 'Compartir con familia';

  @override
  String get settingsRowFamilyShareSubtitle =>
      'Mostrar código QR de invitación';

  @override
  String get settingsValueOn => 'Activado';

  @override
  String get settingsValueOff => 'Desactivado';

  @override
  String get settingsValueNotSet => '—';

  @override
  String get settingsBabyAgeMonthsOne => '1 mes';

  @override
  String settingsBabyAgeMonthsN(int months) {
    return '$months meses';
  }

  @override
  String get settingsBabyAgeDaysOne => '1 día';

  @override
  String settingsBabyAgeDaysN(int days) {
    return '$days días';
  }

  @override
  String settingsBabyBornOn(String date) {
    return 'Nacido el $date';
  }

  @override
  String settingsBabyBornOnFemale(String date) {
    return 'Nacida el $date';
  }

  @override
  String get settingsSheetUnitWeightTitle => 'Unidad de peso';

  @override
  String get settingsSheetUnitLiquidTitle => 'Unidad de líquidos';

  @override
  String get settingsSheetFeedingIntervalTitle => 'Intervalo entre tomas';

  @override
  String get settingsSheetShareTitle => 'Compartir con familia';

  @override
  String get editBabyProfileTitle => 'Editar perfil del bebé';

  @override
  String get labelName => 'Nombre';

  @override
  String get labelGender => 'Género';

  @override
  String get heightFieldLabel => 'Altura (cm)';

  @override
  String get heightFieldHint => 'Opcional, ej. 58';

  @override
  String get heightInvalid => 'Altura inválida';

  @override
  String get heightRangeError => 'Altura debe estar entre 25 y 120 cm';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountBody =>
      'Esta acción eliminará permanentemente tu cuenta y tus datos de acceso. Si eres el único miembro de la familia, también se eliminarán todos los datos del bebé.\n\nEsta operación no se puede deshacer. ¿Estás seguro?';

  @override
  String get deleteAccountConfirm => 'Eliminar cuenta';

  @override
  String deleteAccountError(Object error) {
    return 'Error al eliminar la cuenta: $error';
  }

  @override
  String get signOutTitle => 'Cerrar sesión';

  @override
  String get signOutBody => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get signOutConfirm => 'Cerrar sesión';

  @override
  String signOutError(Object error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get loginForgotPasswordTitle => 'Recuperar contraseña';

  @override
  String get loginForgotPasswordBody =>
      'Te enviaremos un enlace para elegir una contraseña nueva.';

  @override
  String get loginEmailHint => 'Tu correo electrónico';

  @override
  String get loginResetInvalidEmail => 'Introduce un correo válido';

  @override
  String get loginResetCheckEmail =>
      'Revisa tu correo (y spam) para restablecer la contraseña';

  @override
  String get loginResetSendFail =>
      'No se pudo enviar el correo. Inténtalo más tarde.';

  @override
  String get loginHeaderTitle => 'Mibebé';

  @override
  String get loginPasswordHint => 'Tu contraseña';

  @override
  String get loginForgotLink => '¿Has olvidado tu contraseña?';

  @override
  String get loginValidatorEmailEmpty => 'Introduce tu correo';

  @override
  String get loginValidatorEmailInvalid => 'Correo no válido';

  @override
  String get loginValidatorPasswordEmpty => 'Introduce tu contraseña';

  @override
  String get loginSignIn => 'Iniciar Sesión';

  @override
  String get loginGuestQr => 'Unirme con código QR (sin cuenta)';

  @override
  String get loginOrWith => 'O INICIA SESIÓN CON';

  @override
  String get loginNoAccount => '¿No tienes cuenta? ';

  @override
  String get loginRegisterLink => 'Regístrate';

  @override
  String get loginErrorGeneric => 'Error al iniciar sesión';

  @override
  String get loginErrorGoogle => 'Error al iniciar sesión con Google';

  @override
  String get loginErrorApple => 'Error al iniciar sesión con Apple';

  @override
  String get loginGuestNeedsFirebase =>
      'Hace falta Firebase para unirte con código QR';

  @override
  String get loginGuestNotAllowed =>
      'Invitado no disponible. En Firebase Console → Authentication → Sign-in method, activa \"Anónimo\".';

  @override
  String get loginGuestFailed => 'No se pudo entrar como invitado';

  @override
  String get authErrorUserNotFound => 'No existe una cuenta con este correo';

  @override
  String get authErrorWrongPassword => 'Contraseña incorrecta';

  @override
  String get authErrorInvalidEmail => 'Correo electrónico no válido';

  @override
  String get authErrorUserDisabled => 'Esta cuenta ha sido deshabilitada';

  @override
  String get authErrorInvalidCredential => 'Credenciales inválidas';

  @override
  String get authErrorOperationNotAllowed =>
      'Método de inicio de sesión no habilitado';

  @override
  String get authErrorGeneric => 'Error al iniciar sesión';

  @override
  String get resetErrorInvalidEmail => 'Correo electrónico no válido';

  @override
  String get resetErrorUserNotFound =>
      'No hay cuenta con este correo. Comprueba el email o regístrate.';

  @override
  String get resetErrorUserDisabled => 'Esta cuenta está deshabilitada';

  @override
  String get resetErrorOpNotAllowed =>
      'Recuperación por correo no habilitada en Firebase (Authentication → Sign-in method → Email).';

  @override
  String get resetErrorGeneric =>
      'No se pudo enviar el correo. Inténtalo más tarde.';

  @override
  String get registerTitle => 'Registro';

  @override
  String get registerHeadline => 'Crea tu cuenta';

  @override
  String get registerSubtitle => 'Introduce tus datos para registrarte';

  @override
  String get registerEmailLabel => 'Correo electrónico';

  @override
  String get registerPasswordLabel => 'Contraseña';

  @override
  String get registerConfirmLabel => 'Confirmar contraseña';

  @override
  String get registerPasswordHint => 'Mínimo 6 caracteres';

  @override
  String get registerEmailHint => 'tu@email.com';

  @override
  String get registerValidatorEmailEmpty => 'Introduce tu correo';

  @override
  String get registerValidatorPasswordEmpty => 'Introduce una contraseña';

  @override
  String get registerValidatorPasswordShort => 'Mínimo 6 caracteres';

  @override
  String get registerValidatorConfirmEmpty => 'Confirma tu contraseña';

  @override
  String get registerValidatorMismatch => 'Las contraseñas no coinciden';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get registerHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get registerSignInLink => 'Inicia sesión';

  @override
  String get registerErrorGeneric =>
      'Error al registrarse. Comprueba tu conexión y que el registro por email esté habilitado en Firebase.';

  @override
  String get registerErrorEmailInUse =>
      'Ya existe una cuenta con este correo. Usa \"Inicia sesión\" en su lugar.';

  @override
  String get registerErrorWeakPassword =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get registerErrorOpNotAllowed =>
      'Registro por email no habilitado. Actívalo en Firebase Console > Authentication > Sign-in method';

  @override
  String get registerErrorNetwork =>
      'Error de conexión. Comprueba tu internet.';

  @override
  String get registerErrorTooMany =>
      'Demasiados intentos. Espera unos minutos.';

  @override
  String get registerErrorInvalidCredential => 'Credenciales inválidas';

  @override
  String registerErrorUnknown(Object code) {
    return 'Error: $code. Revisa Firebase Console.';
  }

  @override
  String get onboardingWelcome => 'Bienvenido a Mibebé';

  @override
  String get onboardingHowStart => '¿Cómo quieres empezar?';

  @override
  String get onboardingCreateBabyTitle => 'Crear bebé';

  @override
  String get onboardingCreateBabySubtitle =>
      'Configura un nuevo perfil desde cero';

  @override
  String get onboardingScanTitle => 'Escanear bebé';

  @override
  String get onboardingScanSubtitle =>
      'Únete a un bebé ya creado escaneando su código QR';

  @override
  String get onboardingScanDisabled => 'Requiere Firebase para compartir';

  @override
  String get onboardingExitLogin => 'Salir y volver al inicio de sesión';

  @override
  String get onboardingConfigureTitle => 'Configurar bebé';

  @override
  String get onboardingCreateProfileTitle => 'Crear perfil del bebé';

  @override
  String get onboardingCreateProfileSubtitle =>
      'Configura los datos de tu bebé';

  @override
  String get onboardingBabyName => 'Nombre del bebé';

  @override
  String get onboardingBabyNameHint => 'Ej: María, Lucas...';

  @override
  String get onboardingNameRequired => 'El nombre es obligatorio';

  @override
  String get onboardingGender => 'Género';

  @override
  String get onboardingBirthDate => 'Fecha de nacimiento';

  @override
  String get onboardingBirthNote =>
      'Se usa para calcular percentiles OMS (0-12 meses)';

  @override
  String get onboardingHeightTitle => 'Talla / altura';

  @override
  String get onboardingHeightSubtitle =>
      'Opcional. La altura actual en centímetros (aparece en el perfil).';

  @override
  String get onboardingHeightHint => 'Dejar vacío si no la conoces';

  @override
  String get onboardingHeightInvalid => 'Introduce un número válido (ej: 52,5)';

  @override
  String get onboardingHeightRange => 'Altura habitual entre 25 y 130 cm';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get onboardingEnterName => 'Introduce el nombre del bebé';

  @override
  String get onboardingHeightReview =>
      'Revisa la talla: número entre 25 y 130 cm, o deja el campo vacío';

  @override
  String get onboardingSaveDenied =>
      'Sin permiso en Firebase (reglas o sesión). Revisa Firestore.';

  @override
  String onboardingSaveFailed(Object code) {
    return 'No se pudo guardar ($code). Revisa conexión y Firebase.';
  }

  @override
  String onboardingSaveError(Object error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get onboardingExitTitle => '¿Salir?';

  @override
  String get onboardingExitBody =>
      'Cerrarás sesión y volverás a la pantalla de inicio de sesión.';

  @override
  String onboardingSignOutError(Object error) {
    return 'No se pudo cerrar sesión: $error';
  }

  @override
  String get familyQrTitle => 'Escanear código QR';

  @override
  String get familyQrHint => 'Apunta la cámara al código QR del bebé';

  @override
  String get familyQrDetailLabel => 'Detalle:';

  @override
  String get familyQrJoinFailPermission =>
      'Permiso denegado en Firebase (reglas de Firestore o sesión).';

  @override
  String get familyQrJoinFailUnavailable =>
      'Firebase no está disponible. Revisa la conexión a internet.';

  @override
  String get familyQrJoinFailNotFound => 'Recurso no encontrado en Firebase.';

  @override
  String familyQrJoinFailFirebase(Object code) {
    return 'Error de Firebase ($code).';
  }

  @override
  String get familyQrJoinFailFamily =>
      'Familia no encontrada. Comprueba que el QR sea correcto.';

  @override
  String get familyQrJoinFailState => 'Error al procesar el código del QR.';

  @override
  String get familyQrJoinFailUnsupported =>
      'Unirse por QR no está disponible (hace falta Firebase en este dispositivo).';

  @override
  String get familyQrJoinFailGeneric => 'No se pudo unir a la familia.';

  @override
  String get familyQrDecodeFail => 'Fallo al leer o decodificar el código.';

  @override
  String get familyQrInternalCode => 'Código interno:';

  @override
  String get notificationChannelName => 'Próximas tomas';

  @override
  String get notificationChannelDescription =>
      'Aviso cuando llega la hora sugerida de toma';

  @override
  String get notificationNextFeedTitle => 'Próxima toma';

  @override
  String notificationNextFeedBody(Object name) {
    return 'Podría tocar otra toma para $name.';
  }

  @override
  String formatWeightMetricKg(Object kg) {
    return '$kg kg';
  }

  @override
  String formatWeightLbOz(Object lb, Object oz) {
    return '$lb lb $oz oz';
  }

  @override
  String formatVolumeMlOnly(Object ml) {
    return '$ml ml';
  }

  @override
  String formatVolumeFlOzOnly(Object flOz) {
    return '$flOz fl oz';
  }

  @override
  String get unitMlShort => 'ml';

  @override
  String get hintExampleWeightLb => 'Ej: 9,5';

  @override
  String get hintExampleFlOz => 'Ej: 4';

  @override
  String get liquidFieldLabelFlOz => 'Cantidad (fl oz)';

  @override
  String get settingsUnitsTitle => 'Unidades';

  @override
  String get settingsUnitsIntro =>
      'Elige cómo ver e introducir peso y biberón. Los datos se guardan siempre en kg y ml.';

  @override
  String get settingsUnitsWeight => 'Peso';

  @override
  String get settingsUnitsLiquid => 'Líquidos';

  @override
  String get unitSegmentKg => 'kg';

  @override
  String get unitSegmentLbOz => 'lb · oz';

  @override
  String get unitSegmentMl => 'mL';

  @override
  String get unitSegmentFlOz => 'fl oz';
}
