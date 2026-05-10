import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Mibebé'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'INICIO'**
  String get navHome;

  /// No description provided for @navDiapers.
  ///
  /// In es, this message translates to:
  /// **'PAÑALES'**
  String get navDiapers;

  /// No description provided for @navFeeding.
  ///
  /// In es, this message translates to:
  /// **'ALIMENTACIÓN'**
  String get navFeeding;

  /// No description provided for @navWeight.
  ///
  /// In es, this message translates to:
  /// **'PESO'**
  String get navWeight;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get commonDone;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get commonDelete;

  /// No description provided for @deleteRecordConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este registro?'**
  String get deleteRecordConfirmTitle;

  /// No description provided for @deleteRecordConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Se borrará de forma permanente. Esta acción no se puede deshacer.'**
  String get deleteRecordConfirmBody;

  /// No description provided for @commonEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get commonDate;

  /// No description provided for @commonTime.
  ///
  /// In es, this message translates to:
  /// **'Hora'**
  String get commonTime;

  /// No description provided for @commonTimeStart.
  ///
  /// In es, this message translates to:
  /// **'Hora inicio'**
  String get commonTimeStart;

  /// No description provided for @commonTimeEnd.
  ///
  /// In es, this message translates to:
  /// **'Hora fin'**
  String get commonTimeEnd;

  /// No description provided for @commonGenderBoy.
  ///
  /// In es, this message translates to:
  /// **'Niño'**
  String get commonGenderBoy;

  /// No description provided for @commonGenderGirl.
  ///
  /// In es, this message translates to:
  /// **'Niña'**
  String get commonGenderGirl;

  /// No description provided for @commonSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// No description provided for @commonNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get commonNext;

  /// No description provided for @commonExit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get commonExit;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyTitle;

  /// No description provided for @historyScrollLoadMore.
  ///
  /// In es, this message translates to:
  /// **'Desliza hasta el final para cargar tres días más de historial.'**
  String get historyScrollLoadMore;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @timeSuffixMinute.
  ///
  /// In es, this message translates to:
  /// **'min'**
  String get timeSuffixMinute;

  /// No description provided for @timeSuffixHour.
  ///
  /// In es, this message translates to:
  /// **'h'**
  String get timeSuffixHour;

  /// No description provided for @timeSuffixSecond.
  ///
  /// In es, this message translates to:
  /// **'s'**
  String get timeSuffixSecond;

  /// No description provided for @timeHoursOnly.
  ///
  /// In es, this message translates to:
  /// **'{h}h'**
  String timeHoursOnly(Object h);

  /// No description provided for @timeHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{h}h {m} min'**
  String timeHoursMinutes(Object h, Object m);

  /// No description provided for @timeMinutesOnly.
  ///
  /// In es, this message translates to:
  /// **'{m} min'**
  String timeMinutesOnly(Object m);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In es, this message translates to:
  /// **'{m}m {s}s'**
  String durationMinutesSeconds(Object m, Object s);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{h}h {m}m'**
  String durationHoursMinutes(Object h, Object m);

  /// No description provided for @durationHoursMinutesSeconds.
  ///
  /// In es, this message translates to:
  /// **'{h}h {m}m {s}s'**
  String durationHoursMinutesSeconds(Object h, Object m, Object s);

  /// No description provided for @durationHoursOnly.
  ///
  /// In es, this message translates to:
  /// **'{h}h'**
  String durationHoursOnly(Object h);

  /// No description provided for @feedingIntervalHoursOne.
  ///
  /// In es, this message translates to:
  /// **'1 hora'**
  String get feedingIntervalHoursOne;

  /// No description provided for @feedingIntervalHoursN.
  ///
  /// In es, this message translates to:
  /// **'{n} horas'**
  String feedingIntervalHoursN(Object n);

  /// No description provided for @feedingIntervalHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{h}h {m}min'**
  String feedingIntervalHoursMinutes(Object h, Object m);

  /// No description provided for @profileDefaultBabyName.
  ///
  /// In es, this message translates to:
  /// **'Bebé'**
  String get profileDefaultBabyName;

  /// No description provided for @profileWeightLabel.
  ///
  /// In es, this message translates to:
  /// **'PESO'**
  String get profileWeightLabel;

  /// No description provided for @profileHeightLabel.
  ///
  /// In es, this message translates to:
  /// **'ALTURA'**
  String get profileHeightLabel;

  /// No description provided for @babyAgeMonthsOneDaysOne.
  ///
  /// In es, this message translates to:
  /// **'1 MES, 1 DÍA'**
  String get babyAgeMonthsOneDaysOne;

  /// No description provided for @babyAgeMonthsOneDaysN.
  ///
  /// In es, this message translates to:
  /// **'1 MES, {days} DÍAS'**
  String babyAgeMonthsOneDaysN(Object days);

  /// No description provided for @babyAgeMonthsNDaysOne.
  ///
  /// In es, this message translates to:
  /// **'{months} MESES, 1 DÍA'**
  String babyAgeMonthsNDaysOne(Object months);

  /// No description provided for @babyAgeMonthsNDaysN.
  ///
  /// In es, this message translates to:
  /// **'{months} MESES, {days} DÍAS'**
  String babyAgeMonthsNDaysN(Object days, Object months);

  /// No description provided for @monthiversaryOne.
  ///
  /// In es, this message translates to:
  /// **'¡Hoy cumple 1 mes!'**
  String get monthiversaryOne;

  /// No description provided for @monthiversaryN.
  ///
  /// In es, this message translates to:
  /// **'¡Hoy cumple {months} meses!'**
  String monthiversaryN(Object months);

  /// No description provided for @monthiversarySemanticsHint.
  ///
  /// In es, this message translates to:
  /// **'Pulsa para confeti; hasta dos veces hasta que termine'**
  String get monthiversarySemanticsHint;

  /// No description provided for @homeSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de Hoy'**
  String get homeSummaryTitle;

  /// No description provided for @homeLastFeedLabel.
  ///
  /// In es, this message translates to:
  /// **'ÚLTIMA TOMA'**
  String get homeLastFeedLabel;

  /// No description provided for @homeLastFeedAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {time}'**
  String homeLastFeedAgo(Object time);

  /// No description provided for @homeNextFeedSoon.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma pronto'**
  String get homeNextFeedSoon;

  /// No description provided for @homeNextFeedIn.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma en {time}'**
  String homeNextFeedIn(Object time);

  /// No description provided for @homeNoFeedingsYet.
  ///
  /// In es, this message translates to:
  /// **'Sin tomas registradas aún. Toca para anotar la primera.'**
  String get homeNoFeedingsYet;

  /// No description provided for @homeWeightNoRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay registros de peso. Toca para añadir el primero.'**
  String get homeWeightNoRecords;

  /// No description provided for @homeWeightTrendGramsPerDay.
  ///
  /// In es, this message translates to:
  /// **'{sign}{value} g/día'**
  String homeWeightTrendGramsPerDay(Object sign, Object value);

  /// No description provided for @homeWeightTrendOuncesPerDay.
  ///
  /// In es, this message translates to:
  /// **'{sign}{value} oz/día'**
  String homeWeightTrendOuncesPerDay(Object sign, Object value);

  /// No description provided for @homeWeightLast.
  ///
  /// In es, this message translates to:
  /// **'Último: {date}'**
  String homeWeightLast(Object date);

  /// No description provided for @homeDiapersNoRecords.
  ///
  /// In es, this message translates to:
  /// **'No hay pañales registrados. Toca para añadir el primero.'**
  String get homeDiapersNoRecords;

  /// No description provided for @homeDiapersWetDirty.
  ///
  /// In es, this message translates to:
  /// **'{wet} mojados · {dirty} sucios'**
  String homeDiapersWetDirty(Object dirty, Object wet);

  /// No description provided for @homeDiaperChangesOne.
  ///
  /// In es, this message translates to:
  /// **'1 cambio'**
  String get homeDiaperChangesOne;

  /// No description provided for @homeDiaperChangesN.
  ///
  /// In es, this message translates to:
  /// **'{n} cambios'**
  String homeDiaperChangesN(Object n);

  /// No description provided for @homeTipTitle.
  ///
  /// In es, this message translates to:
  /// **'Consejo del día ✨'**
  String get homeTipTitle;

  /// No description provided for @homeTipFallback.
  ///
  /// In es, this message translates to:
  /// **'Los bebés pueden reconocer la voz de su madre desde el útero. Hablarles con calma refuerza ese vínculo.'**
  String get homeTipFallback;

  /// No description provided for @sabiasQueNoBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Añade la fecha de nacimiento del bebé en ajustes para ver consejos según su edad.'**
  String get sabiasQueNoBirthDate;

  /// No description provided for @homeConfigureProfileFirst.
  ///
  /// In es, this message translates to:
  /// **'Configura primero el perfil del bebé en Ajustes'**
  String get homeConfigureProfileFirst;

  /// No description provided for @homePickPhoto.
  ///
  /// In es, this message translates to:
  /// **'Elegir foto'**
  String get homePickPhoto;

  /// No description provided for @homeRemovePhoto.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto del perfil'**
  String get homeRemovePhoto;

  /// No description provided for @homePhotoRemoved.
  ///
  /// In es, this message translates to:
  /// **'Foto del perfil eliminada'**
  String get homePhotoRemoved;

  /// No description provided for @homePhotoRemoveError.
  ///
  /// In es, this message translates to:
  /// **'Error al quitar la foto: {error}'**
  String homePhotoRemoveError(Object error);

  /// No description provided for @homePhotoUpdated.
  ///
  /// In es, this message translates to:
  /// **'Foto actualizada'**
  String get homePhotoUpdated;

  /// No description provided for @homePhotoUploadError.
  ///
  /// In es, this message translates to:
  /// **'Error al subir la foto: {error}'**
  String homePhotoUploadError(Object error);

  /// No description provided for @feedingTitle.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get feedingTitle;

  /// No description provided for @feedingSessionType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de toma'**
  String get feedingSessionType;

  /// No description provided for @feedingBreast.
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get feedingBreast;

  /// No description provided for @feedingLeft.
  ///
  /// In es, this message translates to:
  /// **'Izquierdo'**
  String get feedingLeft;

  /// No description provided for @feedingRight.
  ///
  /// In es, this message translates to:
  /// **'Derecho'**
  String get feedingRight;

  /// No description provided for @feedingBottle.
  ///
  /// In es, this message translates to:
  /// **'Biberón'**
  String get feedingBottle;

  /// No description provided for @feedingSolidFood.
  ///
  /// In es, this message translates to:
  /// **'Sólidos'**
  String get feedingSolidFood;

  /// No description provided for @solidFoodTitle.
  ///
  /// In es, this message translates to:
  /// **'Alimento sólido'**
  String get solidFoodTitle;

  /// No description provided for @solidFoodNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Qué ha comido'**
  String get solidFoodNameLabel;

  /// No description provided for @solidFoodNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: puré de manzana'**
  String get solidFoodNameHint;

  /// No description provided for @solidFoodQuantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get solidFoodQuantityLabel;

  /// No description provided for @solidFoodUnitGrams.
  ///
  /// In es, this message translates to:
  /// **'g (gramos)'**
  String get solidFoodUnitGrams;

  /// No description provided for @solidFoodUnitUnits.
  ///
  /// In es, this message translates to:
  /// **'u (unidades)'**
  String get solidFoodUnitUnits;

  /// No description provided for @solidFoodUnitGramShort.
  ///
  /// In es, this message translates to:
  /// **'g'**
  String get solidFoodUnitGramShort;

  /// No description provided for @solidFoodUnitUnitsShort.
  ///
  /// In es, this message translates to:
  /// **'u'**
  String get solidFoodUnitUnitsShort;

  /// No description provided for @solidFoodQuantityHintGrams.
  ///
  /// In es, this message translates to:
  /// **'Ej: 40 o 0,47 (coma o punto)'**
  String get solidFoodQuantityHintGrams;

  /// No description provided for @solidFoodQuantityHintUnits.
  ///
  /// In es, this message translates to:
  /// **'Solo número entero, ej: 2'**
  String get solidFoodQuantityHintUnits;

  /// No description provided for @solidFoodValidatorNameEmpty.
  ///
  /// In es, this message translates to:
  /// **'Indica qué ha comido'**
  String get solidFoodValidatorNameEmpty;

  /// No description provided for @solidFoodValidatorQuantityEmpty.
  ///
  /// In es, this message translates to:
  /// **'Indica la cantidad'**
  String get solidFoodValidatorQuantityEmpty;

  /// No description provided for @solidFoodValidatorQuantityInvalid.
  ///
  /// In es, this message translates to:
  /// **'Número entero entre 1 y {max}'**
  String solidFoodValidatorQuantityInvalid(Object max);

  /// No description provided for @solidFoodValidatorQuantityParse.
  ///
  /// In es, this message translates to:
  /// **'Formato no válido: solo números y una coma o punto decimal (ej. 0,47).'**
  String get solidFoodValidatorQuantityParse;

  /// No description provided for @solidFoodValidatorUnitsNoDecimals.
  ///
  /// In es, this message translates to:
  /// **'En unidades usa solo números enteros, sin coma ni punto.'**
  String get solidFoodValidatorUnitsNoDecimals;

  /// No description provided for @solidFoodValidatorGramsPositive.
  ///
  /// In es, this message translates to:
  /// **'El peso en gramos debe ser mayor que 0.'**
  String get solidFoodValidatorGramsPositive;

  /// No description provided for @solidFoodValidatorGramsRange.
  ///
  /// In es, this message translates to:
  /// **'El peso no puede superar {max} g.'**
  String solidFoodValidatorGramsRange(Object max);

  /// No description provided for @feedingChooseSideTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué lado?'**
  String get feedingChooseSideTitle;

  /// No description provided for @feedingChooseSideSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige el pecho para iniciar el cronómetro.'**
  String get feedingChooseSideSubtitle;

  /// No description provided for @feedingEditSolid.
  ///
  /// In es, this message translates to:
  /// **'Editar sólidos'**
  String get feedingEditSolid;

  /// No description provided for @feedingStop.
  ///
  /// In es, this message translates to:
  /// **'Parar'**
  String get feedingStop;

  /// No description provided for @feedingActiveTimer.
  ///
  /// In es, this message translates to:
  /// **'Cronómetro activo: {side}'**
  String feedingActiveTimer(Object side);

  /// No description provided for @feedingSideLeft.
  ///
  /// In es, this message translates to:
  /// **'Izquierdo'**
  String get feedingSideLeft;

  /// No description provided for @feedingSideRight.
  ///
  /// In es, this message translates to:
  /// **'Derecho'**
  String get feedingSideRight;

  /// No description provided for @feedingHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay registros. Usa «Pecho», «Biberón» o «Sólidos» arriba para añadir la primera.'**
  String get feedingHistoryEmpty;

  /// No description provided for @feedingSessionCountOne.
  ///
  /// In es, this message translates to:
  /// **'1 toma'**
  String get feedingSessionCountOne;

  /// No description provided for @feedingSessionCountN.
  ///
  /// In es, this message translates to:
  /// **'{n} tomas'**
  String feedingSessionCountN(Object n);

  /// No description provided for @feedingEditBottle.
  ///
  /// In es, this message translates to:
  /// **'Editar biberón'**
  String get feedingEditBottle;

  /// No description provided for @feedingEditSession.
  ///
  /// In es, this message translates to:
  /// **'Editar toma'**
  String get feedingEditSession;

  /// No description provided for @feedingAmountMl.
  ///
  /// In es, this message translates to:
  /// **'Cantidad (ml)'**
  String get feedingAmountMl;

  /// No description provided for @hintExampleMl.
  ///
  /// In es, this message translates to:
  /// **'Ej: 120'**
  String get hintExampleMl;

  /// No description provided for @feedingStreamError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las tomas. Reintenta o comprueba la conexión.'**
  String get feedingStreamError;

  /// No description provided for @lastFeedDetailLeftMinutes.
  ///
  /// In es, this message translates to:
  /// **'Izquierda • {minutes} min'**
  String lastFeedDetailLeftMinutes(Object minutes);

  /// No description provided for @lastFeedDetailLeft.
  ///
  /// In es, this message translates to:
  /// **'Izquierda'**
  String get lastFeedDetailLeft;

  /// No description provided for @lastFeedDetailRightMinutes.
  ///
  /// In es, this message translates to:
  /// **'Derecha • {minutes} min'**
  String lastFeedDetailRightMinutes(Object minutes);

  /// No description provided for @lastFeedDetailRight.
  ///
  /// In es, this message translates to:
  /// **'Derecha'**
  String get lastFeedDetailRight;

  /// No description provided for @lastFeedDetailBottleVolume.
  ///
  /// In es, this message translates to:
  /// **'Biberón • {volume}'**
  String lastFeedDetailBottleVolume(Object volume);

  /// No description provided for @lastFeedDetailSolid.
  ///
  /// In es, this message translates to:
  /// **'Sólidos'**
  String get lastFeedDetailSolid;

  /// No description provided for @diapersTitle.
  ///
  /// In es, this message translates to:
  /// **'Control de Pañales'**
  String get diapersTitle;

  /// No description provided for @diapersChangeType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de cambio'**
  String get diapersChangeType;

  /// No description provided for @diaperWet.
  ///
  /// In es, this message translates to:
  /// **'Mojado'**
  String get diaperWet;

  /// No description provided for @diaperDirty.
  ///
  /// In es, this message translates to:
  /// **'Sucio'**
  String get diaperDirty;

  /// No description provided for @diaperBoth.
  ///
  /// In es, this message translates to:
  /// **'Ambos'**
  String get diaperBoth;

  /// No description provided for @diapersRegisterButton.
  ///
  /// In es, this message translates to:
  /// **'Registrar Cambio de Pañal'**
  String get diapersRegisterButton;

  /// No description provided for @diapersHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay registros. Usa «Registrar cambio de pañal» arriba para añadir el primero.'**
  String get diapersHistoryEmpty;

  /// No description provided for @diaperChangeCountOne.
  ///
  /// In es, this message translates to:
  /// **'1 cambio'**
  String get diaperChangeCountOne;

  /// No description provided for @diaperChangeCountN.
  ///
  /// In es, this message translates to:
  /// **'{n} cambios'**
  String diaperChangeCountN(Object n);

  /// No description provided for @diapersStreamError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los pañales. Reintenta o comprueba la conexión.'**
  String get diapersStreamError;

  /// No description provided for @diapersEditRecord.
  ///
  /// In es, this message translates to:
  /// **'Editar registro'**
  String get diapersEditRecord;

  /// No description provided for @diapersTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get diapersTypeLabel;

  /// No description provided for @weightTitle.
  ///
  /// In es, this message translates to:
  /// **'Control de Peso'**
  String get weightTitle;

  /// No description provided for @weightFieldLabelMetric.
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get weightFieldLabelMetric;

  /// No description provided for @weightFieldLabelImperial.
  ///
  /// In es, this message translates to:
  /// **'Peso (lb)'**
  String get weightFieldLabelImperial;

  /// No description provided for @hintExampleWeight.
  ///
  /// In es, this message translates to:
  /// **'Ej: 4.5'**
  String get hintExampleWeight;

  /// No description provided for @weightRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get weightRegister;

  /// No description provided for @weightValidatorEmpty.
  ///
  /// In es, this message translates to:
  /// **'Introduce el peso'**
  String get weightValidatorEmpty;

  /// No description provided for @weightValidatorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Peso inválido'**
  String get weightValidatorInvalid;

  /// No description provided for @weightStreamError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los pesos. Comprueba la conexión o reintenta.'**
  String get weightStreamError;

  /// No description provided for @weightEvolution.
  ///
  /// In es, this message translates to:
  /// **'Evolución'**
  String get weightEvolution;

  /// No description provided for @weightChartCaption.
  ///
  /// In es, this message translates to:
  /// **'Línea de referencia peso por edad (OMS).'**
  String get weightChartCaption;

  /// No description provided for @weightChartSource.
  ///
  /// In es, this message translates to:
  /// **'Fuente: Organización Mundial de la Salud (OMS) — Child Growth Standards. who.int/tools/child-growth-standards'**
  String get weightChartSource;

  /// No description provided for @weightChartLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la gráfica de peso.'**
  String get weightChartLoadError;

  /// No description provided for @weightHistoryLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el historial de peso.'**
  String get weightHistoryLoadError;

  /// No description provided for @weightHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay registros. Escribe el peso y pulsa «Registrar» arriba para añadir el primero.'**
  String get weightHistoryEmpty;

  /// No description provided for @weightCurrentCard.
  ///
  /// In es, this message translates to:
  /// **'Peso Actual'**
  String get weightCurrentCard;

  /// No description provided for @weightTrendCard.
  ///
  /// In es, this message translates to:
  /// **'Tendencia diaria'**
  String get weightTrendCard;

  /// No description provided for @weightTrendGramsCompact.
  ///
  /// In es, this message translates to:
  /// **'{sign}{value}g'**
  String weightTrendGramsCompact(Object sign, Object value);

  /// No description provided for @weightTrendOuncesCompact.
  ///
  /// In es, this message translates to:
  /// **'{sign}{value} oz'**
  String weightTrendOuncesCompact(Object sign, Object value);

  /// No description provided for @weightNoData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get weightNoData;

  /// No description provided for @weightDash.
  ///
  /// In es, this message translates to:
  /// **'-'**
  String get weightDash;

  /// No description provided for @weightChartEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin datos aún'**
  String get weightChartEmpty;

  /// No description provided for @weightChartNoDataInRange.
  ///
  /// In es, this message translates to:
  /// **'No hay pesadas en este periodo'**
  String get weightChartNoDataInRange;

  /// No description provided for @weightChartRangeAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get weightChartRangeAll;

  /// No description provided for @weightChartRange7d.
  ///
  /// In es, this message translates to:
  /// **'7 días'**
  String get weightChartRange7d;

  /// No description provided for @weightChartRange30d.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get weightChartRange30d;

  /// No description provided for @weightChartRange90d.
  ///
  /// In es, this message translates to:
  /// **'3 meses'**
  String get weightChartRange90d;

  /// No description provided for @weightChartRange365d.
  ///
  /// In es, this message translates to:
  /// **'1 año'**
  String get weightChartRange365d;

  /// No description provided for @weightTooltipPercentile.
  ///
  /// In es, this message translates to:
  /// **'{label} (OMS): {value}'**
  String weightTooltipPercentile(String label, String value);

  /// No description provided for @weightTooltipWeighIn.
  ///
  /// In es, this message translates to:
  /// **'Pesada: {value}'**
  String weightTooltipWeighIn(Object value);

  /// No description provided for @weightChartPercentileSelector.
  ///
  /// In es, this message translates to:
  /// **'Percentil'**
  String get weightChartPercentileSelector;

  /// No description provided for @weightEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar peso'**
  String get weightEditTitle;

  /// No description provided for @bottleTitle.
  ///
  /// In es, this message translates to:
  /// **'Biberón'**
  String get bottleTitle;

  /// No description provided for @bottleValidatorEmpty.
  ///
  /// In es, this message translates to:
  /// **'Introduce la cantidad'**
  String get bottleValidatorEmpty;

  /// No description provided for @bottleValidatorInvalid.
  ///
  /// In es, this message translates to:
  /// **'Cantidad inválida'**
  String get bottleValidatorInvalid;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsBabyProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil del Bebé'**
  String get settingsBabyProfile;

  /// No description provided for @settingsShareFamily.
  ///
  /// In es, this message translates to:
  /// **'Compartir Familia'**
  String get settingsShareFamily;

  /// No description provided for @settingsSuggestedFeedings.
  ///
  /// In es, this message translates to:
  /// **'Tomas sugeridas'**
  String get settingsSuggestedFeedings;

  /// No description provided for @settingsName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get settingsName;

  /// No description provided for @settingsBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get settingsBirthDate;

  /// No description provided for @settingsHeight.
  ///
  /// In es, this message translates to:
  /// **'Altura'**
  String get settingsHeight;

  /// No description provided for @settingsNoProfile.
  ///
  /// In es, this message translates to:
  /// **'Sin perfil configurado'**
  String get settingsNoProfile;

  /// No description provided for @settingsEditProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get settingsEditProfile;

  /// No description provided for @settingsShareQrIntro.
  ///
  /// In es, this message translates to:
  /// **'Invita a otros miembros de la familia escaneando el código QR.'**
  String get settingsShareQrIntro;

  /// No description provided for @settingsFeedingConfigureFirst.
  ///
  /// In es, this message translates to:
  /// **'Configura primero el perfil del bebé.'**
  String get settingsFeedingConfigureFirst;

  /// No description provided for @settingsFeedingIntro.
  ///
  /// In es, this message translates to:
  /// **'Define cada cuánto suele comer el bebé'**
  String get settingsFeedingIntro;

  /// No description provided for @settingsFeedingInterval.
  ///
  /// In es, this message translates to:
  /// **'Intervalo entre tomas'**
  String get settingsFeedingInterval;

  /// No description provided for @settingsNotifyTitle.
  ///
  /// In es, this message translates to:
  /// **'Activar notificaciones'**
  String get settingsNotifyTitle;

  /// No description provided for @settingsNotifySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones en la hora sugerida de la siguiente toma.'**
  String get settingsNotifySubtitle;

  /// No description provided for @settingsNotifyPermission.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones en los ajustes del sistema para recibir el aviso.'**
  String get settingsNotifyPermission;

  /// No description provided for @settingsSignOutSection.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsSignOutSection;

  /// No description provided for @settingsSignOutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsSignOutButton;

  /// No description provided for @settingsSignOutRowSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión en este dispositivo'**
  String get settingsSignOutRowSubtitle;

  /// No description provided for @settingsDeleteSection.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get settingsDeleteSection;

  /// No description provided for @settingsDeleteIntro.
  ///
  /// In es, this message translates to:
  /// **'Elimina tu cuenta y tus datos de acceso. Si eres el único miembro de la familia, también se eliminarán todos los datos del bebé.'**
  String get settingsDeleteIntro;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountRowSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar la cuenta y sus datos'**
  String get settingsDeleteAccountRowSubtitle;

  /// No description provided for @settingsDeleting.
  ///
  /// In es, this message translates to:
  /// **'Eliminando...'**
  String get settingsDeleting;

  /// No description provided for @settingsFamilyFirebaseOnly.
  ///
  /// In es, this message translates to:
  /// **'Compartir familia solo disponible con Firebase.'**
  String get settingsFamilyFirebaseOnly;

  /// No description provided for @settingsShowQr.
  ///
  /// In es, this message translates to:
  /// **'Mostrar QR para invitar'**
  String get settingsShowQr;

  /// No description provided for @settingsHideQr.
  ///
  /// In es, this message translates to:
  /// **'Ocultar QR'**
  String get settingsHideQr;

  /// No description provided for @settingsQrCaption.
  ///
  /// In es, this message translates to:
  /// **'Escanea para unirte a la familia'**
  String get settingsQrCaption;

  /// No description provided for @settingsGroupBaby.
  ///
  /// In es, this message translates to:
  /// **'Bebé'**
  String get settingsGroupBaby;

  /// No description provided for @settingsGroupPreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get settingsGroupPreferences;

  /// No description provided for @settingsGroupFamily.
  ///
  /// In es, this message translates to:
  /// **'Familia'**
  String get settingsGroupFamily;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get settingsGroupAccount;

  /// No description provided for @settingsRowProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos del perfil'**
  String get settingsRowProfileTitle;

  /// No description provided for @settingsRowProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Nombre, fecha y altura'**
  String get settingsRowProfileSubtitle;

  /// No description provided for @settingsRowProfileEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin configurar'**
  String get settingsRowProfileEmpty;

  /// No description provided for @settingsRowFeedingInterval.
  ///
  /// In es, this message translates to:
  /// **'Intervalo entre tomas'**
  String get settingsRowFeedingInterval;

  /// No description provided for @settingsRowFeedingNotify.
  ///
  /// In es, this message translates to:
  /// **'Avisar próxima toma'**
  String get settingsRowFeedingNotify;

  /// No description provided for @settingsRowUnitWeight.
  ///
  /// In es, this message translates to:
  /// **'Unidad de peso'**
  String get settingsRowUnitWeight;

  /// No description provided for @settingsRowUnitLiquid.
  ///
  /// In es, this message translates to:
  /// **'Unidad de líquidos'**
  String get settingsRowUnitLiquid;

  /// No description provided for @settingsRowFamilyShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir con familia'**
  String get settingsRowFamilyShare;

  /// No description provided for @settingsRowFamilyShareSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrar código QR de invitación'**
  String get settingsRowFamilyShareSubtitle;

  /// No description provided for @settingsValueOn.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get settingsValueOn;

  /// No description provided for @settingsValueOff.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get settingsValueOff;

  /// No description provided for @settingsValueNotSet.
  ///
  /// In es, this message translates to:
  /// **'—'**
  String get settingsValueNotSet;

  /// No description provided for @settingsBabyAgeMonthsOne.
  ///
  /// In es, this message translates to:
  /// **'1 mes'**
  String get settingsBabyAgeMonthsOne;

  /// No description provided for @settingsBabyAgeMonthsN.
  ///
  /// In es, this message translates to:
  /// **'{months} meses'**
  String settingsBabyAgeMonthsN(int months);

  /// No description provided for @settingsBabyAgeDaysOne.
  ///
  /// In es, this message translates to:
  /// **'1 día'**
  String get settingsBabyAgeDaysOne;

  /// No description provided for @settingsBabyAgeDaysN.
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String settingsBabyAgeDaysN(int days);

  /// No description provided for @settingsBabyBornOn.
  ///
  /// In es, this message translates to:
  /// **'Nacido el {date}'**
  String settingsBabyBornOn(String date);

  /// No description provided for @settingsBabyBornOnFemale.
  ///
  /// In es, this message translates to:
  /// **'Nacida el {date}'**
  String settingsBabyBornOnFemale(String date);

  /// No description provided for @settingsSheetUnitWeightTitle.
  ///
  /// In es, this message translates to:
  /// **'Unidad de peso'**
  String get settingsSheetUnitWeightTitle;

  /// No description provided for @settingsSheetUnitLiquidTitle.
  ///
  /// In es, this message translates to:
  /// **'Unidad de líquidos'**
  String get settingsSheetUnitLiquidTitle;

  /// No description provided for @settingsSheetFeedingIntervalTitle.
  ///
  /// In es, this message translates to:
  /// **'Intervalo entre tomas'**
  String get settingsSheetFeedingIntervalTitle;

  /// No description provided for @settingsSheetShareTitle.
  ///
  /// In es, this message translates to:
  /// **'Compartir con familia'**
  String get settingsSheetShareTitle;

  /// No description provided for @editBabyProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil del bebé'**
  String get editBabyProfileTitle;

  /// No description provided for @labelName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get labelName;

  /// No description provided for @labelGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get labelGender;

  /// No description provided for @heightFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Altura (cm)'**
  String get heightFieldLabel;

  /// No description provided for @heightFieldHint.
  ///
  /// In es, this message translates to:
  /// **'Opcional, ej. 58'**
  String get heightFieldHint;

  /// No description provided for @heightInvalid.
  ///
  /// In es, this message translates to:
  /// **'Altura inválida'**
  String get heightInvalid;

  /// No description provided for @heightRangeError.
  ///
  /// In es, this message translates to:
  /// **'Altura debe estar entre 25 y 120 cm'**
  String get heightRangeError;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In es, this message translates to:
  /// **'Esta acción eliminará permanentemente tu cuenta y tus datos de acceso. Si eres el único miembro de la familia, también se eliminarán todos los datos del bebé.\n\nEsta operación no se puede deshacer. ¿Estás seguro?'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar la cuenta: {error}'**
  String deleteAccountError(Object error);

  /// No description provided for @signOutTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOutTitle;

  /// No description provided for @signOutBody.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get signOutBody;

  /// No description provided for @signOutConfirm.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOutConfirm;

  /// No description provided for @signOutError.
  ///
  /// In es, this message translates to:
  /// **'Error al cerrar sesión: {error}'**
  String signOutError(Object error);

  /// No description provided for @loginForgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get loginForgotPasswordTitle;

  /// No description provided for @loginForgotPasswordBody.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace para elegir una contraseña nueva.'**
  String get loginForgotPasswordBody;

  /// No description provided for @loginEmailHint.
  ///
  /// In es, this message translates to:
  /// **'Tu correo electrónico'**
  String get loginEmailHint;

  /// No description provided for @loginResetInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Introduce un correo válido'**
  String get loginResetInvalidEmail;

  /// No description provided for @loginResetCheckEmail.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo (y spam) para restablecer la contraseña'**
  String get loginResetCheckEmail;

  /// No description provided for @loginResetSendFail.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo. Inténtalo más tarde.'**
  String get loginResetSendFail;

  /// No description provided for @loginHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Mibebé'**
  String get loginHeaderTitle;

  /// No description provided for @loginPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotLink.
  ///
  /// In es, this message translates to:
  /// **'¿Has olvidado tu contraseña?'**
  String get loginForgotLink;

  /// No description provided for @loginValidatorEmailEmpty.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu correo'**
  String get loginValidatorEmailEmpty;

  /// No description provided for @loginValidatorEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido'**
  String get loginValidatorEmailInvalid;

  /// No description provided for @loginValidatorPasswordEmpty.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu contraseña'**
  String get loginValidatorPasswordEmpty;

  /// No description provided for @loginSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginSignIn;

  /// No description provided for @loginGuestQr.
  ///
  /// In es, this message translates to:
  /// **'Unirme con código QR (sin cuenta)'**
  String get loginGuestQr;

  /// No description provided for @loginOrWith.
  ///
  /// In es, this message translates to:
  /// **'O INICIA SESIÓN CON'**
  String get loginOrWith;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginRegisterLink;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginErrorGeneric;

  /// No description provided for @loginErrorGoogle.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Google'**
  String get loginErrorGoogle;

  /// No description provided for @loginErrorApple.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Apple'**
  String get loginErrorApple;

  /// No description provided for @loginGuestNeedsFirebase.
  ///
  /// In es, this message translates to:
  /// **'Hace falta Firebase para unirte con código QR'**
  String get loginGuestNeedsFirebase;

  /// No description provided for @loginGuestNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'Invitado no disponible. En Firebase Console → Authentication → Sign-in method, activa \"Anónimo\".'**
  String get loginGuestNotAllowed;

  /// No description provided for @loginGuestFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo entrar como invitado'**
  String get loginGuestFailed;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In es, this message translates to:
  /// **'No existe una cuenta con este correo'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico no válido'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta ha sido deshabilitada'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorInvalidCredential.
  ///
  /// In es, this message translates to:
  /// **'Credenciales inválidas'**
  String get authErrorInvalidCredential;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'Método de inicio de sesión no habilitado'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get authErrorGeneric;

  /// No description provided for @resetErrorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico no válido'**
  String get resetErrorInvalidEmail;

  /// No description provided for @resetErrorUserNotFound.
  ///
  /// In es, this message translates to:
  /// **'No hay cuenta con este correo. Comprueba el email o regístrate.'**
  String get resetErrorUserNotFound;

  /// No description provided for @resetErrorUserDisabled.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta está deshabilitada'**
  String get resetErrorUserDisabled;

  /// No description provided for @resetErrorOpNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'Recuperación por correo no habilitada en Firebase (Authentication → Sign-in method → Email).'**
  String get resetErrorOpNotAllowed;

  /// No description provided for @resetErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo. Inténtalo más tarde.'**
  String get resetErrorGeneric;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro'**
  String get registerTitle;

  /// No description provided for @registerHeadline.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get registerHeadline;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Introduce tus datos para registrarte'**
  String get registerSubtitle;

  /// No description provided for @registerEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get registerEmailLabel;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get registerPasswordLabel;

  /// No description provided for @registerConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get registerConfirmLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get registerPasswordHint;

  /// No description provided for @registerEmailHint.
  ///
  /// In es, this message translates to:
  /// **'tu@email.com'**
  String get registerEmailHint;

  /// No description provided for @registerValidatorEmailEmpty.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu correo'**
  String get registerValidatorEmailEmpty;

  /// No description provided for @registerValidatorPasswordEmpty.
  ///
  /// In es, this message translates to:
  /// **'Introduce una contraseña'**
  String get registerValidatorPasswordEmpty;

  /// No description provided for @registerValidatorPasswordShort.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get registerValidatorPasswordShort;

  /// No description provided for @registerValidatorConfirmEmpty.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get registerValidatorConfirmEmpty;

  /// No description provided for @registerValidatorMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get registerValidatorMismatch;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get registerHaveAccount;

  /// No description provided for @registerSignInLink.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get registerSignInLink;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse. Comprueba tu conexión y que el registro por email esté habilitado en Firebase.'**
  String get registerErrorGeneric;

  /// No description provided for @registerErrorEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con este correo. Usa \"Inicia sesión\" en su lugar.'**
  String get registerErrorEmailInUse;

  /// No description provided for @registerErrorWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get registerErrorWeakPassword;

  /// No description provided for @registerErrorOpNotAllowed.
  ///
  /// In es, this message translates to:
  /// **'Registro por email no habilitado. Actívalo en Firebase Console > Authentication > Sign-in method'**
  String get registerErrorOpNotAllowed;

  /// No description provided for @registerErrorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Comprueba tu internet.'**
  String get registerErrorNetwork;

  /// No description provided for @registerErrorTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera unos minutos.'**
  String get registerErrorTooMany;

  /// No description provided for @registerErrorInvalidCredential.
  ///
  /// In es, this message translates to:
  /// **'Credenciales inválidas'**
  String get registerErrorInvalidCredential;

  /// No description provided for @registerErrorUnknown.
  ///
  /// In es, this message translates to:
  /// **'Error: {code}. Revisa Firebase Console.'**
  String registerErrorUnknown(Object code);

  /// No description provided for @onboardingWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Mibebé'**
  String get onboardingWelcome;

  /// No description provided for @onboardingHowStart.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo quieres empezar?'**
  String get onboardingHowStart;

  /// No description provided for @onboardingCreateBabyTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear bebé'**
  String get onboardingCreateBabyTitle;

  /// No description provided for @onboardingCreateBabySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Configura un nuevo perfil desde cero'**
  String get onboardingCreateBabySubtitle;

  /// No description provided for @onboardingScanTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear bebé'**
  String get onboardingScanTitle;

  /// No description provided for @onboardingScanSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Únete a un bebé ya creado escaneando su código QR'**
  String get onboardingScanSubtitle;

  /// No description provided for @onboardingScanDisabled.
  ///
  /// In es, this message translates to:
  /// **'Requiere Firebase para compartir'**
  String get onboardingScanDisabled;

  /// No description provided for @onboardingExitLogin.
  ///
  /// In es, this message translates to:
  /// **'Salir y volver al inicio de sesión'**
  String get onboardingExitLogin;

  /// No description provided for @onboardingConfigureTitle.
  ///
  /// In es, this message translates to:
  /// **'Configurar bebé'**
  String get onboardingConfigureTitle;

  /// No description provided for @onboardingCreateProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear perfil del bebé'**
  String get onboardingCreateProfileTitle;

  /// No description provided for @onboardingCreateProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Configura los datos de tu bebé'**
  String get onboardingCreateProfileSubtitle;

  /// No description provided for @onboardingBabyName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del bebé'**
  String get onboardingBabyName;

  /// No description provided for @onboardingBabyNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: María, Lucas...'**
  String get onboardingBabyNameHint;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get onboardingGender;

  /// No description provided for @onboardingBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get onboardingBirthDate;

  /// No description provided for @onboardingBirthNote.
  ///
  /// In es, this message translates to:
  /// **'Se usa para calcular percentiles OMS (0-12 meses)'**
  String get onboardingBirthNote;

  /// No description provided for @onboardingHeightTitle.
  ///
  /// In es, this message translates to:
  /// **'Talla / altura'**
  String get onboardingHeightTitle;

  /// No description provided for @onboardingHeightSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Opcional. La altura actual en centímetros (aparece en el perfil).'**
  String get onboardingHeightSubtitle;

  /// No description provided for @onboardingHeightHint.
  ///
  /// In es, this message translates to:
  /// **'Dejar vacío si no la conoces'**
  String get onboardingHeightHint;

  /// No description provided for @onboardingHeightInvalid.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido (ej: 52,5)'**
  String get onboardingHeightInvalid;

  /// No description provided for @onboardingHeightRange.
  ///
  /// In es, this message translates to:
  /// **'Altura habitual entre 25 y 130 cm'**
  String get onboardingHeightRange;

  /// No description provided for @onboardingNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingStart;

  /// No description provided for @onboardingEnterName.
  ///
  /// In es, this message translates to:
  /// **'Introduce el nombre del bebé'**
  String get onboardingEnterName;

  /// No description provided for @onboardingHeightReview.
  ///
  /// In es, this message translates to:
  /// **'Revisa la talla: número entre 25 y 130 cm, o deja el campo vacío'**
  String get onboardingHeightReview;

  /// No description provided for @onboardingSaveDenied.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso en Firebase (reglas o sesión). Revisa Firestore.'**
  String get onboardingSaveDenied;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar ({code}). Revisa conexión y Firebase.'**
  String onboardingSaveFailed(Object code);

  /// No description provided for @onboardingSaveError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar: {error}'**
  String onboardingSaveError(Object error);

  /// No description provided for @onboardingExitTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir?'**
  String get onboardingExitTitle;

  /// No description provided for @onboardingExitBody.
  ///
  /// In es, this message translates to:
  /// **'Cerrarás sesión y volverás a la pantalla de inicio de sesión.'**
  String get onboardingExitBody;

  /// No description provided for @onboardingSignOutError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cerrar sesión: {error}'**
  String onboardingSignOutError(Object error);

  /// No description provided for @familyQrTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear código QR'**
  String get familyQrTitle;

  /// No description provided for @familyQrHint.
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara al código QR del bebé'**
  String get familyQrHint;

  /// No description provided for @familyQrDetailLabel.
  ///
  /// In es, this message translates to:
  /// **'Detalle:'**
  String get familyQrDetailLabel;

  /// No description provided for @familyQrJoinFailPermission.
  ///
  /// In es, this message translates to:
  /// **'Permiso denegado en Firebase (reglas de Firestore o sesión).'**
  String get familyQrJoinFailPermission;

  /// No description provided for @familyQrJoinFailUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Firebase no está disponible. Revisa la conexión a internet.'**
  String get familyQrJoinFailUnavailable;

  /// No description provided for @familyQrJoinFailNotFound.
  ///
  /// In es, this message translates to:
  /// **'Recurso no encontrado en Firebase.'**
  String get familyQrJoinFailNotFound;

  /// No description provided for @familyQrJoinFailFirebase.
  ///
  /// In es, this message translates to:
  /// **'Error de Firebase ({code}).'**
  String familyQrJoinFailFirebase(Object code);

  /// No description provided for @familyQrJoinFailFamily.
  ///
  /// In es, this message translates to:
  /// **'Familia no encontrada. Comprueba que el QR sea correcto.'**
  String get familyQrJoinFailFamily;

  /// No description provided for @familyQrJoinFailState.
  ///
  /// In es, this message translates to:
  /// **'Error al procesar el código del QR.'**
  String get familyQrJoinFailState;

  /// No description provided for @familyQrJoinFailUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Unirse por QR no está disponible (hace falta Firebase en este dispositivo).'**
  String get familyQrJoinFailUnsupported;

  /// No description provided for @familyQrJoinFailGeneric.
  ///
  /// In es, this message translates to:
  /// **'No se pudo unir a la familia.'**
  String get familyQrJoinFailGeneric;

  /// No description provided for @familyQrDecodeFail.
  ///
  /// In es, this message translates to:
  /// **'Fallo al leer o decodificar el código.'**
  String get familyQrDecodeFail;

  /// No description provided for @familyQrInternalCode.
  ///
  /// In es, this message translates to:
  /// **'Código interno:'**
  String get familyQrInternalCode;

  /// No description provided for @notificationChannelName.
  ///
  /// In es, this message translates to:
  /// **'Próximas tomas'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In es, this message translates to:
  /// **'Aviso cuando llega la hora sugerida de toma'**
  String get notificationChannelDescription;

  /// No description provided for @notificationNextFeedTitle.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma'**
  String get notificationNextFeedTitle;

  /// No description provided for @notificationNextFeedBody.
  ///
  /// In es, this message translates to:
  /// **'Podría tocar otra toma para {name}.'**
  String notificationNextFeedBody(Object name);

  /// No description provided for @formatWeightMetricKg.
  ///
  /// In es, this message translates to:
  /// **'{kg} kg'**
  String formatWeightMetricKg(Object kg);

  /// No description provided for @formatWeightLbOz.
  ///
  /// In es, this message translates to:
  /// **'{lb} lb {oz} oz'**
  String formatWeightLbOz(Object lb, Object oz);

  /// No description provided for @formatVolumeMlOnly.
  ///
  /// In es, this message translates to:
  /// **'{ml} ml'**
  String formatVolumeMlOnly(Object ml);

  /// No description provided for @formatVolumeFlOzOnly.
  ///
  /// In es, this message translates to:
  /// **'{flOz} fl oz'**
  String formatVolumeFlOzOnly(Object flOz);

  /// No description provided for @unitMlShort.
  ///
  /// In es, this message translates to:
  /// **'ml'**
  String get unitMlShort;

  /// No description provided for @hintExampleWeightLb.
  ///
  /// In es, this message translates to:
  /// **'Ej: 9,5'**
  String get hintExampleWeightLb;

  /// No description provided for @hintExampleFlOz.
  ///
  /// In es, this message translates to:
  /// **'Ej: 4'**
  String get hintExampleFlOz;

  /// No description provided for @liquidFieldLabelFlOz.
  ///
  /// In es, this message translates to:
  /// **'Cantidad (fl oz)'**
  String get liquidFieldLabelFlOz;

  /// No description provided for @settingsUnitsTitle.
  ///
  /// In es, this message translates to:
  /// **'Unidades'**
  String get settingsUnitsTitle;

  /// No description provided for @settingsUnitsIntro.
  ///
  /// In es, this message translates to:
  /// **'Elige cómo ver e introducir peso y biberón. Los datos se guardan siempre en kg y ml.'**
  String get settingsUnitsIntro;

  /// No description provided for @settingsUnitsWeight.
  ///
  /// In es, this message translates to:
  /// **'Peso'**
  String get settingsUnitsWeight;

  /// No description provided for @settingsUnitsLiquid.
  ///
  /// In es, this message translates to:
  /// **'Líquidos'**
  String get settingsUnitsLiquid;

  /// No description provided for @unitSegmentKg.
  ///
  /// In es, this message translates to:
  /// **'kg'**
  String get unitSegmentKg;

  /// No description provided for @unitSegmentLbOz.
  ///
  /// In es, this message translates to:
  /// **'lb · oz'**
  String get unitSegmentLbOz;

  /// No description provided for @unitSegmentMl.
  ///
  /// In es, this message translates to:
  /// **'mL'**
  String get unitSegmentMl;

  /// No description provided for @unitSegmentFlOz.
  ///
  /// In es, this message translates to:
  /// **'fl oz'**
  String get unitSegmentFlOz;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
