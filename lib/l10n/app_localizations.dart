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
    Locale('es')
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Docentia'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navCourses.
  ///
  /// In es, this message translates to:
  /// **'Cursos'**
  String get navCourses;

  /// No description provided for @navCalendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get navCalendar;

  /// No description provided for @navFinance.
  ///
  /// In es, this message translates to:
  /// **'Finanzas'**
  String get navFinance;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @create.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @viewCode.
  ///
  /// In es, this message translates to:
  /// **'Ver código'**
  String get viewCode;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Docentia'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La plataforma inteligente de gestión académica y control de asistencia diseñada para el docente moderno.'**
  String get loginSubtitle;

  /// No description provided for @loginFeature1.
  ///
  /// In es, this message translates to:
  /// **'Control de Asistencia Rápido'**
  String get loginFeature1;

  /// No description provided for @loginFeature2.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones Directas'**
  String get loginFeature2;

  /// No description provided for @loginFeature3.
  ///
  /// In es, this message translates to:
  /// **'Métricas y Finanzas Claras'**
  String get loginFeature3;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google Workspace'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get continueWithApple;

  /// No description provided for @termsNotice.
  ///
  /// In es, this message translates to:
  /// **'Al continuar aceptas los Términos de Servicio y Política de Privacidad de Docentia.'**
  String get termsNotice;

  /// No description provided for @greetingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a tu panel de control docente'**
  String get greetingSubtitle;

  /// No description provided for @activeCoursesSummary.
  ///
  /// In es, this message translates to:
  /// **'cursos activos'**
  String get activeCoursesSummary;

  /// No description provided for @activeStudentsSummary.
  ///
  /// In es, this message translates to:
  /// **'alumnos en total'**
  String get activeStudentsSummary;

  /// No description provided for @activeCoursesCard.
  ///
  /// In es, this message translates to:
  /// **'Cursos Activos'**
  String get activeCoursesCard;

  /// No description provided for @studentsCard.
  ///
  /// In es, this message translates to:
  /// **'Alumnos'**
  String get studentsCard;

  /// No description provided for @monthlyIncomeCard.
  ///
  /// In es, this message translates to:
  /// **'Ingresos del Mes'**
  String get monthlyIncomeCard;

  /// No description provided for @todaysCoursesTitle.
  ///
  /// In es, this message translates to:
  /// **'Cursos de Hoy'**
  String get todaysCoursesTitle;

  /// No description provided for @newCourseBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Nuevo curso'**
  String get newCourseBtn;

  /// No description provided for @noCoursesTodayTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay clases programadas para hoy'**
  String get noCoursesTodayTitle;

  /// No description provided for @noCoursesTodayDesc.
  ///
  /// In es, this message translates to:
  /// **'Aprovecha este tiempo para preparar tus materiales pedagógicos o revisar calificaciones pendientes.'**
  String get noCoursesTodayDesc;

  /// No description provided for @createFirstCourseBtn.
  ///
  /// In es, this message translates to:
  /// **'Crear mi primer curso'**
  String get createFirstCourseBtn;

  /// No description provided for @financeTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas y Finanzas'**
  String get financeTitle;

  /// No description provided for @currentMonthTab.
  ///
  /// In es, this message translates to:
  /// **'Mes Actual'**
  String get currentMonthTab;

  /// No description provided for @previousMonthTab.
  ///
  /// In es, this message translates to:
  /// **'Mes Anterior'**
  String get previousMonthTab;

  /// No description provided for @allPeriodTab.
  ///
  /// In es, this message translates to:
  /// **'Todo el Periodo'**
  String get allPeriodTab;

  /// No description provided for @collectedIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos Cobrados'**
  String get collectedIncome;

  /// No description provided for @pendingCollect.
  ///
  /// In es, this message translates to:
  /// **'por cobrar'**
  String get pendingCollect;

  /// No description provided for @operatingExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos Operativos'**
  String get operatingExpenses;

  /// No description provided for @deductibleRecords.
  ///
  /// In es, this message translates to:
  /// **'registros deducibles'**
  String get deductibleRecords;

  /// No description provided for @netProfit.
  ///
  /// In es, this message translates to:
  /// **'Ganancia Neta'**
  String get netProfit;

  /// No description provided for @realtimeBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance en tiempo real'**
  String get realtimeBalance;

  /// No description provided for @financialDistribution.
  ///
  /// In es, this message translates to:
  /// **'Distribución Financiera'**
  String get financialDistribution;

  /// No description provided for @netMargin.
  ///
  /// In es, this message translates to:
  /// **'Margen neto'**
  String get netMargin;

  /// No description provided for @incomeLabel.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get incomeLabel;

  /// No description provided for @expensesLabel.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expensesLabel;

  /// No description provided for @expenseDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Gastos Registrados'**
  String get expenseDetails;

  /// No description provided for @addExpenseBtn.
  ///
  /// In es, this message translates to:
  /// **'Registrar Gasto'**
  String get addExpenseBtn;

  /// No description provided for @noExpensesPeriod.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos registrados en este periodo.'**
  String get noExpensesPeriod;

  /// No description provided for @registerExpenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar Gasto del Docente'**
  String get registerExpenseTitle;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil del Profesor'**
  String get profileTitle;

  /// No description provided for @personalizationTitle.
  ///
  /// In es, this message translates to:
  /// **'Personalización'**
  String get personalizationTitle;

  /// No description provided for @personalizationDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el color principal de la aplicación. Se mantendrán intactos los colores semánticos (asistencia, pagos y alertas).'**
  String get personalizationDesc;

  /// No description provided for @languageTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// No description provided for @languageDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el idioma principal de la aplicación.'**
  String get languageDesc;

  /// No description provided for @spanishLanguage.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanishLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @themeModeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tema Visual'**
  String get themeModeTitle;

  /// No description provided for @themeModeDesc.
  ///
  /// In es, this message translates to:
  /// **'Cambia entre modo claro y oscuro para adaptar la visualización a tu entorno.'**
  String get themeModeDesc;

  /// No description provided for @lightMode.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get systemMode;

  /// No description provided for @editProfileData.
  ///
  /// In es, this message translates to:
  /// **'Editar Datos'**
  String get editProfileData;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get signOut;

  /// No description provided for @linkedWith.
  ///
  /// In es, this message translates to:
  /// **'Cuenta vinculada con'**
  String get linkedWith;

  /// No description provided for @courseDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle del Curso'**
  String get courseDetailTitle;

  /// No description provided for @addStudentBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Agregar Alumno'**
  String get addStudentBtn;

  /// No description provided for @attendanceRecordBtn.
  ///
  /// In es, this message translates to:
  /// **'Historial de Asistencia'**
  String get attendanceRecordBtn;

  /// No description provided for @studentListTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista de Alumnos'**
  String get studentListTitle;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get filterPending;

  /// No description provided for @courseChannelTitle.
  ///
  /// In es, this message translates to:
  /// **'Canal del Curso'**
  String get courseChannelTitle;

  /// No description provided for @studentsAndTutorsConnected.
  ///
  /// In es, this message translates to:
  /// **'alumnos y tutores conectados'**
  String get studentsAndTutorsConnected;

  /// No description provided for @broadcastBtn.
  ///
  /// In es, this message translates to:
  /// **'Difusión'**
  String get broadcastBtn;

  /// No description provided for @editCourseTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Curso'**
  String get editCourseTitle;

  /// No description provided for @createCourseTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear Nuevo Curso'**
  String get createCourseTitle;

  /// No description provided for @courseNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del Curso *'**
  String get courseNameLabel;

  /// No description provided for @sessionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Total de Sesiones *'**
  String get sessionsLabel;

  /// No description provided for @maxCapacityLabel.
  ///
  /// In es, this message translates to:
  /// **'Capacidad Máxima *'**
  String get maxCapacityLabel;

  /// No description provided for @classDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días de Clase (al menos 1) *'**
  String get classDaysLabel;

  /// No description provided for @startTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de Inicio *'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de Fin *'**
  String get endTimeLabel;

  /// No description provided for @monthlyCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo Mensual (\$) *'**
  String get monthlyCostLabel;

  /// No description provided for @paymentScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Esquema de Cobro Mensual'**
  String get paymentScheduleLabel;

  /// No description provided for @scheduleFirstHalf.
  ///
  /// In es, this message translates to:
  /// **'Primera quincena (Día 1-15)'**
  String get scheduleFirstHalf;

  /// No description provided for @scheduleEndOfMonth.
  ///
  /// In es, this message translates to:
  /// **'Fin de mes (Día 25-30)'**
  String get scheduleEndOfMonth;

  /// No description provided for @chooseIconLabel.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Icono Representativo'**
  String get chooseIconLabel;

  /// No description provided for @deleteCourseBtn.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Curso'**
  String get deleteCourseBtn;

  /// No description provided for @studentDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Ficha del Alumno'**
  String get studentDetailTitle;

  /// No description provided for @tutorInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información del Tutor / Apoderado'**
  String get tutorInfoTitle;

  /// No description provided for @sendWhatsAppBtn.
  ///
  /// In es, this message translates to:
  /// **'Enviar WhatsApp al Tutor'**
  String get sendWhatsAppBtn;

  /// No description provided for @attendanceSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de Asistencia'**
  String get attendanceSummaryTitle;

  /// No description provided for @monthlyFeesTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuotas y Mensualidades'**
  String get monthlyFeesTitle;

  /// No description provided for @addFeeBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Generar Cuota'**
  String get addFeeBtn;

  /// No description provided for @deactivateStudentBtn.
  ///
  /// In es, this message translates to:
  /// **'Dar de Baja al Alumno'**
  String get deactivateStudentBtn;

  /// No description provided for @calendarTitle.
  ///
  /// In es, this message translates to:
  /// **'Calendario de Actividades'**
  String get calendarTitle;

  /// No description provided for @newEventBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Nuevo Evento'**
  String get newEventBtn;

  /// No description provided for @allFilter.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allFilter;

  /// No description provided for @classesFilter.
  ///
  /// In es, this message translates to:
  /// **'Clases'**
  String get classesFilter;

  /// No description provided for @eventsFilter.
  ///
  /// In es, this message translates to:
  /// **'Eventos'**
  String get eventsFilter;

  /// No description provided for @paymentsFilter.
  ///
  /// In es, this message translates to:
  /// **'Vencimientos'**
  String get paymentsFilter;

  /// No description provided for @noEventsDay.
  ///
  /// In es, this message translates to:
  /// **'No hay eventos o clases programadas para esta fecha.'**
  String get noEventsDay;

  /// No description provided for @weekdayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get weekdaySunday;

  /// No description provided for @summarySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aquí tienes el resumen de tus cursos.'**
  String get summarySubtitle;

  /// No description provided for @activeCourseSingular.
  ///
  /// In es, this message translates to:
  /// **'curso activo'**
  String get activeCourseSingular;

  /// No description provided for @activeCoursePlural.
  ///
  /// In es, this message translates to:
  /// **'cursos activos'**
  String get activeCoursePlural;

  /// No description provided for @studentSingular.
  ///
  /// In es, this message translates to:
  /// **'alumno'**
  String get studentSingular;

  /// No description provided for @studentPlural.
  ///
  /// In es, this message translates to:
  /// **'alumnos'**
  String get studentPlural;

  /// No description provided for @summaryCardStudents.
  ///
  /// In es, this message translates to:
  /// **'Alumnos'**
  String get summaryCardStudents;

  /// No description provided for @summaryCardActiveCourses.
  ///
  /// In es, this message translates to:
  /// **'Cursos activos'**
  String get summaryCardActiveCourses;

  /// No description provided for @summaryCardIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos del mes'**
  String get summaryCardIncome;

  /// No description provided for @noCoursesYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes cursos'**
  String get noCoursesYet;

  /// No description provided for @noCoursesYetDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer curso para comenzar a inscribir alumnos y llevar el control.'**
  String get noCoursesYetDesc;

  /// No description provided for @viewAllCourses.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los cursos'**
  String get viewAllCourses;

  /// No description provided for @ofTotal.
  ///
  /// In es, this message translates to:
  /// **'de {total}'**
  String ofTotal(int total);
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
      'that was used.');
}
