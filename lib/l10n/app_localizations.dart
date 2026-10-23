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
    Locale('es'),
    Locale('en')
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

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

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

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(String name);

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
  /// **'Cursos de hoy'**
  String get todaysCoursesTitle;

  /// No description provided for @newCourseBtn.
  ///
  /// In es, this message translates to:
  /// **'Nuevo curso'**
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
  /// **'Todo el período'**
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
  /// **'No hay gastos registrados en este período.'**
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
  /// **'Detalle del curso'**
  String get courseDetailTitle;

  /// No description provided for @addStudentBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Agregar alumno'**
  String get addStudentBtn;

  /// No description provided for @attendanceRecordBtn.
  ///
  /// In es, this message translates to:
  /// **'Historial de asistencia'**
  String get attendanceRecordBtn;

  /// No description provided for @studentListTitle.
  ///
  /// In es, this message translates to:
  /// **'Lista de alumnos'**
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
  /// **'Editar curso'**
  String get editCourseTitle;

  /// No description provided for @createCourseTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear nuevo curso'**
  String get createCourseTitle;

  /// No description provided for @courseNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del curso *'**
  String get courseNameLabel;

  /// No description provided for @sessionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Total de sesiones *'**
  String get sessionsLabel;

  /// No description provided for @maxCapacityLabel.
  ///
  /// In es, this message translates to:
  /// **'Capacidad máxima *'**
  String get maxCapacityLabel;

  /// No description provided for @classDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días de clase (al menos 1) *'**
  String get classDaysLabel;

  /// No description provided for @startTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de inicio *'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de fin *'**
  String get endTimeLabel;

  /// No description provided for @classScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario de clase'**
  String get classScheduleLabel;

  /// No description provided for @monthlyCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo mensual (\$) *'**
  String get monthlyCostLabel;

  /// No description provided for @paymentScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Esquema de cobro mensual'**
  String get paymentScheduleLabel;

  /// No description provided for @scheduleFirstHalf.
  ///
  /// In es, this message translates to:
  /// **'Primera quincena (día 1-15)'**
  String get scheduleFirstHalf;

  /// No description provided for @scheduleEndOfMonth.
  ///
  /// In es, this message translates to:
  /// **'Fin de mes (día 25-30)'**
  String get scheduleEndOfMonth;

  /// No description provided for @chooseIconLabel.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar icono representativo'**
  String get chooseIconLabel;

  /// No description provided for @deleteCourseBtn.
  ///
  /// In es, this message translates to:
  /// **'Eliminar curso'**
  String get deleteCourseBtn;

  /// No description provided for @studentDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Ficha del alumno'**
  String get studentDetailTitle;

  /// No description provided for @tutorInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información del tutor'**
  String get tutorInfoTitle;

  /// No description provided for @sendWhatsAppBtn.
  ///
  /// In es, this message translates to:
  /// **'Enviar WhatsApp al tutor'**
  String get sendWhatsAppBtn;

  /// No description provided for @attendanceSummaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen de asistencia'**
  String get attendanceSummaryTitle;

  /// No description provided for @monthlyFeesTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuotas y mensualidades'**
  String get monthlyFeesTitle;

  /// No description provided for @addFeeBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Generar cuota'**
  String get addFeeBtn;

  /// No description provided for @deactivateStudentBtn.
  ///
  /// In es, this message translates to:
  /// **'Dar de baja al alumno'**
  String get deactivateStudentBtn;

  /// No description provided for @calendarTitle.
  ///
  /// In es, this message translates to:
  /// **'Calendario de actividades'**
  String get calendarTitle;

  /// No description provided for @newEventBtn.
  ///
  /// In es, this message translates to:
  /// **'+ Nuevo evento'**
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

  /// No description provided for @pendingPaymentSingular.
  ///
  /// In es, this message translates to:
  /// **'pago pendiente'**
  String get pendingPaymentSingular;

  /// No description provided for @pendingPaymentPlural.
  ///
  /// In es, this message translates to:
  /// **'pagos pendientes'**
  String get pendingPaymentPlural;

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

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @required.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get required;

  /// No description provided for @errorWithDetail.
  ///
  /// In es, this message translates to:
  /// **'Error: {detail}'**
  String errorWithDetail(String detail);

  /// No description provided for @courseFallback.
  ///
  /// In es, this message translates to:
  /// **'Curso'**
  String get courseFallback;

  /// No description provided for @studentFallback.
  ///
  /// In es, this message translates to:
  /// **'Alumno'**
  String get studentFallback;

  /// No description provided for @teacherFallback.
  ///
  /// In es, this message translates to:
  /// **'Profesor'**
  String get teacherFallback;

  /// No description provided for @yearsOld.
  ///
  /// In es, this message translates to:
  /// **'{age} años'**
  String yearsOld(int age);

  /// No description provided for @duePrefix.
  ///
  /// In es, this message translates to:
  /// **'Vence'**
  String get duePrefix;

  /// No description provided for @paidStatus.
  ///
  /// In es, this message translates to:
  /// **'Pagado'**
  String get paidStatus;

  /// No description provided for @overdueStatus.
  ///
  /// In es, this message translates to:
  /// **'Atrasado'**
  String get overdueStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pendingStatus;

  /// No description provided for @upcomingStatus.
  ///
  /// In es, this message translates to:
  /// **'Próximo a vencer'**
  String get upcomingStatus;

  /// No description provided for @paymentUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Al corriente'**
  String get paymentUpToDate;

  /// No description provided for @noFeeStatus.
  ///
  /// In es, this message translates to:
  /// **'Sin cuota'**
  String get noFeeStatus;

  /// No description provided for @allStudentsCurrent.
  ///
  /// In es, this message translates to:
  /// **'Todos los alumnos están al corriente'**
  String get allStudentsCurrent;

  /// No description provided for @presentStatus.
  ///
  /// In es, this message translates to:
  /// **'Presente'**
  String get presentStatus;

  /// No description provided for @lateStatus.
  ///
  /// In es, this message translates to:
  /// **'Retardo'**
  String get lateStatus;

  /// No description provided for @absentStatus.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get absentStatus;

  /// No description provided for @excusedStatus.
  ///
  /// In es, this message translates to:
  /// **'Justificado'**
  String get excusedStatus;

  /// No description provided for @excusedNoteFallback.
  ///
  /// In es, this message translates to:
  /// **'Justificada'**
  String get excusedNoteFallback;

  /// No description provided for @unmarkedStatus.
  ///
  /// In es, this message translates to:
  /// **'Sin marcar'**
  String get unmarkedStatus;

  /// No description provided for @notRecorded.
  ///
  /// In es, this message translates to:
  /// **'Sin registrar'**
  String get notRecorded;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get register;

  /// No description provided for @perMonth.
  ///
  /// In es, this message translates to:
  /// **'mes'**
  String get perMonth;

  /// No description provided for @enrolledWord.
  ///
  /// In es, this message translates to:
  /// **'inscritos'**
  String get enrolledWord;

  /// No description provided for @appVersion.
  ///
  /// In es, this message translates to:
  /// **'Docentia v1.0.0'**
  String get appVersion;

  /// No description provided for @loginShortSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Plataforma de gestión académica y control de asistencia para docentes.'**
  String get loginShortSubtitle;

  /// No description provided for @continueWithGoogleShort.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogleShort;

  /// No description provided for @termsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Al continuar, aceptas nuestros'**
  String get termsPrefix;

  /// No description provided for @termsLink.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsLink;

  /// No description provided for @privacyLink.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacyLink;

  /// No description provided for @whatsappPhone.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp / Teléfono'**
  String get whatsappPhone;

  /// No description provided for @biography.
  ///
  /// In es, this message translates to:
  /// **'Biografía'**
  String get biography;

  /// No description provided for @myCourses.
  ///
  /// In es, this message translates to:
  /// **'Mis cursos'**
  String get myCourses;

  /// No description provided for @courseFee.
  ///
  /// In es, this message translates to:
  /// **'Cuota del curso'**
  String get courseFee;

  /// No description provided for @noCoursesManageDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer curso para comenzar a gestionar alumnos, asistencias y pagos.'**
  String get noCoursesManageDesc;

  /// No description provided for @selectStartTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar hora de inicio'**
  String get selectStartTime;

  /// No description provided for @selectEndTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar hora de finalización'**
  String get selectEndTime;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona al menos un día de clase.'**
  String get selectAtLeastOneDay;

  /// No description provided for @courseUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Curso \"{name}\" actualizado con éxito'**
  String courseUpdatedSuccess(String name);

  /// No description provided for @courseCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Curso \"{name}\" creado con éxito'**
  String courseCreatedSuccess(String name);

  /// No description provided for @deleteCourseConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este curso?'**
  String get deleteCourseConfirmTitle;

  /// No description provided for @deleteCourseConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Estás a punto de eliminar el curso \"{name}\". Esta acción dará de baja el curso y no podrá deshacerse.'**
  String deleteCourseConfirmBody(String name);

  /// No description provided for @yesDeleteCourse.
  ///
  /// In es, this message translates to:
  /// **'Sí, eliminar curso'**
  String get yesDeleteCourse;

  /// No description provided for @courseDeletedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Curso \"{name}\" eliminado correctamente.'**
  String courseDeletedSuccess(String name);

  /// No description provided for @courseNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Inglés avanzado B2'**
  String get courseNameHint;

  /// No description provided for @courseNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre obligatorio'**
  String get courseNameRequired;

  /// No description provided for @cannotSaveAttendanceNotClassDay.
  ///
  /// In es, this message translates to:
  /// **'No es posible registrar asistencia: Hoy no es día de clase para este curso.'**
  String get cannotSaveAttendanceNotClassDay;

  /// No description provided for @attendanceSaved.
  ///
  /// In es, this message translates to:
  /// **'Asistencia guardada correctamente ({count} presentes)'**
  String attendanceSaved(int count);

  /// No description provided for @courseOptions.
  ///
  /// In es, this message translates to:
  /// **'Opciones del curso'**
  String get courseOptions;

  /// No description provided for @notClassDayBanner.
  ///
  /// In es, this message translates to:
  /// **'Hoy no hay clase. La asistencia solo está disponible los días de clase.'**
  String get notClassDayBanner;

  /// No description provided for @addStudentShort.
  ///
  /// In es, this message translates to:
  /// **'Agregar alumno'**
  String get addStudentShort;

  /// No description provided for @attendanceLog.
  ///
  /// In es, this message translates to:
  /// **'Registro de asistencia'**
  String get attendanceLog;

  /// No description provided for @attendanceStudentOf.
  ///
  /// In es, this message translates to:
  /// **'{current} de {total}'**
  String attendanceStudentOf(int current, int total);

  /// No description provided for @noStudentsForAttendance.
  ///
  /// In es, this message translates to:
  /// **'Agrega alumnos para tomar asistencia.'**
  String get noStudentsForAttendance;

  /// No description provided for @attendanceRollComplete.
  ///
  /// In es, this message translates to:
  /// **'Lista tomada correctamente'**
  String get attendanceRollComplete;

  /// No description provided for @attendanceDaySummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen del día'**
  String get attendanceDaySummary;

  /// No description provided for @allStudentsMarkedToday.
  ///
  /// In es, this message translates to:
  /// **'Todos los alumnos tienen asistencia asignada hoy'**
  String get allStudentsMarkedToday;

  /// No description provided for @noStudentsInCourse.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay alumnos inscritos en este curso'**
  String get noStudentsInCourse;

  /// No description provided for @sessionOf.
  ///
  /// In es, this message translates to:
  /// **'Sesión {current} de {total}'**
  String sessionOf(int current, int total);

  /// No description provided for @todayAttendance.
  ///
  /// In es, this message translates to:
  /// **'Hoy, Asistencia'**
  String get todayAttendance;

  /// No description provided for @enrolledLabel.
  ///
  /// In es, this message translates to:
  /// **'Inscritos'**
  String get enrolledLabel;

  /// No description provided for @activeLabel.
  ///
  /// In es, this message translates to:
  /// **'Activos'**
  String get activeLabel;

  /// No description provided for @courseActiveBadge.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get courseActiveBadge;

  /// No description provided for @presentsLabel.
  ///
  /// In es, this message translates to:
  /// **'Presentes'**
  String get presentsLabel;

  /// No description provided for @latesLabel.
  ///
  /// In es, this message translates to:
  /// **'Retardos'**
  String get latesLabel;

  /// No description provided for @absencesLabel.
  ///
  /// In es, this message translates to:
  /// **'Faltas'**
  String get absencesLabel;

  /// No description provided for @spotsLabel.
  ///
  /// In es, this message translates to:
  /// **'Cupos'**
  String get spotsLabel;

  /// No description provided for @ofCapacity.
  ///
  /// In es, this message translates to:
  /// **'De {capacity}'**
  String ofCapacity(int capacity);

  /// No description provided for @studentRegisteredSuccess.
  ///
  /// In es, this message translates to:
  /// **'Alumno registrado con éxito'**
  String get studentRegisteredSuccess;

  /// No description provided for @addStudentTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar alumno'**
  String get addStudentTitle;

  /// No description provided for @addStudentDesc.
  ///
  /// In es, this message translates to:
  /// **'Ingresa los datos para matricular e inscribir en {course}.'**
  String addStudentDesc(String course);

  /// No description provided for @firstNamesLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombres *'**
  String get firstNamesLabel;

  /// No description provided for @firstNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Camila'**
  String get firstNameHint;

  /// No description provided for @lastNamesLabel.
  ///
  /// In es, this message translates to:
  /// **'Apellidos *'**
  String get lastNamesLabel;

  /// No description provided for @lastNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Morales Díaz'**
  String get lastNameHint;

  /// No description provided for @ageLabel.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get ageLabel;

  /// No description provided for @relationshipLabel.
  ///
  /// In es, this message translates to:
  /// **'Parentesco'**
  String get relationshipLabel;

  /// No description provided for @relationshipMother.
  ///
  /// In es, this message translates to:
  /// **'Madre'**
  String get relationshipMother;

  /// No description provided for @relationshipFather.
  ///
  /// In es, this message translates to:
  /// **'Padre'**
  String get relationshipFather;

  /// No description provided for @relationshipTutor.
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get relationshipTutor;

  /// No description provided for @tutorNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del tutor'**
  String get tutorNameLabel;

  /// No description provided for @tutorNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Patricia Díaz'**
  String get tutorNameHint;

  /// No description provided for @tutorPhoneRequiredLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono móvil (WhatsApp) *'**
  String get tutorPhoneRequiredLabel;

  /// No description provided for @phoneRequiredWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'Teléfono requerido para WhatsApp'**
  String get phoneRequiredWhatsapp;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'tutor@ejemplo.com'**
  String get emailHint;

  /// No description provided for @tutorFallback.
  ///
  /// In es, this message translates to:
  /// **'Tutor'**
  String get tutorFallback;

  /// No description provided for @noTutorPhone.
  ///
  /// In es, this message translates to:
  /// **'El alumno no tiene registrado teléfono de tutor'**
  String get noTutorPhone;

  /// No description provided for @whatsappProgressMessage.
  ///
  /// In es, this message translates to:
  /// **'Hola, {tutor}. Le escribo desde Docentia para informarle sobre el progreso de {student}.'**
  String whatsappProgressMessage(String tutor, String student);

  /// No description provided for @whatsappOpenError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir WhatsApp en este dispositivo'**
  String get whatsappOpenError;

  /// No description provided for @deactivateStudentTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Dar de baja al alumno?'**
  String get deactivateStudentTitle;

  /// No description provided for @deactivateStudentBody.
  ///
  /// In es, this message translates to:
  /// **'El alumno {name} dejará de figurar en la lista activa del curso, pero sus asistencias y pagos se conservarán intactos.'**
  String deactivateStudentBody(String name);

  /// No description provided for @studentDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Alumno dado de baja. Historial conservado.'**
  String get studentDeactivated;

  /// No description provided for @confirmDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Confirmar baja'**
  String get confirmDeactivate;

  /// No description provided for @newMonthlyFee.
  ///
  /// In es, this message translates to:
  /// **'Cuota proporcional'**
  String get newMonthlyFee;

  /// No description provided for @feeConfigHelp.
  ///
  /// In es, this message translates to:
  /// **'Para alumnos que regresan a mitad de ciclo. Se cobra solo los días que faltan hasta el próximo cobro automático.'**
  String get feeConfigHelp;

  /// No description provided for @returnDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de reingreso'**
  String get returnDateLabel;

  /// No description provided for @nextChargeDate.
  ///
  /// In es, this message translates to:
  /// **'Próximo cobro automático'**
  String get nextChargeDate;

  /// No description provided for @remainingDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{days} días restantes'**
  String remainingDaysCount(int days);

  /// No description provided for @proratedBreakdown.
  ///
  /// In es, this message translates to:
  /// **'{remaining} de {cycle} días del ciclo'**
  String proratedBreakdown(int remaining, int cycle);

  /// No description provided for @proratedBadge.
  ///
  /// In es, this message translates to:
  /// **'Proporcional'**
  String get proratedBadge;

  /// No description provided for @proratedOnBillingDay.
  ///
  /// In es, this message translates to:
  /// **'Hoy es el día de cobro de este curso. La cuota mensual se genera sola.'**
  String get proratedOnBillingDay;

  /// No description provided for @proratedFeeCreated.
  ///
  /// In es, this message translates to:
  /// **'Cuota proporcional creada por {days} días.'**
  String proratedFeeCreated(int days);

  /// No description provided for @proratedAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una cuota proporcional hasta el próximo cobro.'**
  String get proratedAlreadyExists;

  /// No description provided for @createProratedFee.
  ///
  /// In es, this message translates to:
  /// **'Crear proporcional'**
  String get createProratedFee;

  /// No description provided for @addProratedFee.
  ///
  /// In es, this message translates to:
  /// **'+ Proporcional'**
  String get addProratedFee;

  /// No description provided for @monthAndYear.
  ///
  /// In es, this message translates to:
  /// **'Mes y año:'**
  String get monthAndYear;

  /// No description provided for @dueDateField.
  ///
  /// In es, this message translates to:
  /// **'Vencimiento:'**
  String get dueDateField;

  /// No description provided for @monthStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio de mes'**
  String get monthStart;

  /// No description provided for @monthStartDay1.
  ///
  /// In es, this message translates to:
  /// **'Día 1 del mes correspondiente'**
  String get monthStartDay1;

  /// No description provided for @monthEnd.
  ///
  /// In es, this message translates to:
  /// **'Fin de mes'**
  String get monthEnd;

  /// No description provided for @monthEndLastDay.
  ///
  /// In es, this message translates to:
  /// **'Último día válido (considera bisiestos)'**
  String get monthEndLastDay;

  /// No description provided for @calculatedDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha calculada:'**
  String get calculatedDate;

  /// No description provided for @amountToCharge.
  ///
  /// In es, this message translates to:
  /// **'Monto a cobrar:'**
  String get amountToCharge;

  /// No description provided for @createFee.
  ///
  /// In es, this message translates to:
  /// **'Crear cuota'**
  String get createFee;

  /// No description provided for @feeCreated.
  ///
  /// In es, this message translates to:
  /// **'Cuota generada correctamente para {period}.'**
  String feeCreated(String period);

  /// No description provided for @feeAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'La cuota de este mes ya está registrada para este alumno y curso.'**
  String get feeAlreadyExists;

  /// No description provided for @modifyDueDate.
  ///
  /// In es, this message translates to:
  /// **'Modificar vencimiento'**
  String get modifyDueDate;

  /// No description provided for @changeDueOption.
  ///
  /// In es, this message translates to:
  /// **'Cambiar opción de vencimiento para la cuota de {period}:'**
  String changeDueOption(String period);

  /// No description provided for @monthStartDay1Short.
  ///
  /// In es, this message translates to:
  /// **'Inicio de mes (Día 1)'**
  String get monthStartDay1Short;

  /// No description provided for @monthEndLastDayShort.
  ///
  /// In es, this message translates to:
  /// **'Fin de mes (Último día)'**
  String get monthEndLastDayShort;

  /// No description provided for @resultingDueDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento resultante: {date}'**
  String resultingDueDate(String date);

  /// No description provided for @dueDateUpdated.
  ///
  /// In es, this message translates to:
  /// **'Vencimiento actualizado a {date}'**
  String dueDateUpdated(String date);

  /// No description provided for @update.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get update;

  /// No description provided for @confirmPayment.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get confirmPayment;

  /// No description provided for @reviewPaymentData.
  ///
  /// In es, this message translates to:
  /// **'Revisa los datos del pago que vas a registrar:'**
  String get reviewPaymentData;

  /// No description provided for @studentColon.
  ///
  /// In es, this message translates to:
  /// **'Alumno:'**
  String get studentColon;

  /// No description provided for @courseColon.
  ///
  /// In es, this message translates to:
  /// **'Curso:'**
  String get courseColon;

  /// No description provided for @monthlyFeeColon.
  ///
  /// In es, this message translates to:
  /// **'Mensualidad:'**
  String get monthlyFeeColon;

  /// No description provided for @feeConceptLabel.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get feeConceptLabel;

  /// No description provided for @monthlyFeeConcept.
  ///
  /// In es, this message translates to:
  /// **'Mensualidad'**
  String get monthlyFeeConcept;

  /// No description provided for @courseMonthlyFee.
  ///
  /// In es, this message translates to:
  /// **'Mensualidad del curso'**
  String get courseMonthlyFee;

  /// No description provided for @periodLabel.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get periodLabel;

  /// No description provided for @paymentDateColon.
  ///
  /// In es, this message translates to:
  /// **'Fecha de pago:'**
  String get paymentDateColon;

  /// No description provided for @amountToPay.
  ///
  /// In es, this message translates to:
  /// **'Monto a pagar:'**
  String get amountToPay;

  /// No description provided for @paymentConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Pago de {amount} confirmado para {student}'**
  String paymentConfirmed(String amount, String student);

  /// No description provided for @studentNotFound.
  ///
  /// In es, this message translates to:
  /// **'Alumno no encontrado'**
  String get studentNotFound;

  /// No description provided for @regularStudent.
  ///
  /// In es, this message translates to:
  /// **'Alumno regular'**
  String get regularStudent;

  /// No description provided for @deactivatedStudent.
  ///
  /// In es, this message translates to:
  /// **'Dado de baja'**
  String get deactivatedStudent;

  /// No description provided for @whatsappTutor.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp al tutor'**
  String get whatsappTutor;

  /// No description provided for @studentAttendance.
  ///
  /// In es, this message translates to:
  /// **'Asistencia del alumno'**
  String get studentAttendance;

  /// No description provided for @realtimeRecord.
  ///
  /// In es, this message translates to:
  /// **'Registro en tiempo real'**
  String get realtimeRecord;

  /// No description provided for @classesLabel.
  ///
  /// In es, this message translates to:
  /// **'Clases'**
  String get classesLabel;

  /// No description provided for @attendancesLabel.
  ///
  /// In es, this message translates to:
  /// **'Asistencias'**
  String get attendancesLabel;

  /// No description provided for @percentageLabel.
  ///
  /// In es, this message translates to:
  /// **'Porcentaje'**
  String get percentageLabel;

  /// No description provided for @metricsError.
  ///
  /// In es, this message translates to:
  /// **'Error al calcular las métricas'**
  String get metricsError;

  /// No description provided for @tutorDataTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos del tutor'**
  String get tutorDataTitle;

  /// No description provided for @editTutorBtn.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editTutorBtn;

  /// No description provided for @editTutorTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar datos del tutor'**
  String get editTutorTitle;

  /// No description provided for @tutorUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Datos del tutor actualizados'**
  String get tutorUpdatedSuccess;

  /// No description provided for @editStudentTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar datos del alumno'**
  String get editStudentTitle;

  /// No description provided for @studentUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Datos del alumno actualizados'**
  String get studentUpdatedSuccess;

  /// No description provided for @emergencyContactTitle.
  ///
  /// In es, this message translates to:
  /// **'Contacto de emergencia'**
  String get emergencyContactTitle;

  /// No description provided for @editEmergencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar contacto de emergencia'**
  String get editEmergencyTitle;

  /// No description provided for @emergencyUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contacto de emergencia actualizado'**
  String get emergencyUpdatedSuccess;

  /// No description provided for @noEmergencyContact.
  ///
  /// In es, this message translates to:
  /// **'Sin contacto de emergencia'**
  String get noEmergencyContact;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @mobilePhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono móvil'**
  String get mobilePhone;

  /// No description provided for @secondaryPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono secundario'**
  String get secondaryPhone;

  /// No description provided for @noFeesYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cuotas emitidas para este alumno.'**
  String get noFeesYet;

  /// No description provided for @generateMonthly.
  ///
  /// In es, this message translates to:
  /// **'Generar mensualidad'**
  String get generateMonthly;

  /// No description provided for @dueOn.
  ///
  /// In es, this message translates to:
  /// **'Vence: {date}'**
  String dueOn(String date);

  /// No description provided for @startShort.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get startShort;

  /// No description provided for @confirmPaymentShort.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get confirmPaymentShort;

  /// No description provided for @sendFeeBtn.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendFeeBtn;

  /// No description provided for @paymentsLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar pagos'**
  String get paymentsLoadError;

  /// No description provided for @swipeMarkHint.
  ///
  /// In es, this message translates to:
  /// **'Desliza: ⟵ Falta | Presente ⟶'**
  String get swipeMarkHint;

  /// No description provided for @swipeCorrectHint.
  ///
  /// In es, this message translates to:
  /// **'Desliza en sentido contrario para corregir'**
  String get swipeCorrectHint;

  /// No description provided for @classDaysOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo días de clase'**
  String get classDaysOnly;

  /// No description provided for @noteTitle.
  ///
  /// In es, this message translates to:
  /// **'Nota / Justificante'**
  String get noteTitle;

  /// No description provided for @noteReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo de falta / observación'**
  String get noteReasonLabel;

  /// No description provided for @noteHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Cita médica, permiso familiar...'**
  String get noteHint;

  /// No description provided for @viewNote.
  ///
  /// In es, this message translates to:
  /// **'Ver nota'**
  String get viewNote;

  /// No description provided for @attendanceHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro de asistencia'**
  String get attendanceHistoryTitle;

  /// No description provided for @noSessionsYet.
  ///
  /// In es, this message translates to:
  /// **'Sin clases registradas aún'**
  String get noSessionsYet;

  /// No description provided for @noSessionsDesc.
  ///
  /// In es, this message translates to:
  /// **'Cuando guardes la asistencia de una clase, su fecha, horario y detalle de alumnos presentes y faltas se conservarán aquí.'**
  String get noSessionsDesc;

  /// No description provided for @historyLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar historial: {detail}'**
  String historyLoadError(String detail);

  /// No description provided for @presentsCount.
  ///
  /// In es, this message translates to:
  /// **'Presentes: {count}'**
  String presentsCount(int count);

  /// No description provided for @latesCount.
  ///
  /// In es, this message translates to:
  /// **'Retardos: {count}'**
  String latesCount(int count);

  /// No description provided for @absencesCount.
  ///
  /// In es, this message translates to:
  /// **'Faltas: {count}'**
  String absencesCount(int count);

  /// No description provided for @presentsHeader.
  ///
  /// In es, this message translates to:
  /// **'Presentes — {count}'**
  String presentsHeader(int count);

  /// No description provided for @noPresentsRecorded.
  ///
  /// In es, this message translates to:
  /// **'Ningún alumno presente registrado'**
  String get noPresentsRecorded;

  /// No description provided for @absencesHeader.
  ///
  /// In es, this message translates to:
  /// **'Faltas — {count}'**
  String absencesHeader(int count);

  /// No description provided for @noAbsences.
  ///
  /// In es, this message translates to:
  /// **'Sin inasistencias en esta clase'**
  String get noAbsences;

  /// No description provided for @financeStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas Financieras'**
  String get financeStatsTitle;

  /// No description provided for @allYearTab.
  ///
  /// In es, this message translates to:
  /// **'Todo el Año'**
  String get allYearTab;

  /// No description provided for @netProfitFormula.
  ///
  /// In es, this message translates to:
  /// **'Ganancia Neta (Ingresos - Gastos)'**
  String get netProfitFormula;

  /// No description provided for @marginLabel.
  ///
  /// In es, this message translates to:
  /// **'Margen: {percent}%'**
  String marginLabel(String percent);

  /// No description provided for @collectedWithAmount.
  ///
  /// In es, this message translates to:
  /// **'Cobrado: {amount}'**
  String collectedWithAmount(String amount);

  /// No description provided for @expensesWithAmount.
  ///
  /// In es, this message translates to:
  /// **'Gastos: {amount}'**
  String expensesWithAmount(String amount);

  /// No description provided for @teacherExpenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos del Docente'**
  String get teacherExpenses;

  /// No description provided for @expenseDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción del gasto'**
  String get expenseDescriptionLabel;

  /// No description provided for @amountDollarLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto (\$)'**
  String get amountDollarLabel;

  /// No description provided for @categoryMaterials.
  ///
  /// In es, this message translates to:
  /// **'Materiales y Libros'**
  String get categoryMaterials;

  /// No description provided for @categorySoftware.
  ///
  /// In es, this message translates to:
  /// **'Software y Licencias'**
  String get categorySoftware;

  /// No description provided for @categorySupplies.
  ///
  /// In es, this message translates to:
  /// **'Insumos de Aula'**
  String get categorySupplies;

  /// No description provided for @categoryTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get categoryTransport;

  /// No description provided for @categoryMisc.
  ///
  /// In es, this message translates to:
  /// **'Varios'**
  String get categoryMisc;

  /// No description provided for @newSchoolEvent.
  ///
  /// In es, this message translates to:
  /// **'Nuevo evento escolar'**
  String get newSchoolEvent;

  /// No description provided for @eventTitleLabel.
  ///
  /// In es, this message translates to:
  /// **'Título del evento *'**
  String get eventTitleLabel;

  /// No description provided for @eventTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Primer examen parcial / Entrega de proyectos'**
  String get eventTitleHint;

  /// No description provided for @activityType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de actividad'**
  String get activityType;

  /// No description provided for @eventTypeExam.
  ///
  /// In es, this message translates to:
  /// **'Examen'**
  String get eventTypeExam;

  /// No description provided for @eventTypeProject.
  ///
  /// In es, this message translates to:
  /// **'Proyecto'**
  String get eventTypeProject;

  /// No description provided for @eventTypeMeeting.
  ///
  /// In es, this message translates to:
  /// **'Reunión de apoderados'**
  String get eventTypeMeeting;

  /// No description provided for @eventTypeHoliday.
  ///
  /// In es, this message translates to:
  /// **'Día festivo'**
  String get eventTypeHoliday;

  /// No description provided for @eventTypeSpecial.
  ///
  /// In es, this message translates to:
  /// **'Especial'**
  String get eventTypeSpecial;

  /// No description provided for @associatedCourse.
  ///
  /// In es, this message translates to:
  /// **'Curso asociado'**
  String get associatedCourse;

  /// No description provided for @allCoursesGeneral.
  ///
  /// In es, this message translates to:
  /// **'General / Todos los cursos'**
  String get allCoursesGeneral;

  /// No description provided for @dateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get timeLabel;

  /// No description provided for @locationLabel.
  ///
  /// In es, this message translates to:
  /// **'Ubicación / salón / enlace (opcional)'**
  String get locationLabel;

  /// No description provided for @locationHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Aula 3B, Laboratorio o Google Meet'**
  String get locationHint;

  /// No description provided for @descriptionInstructionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción / instrucciones *'**
  String get descriptionInstructionsLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Detalles de la actividad, temas a evaluar o materiales requeridos...'**
  String get descriptionHint;

  /// No description provided for @extraEmailsLabel.
  ///
  /// In es, this message translates to:
  /// **'Correos adicionales de tutores (opcional)'**
  String get extraEmailsLabel;

  /// No description provided for @extraEmailsHint.
  ///
  /// In es, this message translates to:
  /// **'apoderado@ejemplo.com, direccion@colegio.edu'**
  String get extraEmailsHint;

  /// No description provided for @eventTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'El título del evento es obligatorio.'**
  String get eventTitleRequired;

  /// No description provided for @eventDescriptionRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa una descripción para el evento.'**
  String get eventDescriptionRequired;

  /// No description provided for @eventSaved.
  ///
  /// In es, this message translates to:
  /// **'Evento \"{title}\" registrado en el calendario'**
  String eventSaved(String title);

  /// No description provided for @saveEvent.
  ///
  /// In es, this message translates to:
  /// **'Guardar evento'**
  String get saveEvent;

  /// No description provided for @sendEventToParents.
  ///
  /// In es, this message translates to:
  /// **'Enviar evento a padres'**
  String get sendEventToParents;

  /// No description provided for @bccPrivacyNotice.
  ///
  /// In es, this message translates to:
  /// **'Se preparará el correo para {count} tutores con copia oculta (CCO) para proteger su privacidad.'**
  String bccPrivacyNotice(int count);

  /// No description provided for @subjectPrefix.
  ///
  /// In es, this message translates to:
  /// **'Asunto:'**
  String get subjectPrefix;

  /// No description provided for @noticeCopied.
  ///
  /// In es, this message translates to:
  /// **'Aviso copiado al portapapeles'**
  String get noticeCopied;

  /// No description provided for @copyText.
  ///
  /// In es, this message translates to:
  /// **'Copiar texto'**
  String get copyText;

  /// No description provided for @openMail.
  ///
  /// In es, this message translates to:
  /// **'Abrir correo'**
  String get openMail;

  /// No description provided for @noMailClient.
  ///
  /// In es, this message translates to:
  /// **'No se encontró cliente de correo instalado. Mensaje copiado.'**
  String get noMailClient;

  /// No description provided for @calendarClassesTitle.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendarClassesTitle;

  /// No description provided for @schoolEvents.
  ///
  /// In es, this message translates to:
  /// **'Eventos escolares'**
  String get schoolEvents;

  /// No description provided for @noSchoolEvents.
  ///
  /// In es, this message translates to:
  /// **'Sin eventos escolares registrados'**
  String get noSchoolEvents;

  /// No description provided for @noSchoolEventsDesc.
  ///
  /// In es, this message translates to:
  /// **'Puedes agregar exámenes, reuniones de apoderados o actividades con el botón \"Nuevo evento\".'**
  String get noSchoolEventsDesc;

  /// No description provided for @createEvent.
  ///
  /// In es, this message translates to:
  /// **'Crear evento'**
  String get createEvent;

  /// No description provided for @coursePaymentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Pagos y cuotas de cursos'**
  String get coursePaymentsTitle;

  /// No description provided for @noDueDatesToday.
  ///
  /// In es, this message translates to:
  /// **'Sin vencimientos de cuotas hoy'**
  String get noDueDatesToday;

  /// No description provided for @noDueDatesDesc.
  ///
  /// In es, this message translates to:
  /// **'No hay pagos con fecha límite programada para este día.'**
  String get noDueDatesDesc;

  /// No description provided for @scheduledClasses.
  ///
  /// In es, this message translates to:
  /// **'Clases programadas'**
  String get scheduledClasses;

  /// No description provided for @noClassesThisDay.
  ///
  /// In es, this message translates to:
  /// **'No hay clases programadas para este día'**
  String get noClassesThisDay;

  /// No description provided for @noClassesThisDayDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona otro día en el calendario semanal para consultar los horarios.'**
  String get noClassesThisDayDesc;

  /// No description provided for @deleteEvent.
  ///
  /// In es, this message translates to:
  /// **'Eliminar evento'**
  String get deleteEvent;

  /// No description provided for @eventDeleted.
  ///
  /// In es, this message translates to:
  /// **'Evento escolar eliminado'**
  String get eventDeleted;

  /// No description provided for @notifyParents.
  ///
  /// In es, this message translates to:
  /// **'Avisar a padres'**
  String get notifyParents;

  /// No description provided for @groupSingular.
  ///
  /// In es, this message translates to:
  /// **'grupo'**
  String get groupSingular;

  /// No description provided for @groupPlural.
  ///
  /// In es, this message translates to:
  /// **'grupos'**
  String get groupPlural;

  /// No description provided for @feeReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio de cuota: {name}'**
  String feeReminder(String name);

  /// No description provided for @feeScheduleLine.
  ///
  /// In es, this message translates to:
  /// **'Fecha de cobro establecida: {schedule} · Cuota: {amount}'**
  String feeScheduleLine(String schedule, String amount);

  /// No description provided for @monthStartRange.
  ///
  /// In es, this message translates to:
  /// **'Inicio de mes (día 1-10)'**
  String get monthStartRange;

  /// No description provided for @monthEndDay30.
  ///
  /// In es, this message translates to:
  /// **'Fin de mes (día 30)'**
  String get monthEndDay30;

  /// No description provided for @attendanceAction.
  ///
  /// In es, this message translates to:
  /// **'Asistencia'**
  String get attendanceAction;

  /// No description provided for @classesTabCount.
  ///
  /// In es, this message translates to:
  /// **'Clases ({count})'**
  String classesTabCount(int count);

  /// No description provided for @eventsTabCount.
  ///
  /// In es, this message translates to:
  /// **'Eventos ({count})'**
  String eventsTabCount(int count);

  /// No description provided for @paymentsTabCount.
  ///
  /// In es, this message translates to:
  /// **'Pagos ({count})'**
  String paymentsTabCount(int count);

  /// No description provided for @schoolNoticeSubject.
  ///
  /// In es, this message translates to:
  /// **'[Docentia] Aviso escolar: {title} ({date})'**
  String schoolNoticeSubject(String title, String date);

  /// No description provided for @schoolNoticeBody.
  ///
  /// In es, this message translates to:
  /// **'Estimados padres de familia y tutores:\n\nPor medio del presente aviso escolar, les informamos de la siguiente actividad programada en Docentia:\n• Evento: {title}\n• Fecha: {date}\n• Horario: {schedule}{location}\n• Descripción: {description}\n\nAgradecemos su valioso apoyo y puntual acompañamiento.\n\nAtentamente,\n{teacher}\nDocentia - Plataforma académica'**
  String schoolNoticeBody(String title, String date, String schedule,
      String location, String description, String teacher);

  /// No description provided for @principalTeacher.
  ///
  /// In es, this message translates to:
  /// **'Profesor titular'**
  String get principalTeacher;

  /// No description provided for @locationLine.
  ///
  /// In es, this message translates to:
  /// **'\n• Ubicación: {place}'**
  String locationLine(String place);

  /// No description provided for @attendancePctShort.
  ///
  /// In es, this message translates to:
  /// **'{percent}% asist.'**
  String attendancePctShort(int percent);

  /// No description provided for @excusedCompact.
  ///
  /// In es, this message translates to:
  /// **'{count} just.'**
  String excusedCompact(int count);

  /// No description provided for @completeProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Personaliza tu cuenta'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no incluye un nombre. Completa tu perfil para continuar.'**
  String get completeProfileSubtitle;

  /// No description provided for @completeProfileNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get completeProfileNameLabel;

  /// No description provided for @completeProfileNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Ana García'**
  String get completeProfileNameHint;

  /// No description provided for @completeProfilePhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono / WhatsApp'**
  String get completeProfilePhoneLabel;

  /// No description provided for @completeProfilePhoneHint.
  ///
  /// In es, this message translates to:
  /// **'+52 55 1234 5678'**
  String get completeProfilePhoneHint;

  /// No description provided for @completeProfileBioLabel.
  ///
  /// In es, this message translates to:
  /// **'Biografía'**
  String get completeProfileBioLabel;

  /// No description provided for @completeProfileBioHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos sobre tu labor docente'**
  String get completeProfileBioHint;

  /// No description provided for @completeProfileContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get completeProfileContinue;

  /// No description provided for @completeProfilePhotoHint.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get completeProfilePhotoHint;

  /// No description provided for @completeProfileNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get completeProfileNameRequired;

  /// No description provided for @completeProfileNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'Usa tu nombre, no un correo'**
  String get completeProfileNameInvalid;

  /// No description provided for @completeProfileGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get completeProfileGallery;

  /// No description provided for @completeProfileCamera.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get completeProfileCamera;

  /// No description provided for @loginWelcomeTagline.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Docentia. El verdadero trabajo lo realizamos nosotros.'**
  String get loginWelcomeTagline;

  /// No description provided for @loginEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginSignIn;

  /// No description provided for @loginOrSeparator.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get loginOrSeparator;

  /// No description provided for @loginEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'El correo no es válido'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'Usa al menos 6 caracteres'**
  String get loginPasswordTooShort;

  /// No description provided for @loginResetEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo para recuperarla'**
  String get loginResetEmailRequired;

  /// No description provided for @loginResetPasswordSent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un correo para restablecer tu contraseña.'**
  String get loginResetPasswordSent;
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
