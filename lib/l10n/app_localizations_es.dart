// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Docentia';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCourses => 'Cursos';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navFinance => 'Finanzas';

  @override
  String get back => 'Volver';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get close => 'Cerrar';

  @override
  String get loading => 'Cargando...';

  @override
  String get description => 'Descripción';

  @override
  String get amount => 'Monto';

  @override
  String get category => 'Categoría';

  @override
  String get viewCode => 'Ver código';

  @override
  String get loginTitle => 'Docentia';

  @override
  String get loginSubtitle =>
      'La plataforma inteligente de gestión académica y control de asistencia diseñada para el docente moderno.';

  @override
  String get loginFeature1 => 'Control de Asistencia Rápido';

  @override
  String get loginFeature2 => 'Notificaciones Directas';

  @override
  String get loginFeature3 => 'Métricas y Finanzas Claras';

  @override
  String get continueWithGoogle => 'Continuar con Google Workspace';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get termsNotice =>
      'Al continuar aceptas los Términos de Servicio y Política de Privacidad de Docentia.';

  @override
  String get greetingSubtitle => 'Bienvenido a tu panel de control docente';

  @override
  String get activeCoursesSummary => 'cursos activos';

  @override
  String get activeStudentsSummary => 'alumnos en total';

  @override
  String get activeCoursesCard => 'Cursos Activos';

  @override
  String get studentsCard => 'Alumnos';

  @override
  String get monthlyIncomeCard => 'Ingresos del Mes';

  @override
  String get todaysCoursesTitle => 'Cursos de Hoy';

  @override
  String get newCourseBtn => '+ Nuevo curso';

  @override
  String get noCoursesTodayTitle => 'No hay clases programadas para hoy';

  @override
  String get noCoursesTodayDesc =>
      'Aprovecha este tiempo para preparar tus materiales pedagógicos o revisar calificaciones pendientes.';

  @override
  String get createFirstCourseBtn => 'Crear mi primer curso';

  @override
  String get financeTitle => 'Estadísticas y Finanzas';

  @override
  String get currentMonthTab => 'Mes Actual';

  @override
  String get previousMonthTab => 'Mes Anterior';

  @override
  String get allPeriodTab => 'Todo el Periodo';

  @override
  String get collectedIncome => 'Ingresos Cobrados';

  @override
  String get pendingCollect => 'por cobrar';

  @override
  String get operatingExpenses => 'Gastos Operativos';

  @override
  String get deductibleRecords => 'registros deducibles';

  @override
  String get netProfit => 'Ganancia Neta';

  @override
  String get realtimeBalance => 'Balance en tiempo real';

  @override
  String get financialDistribution => 'Distribución Financiera';

  @override
  String get netMargin => 'Margen neto';

  @override
  String get incomeLabel => 'Ingresos';

  @override
  String get expensesLabel => 'Gastos';

  @override
  String get expenseDetails => 'Detalle de Gastos Registrados';

  @override
  String get addExpenseBtn => 'Registrar Gasto';

  @override
  String get noExpensesPeriod => 'No hay gastos registrados en este periodo.';

  @override
  String get registerExpenseTitle => 'Registrar Gasto del Docente';

  @override
  String get profileTitle => 'Perfil del Profesor';

  @override
  String get personalizationTitle => 'Personalización';

  @override
  String get personalizationDesc =>
      'Selecciona el color principal de la aplicación. Se mantendrán intactos los colores semánticos (asistencia, pagos y alertas).';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageDesc => 'Selecciona el idioma principal de la aplicación.';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get englishLanguage => 'English';

  @override
  String get themeModeTitle => 'Tema Visual';

  @override
  String get themeModeDesc =>
      'Cambia entre modo claro y oscuro para adaptar la visualización a tu entorno.';

  @override
  String get lightMode => 'Claro';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get editProfileData => 'Editar Datos';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get linkedWith => 'Cuenta vinculada con';

  @override
  String get courseDetailTitle => 'Detalle del Curso';

  @override
  String get addStudentBtn => '+ Agregar Alumno';

  @override
  String get attendanceRecordBtn => 'Historial de Asistencia';

  @override
  String get studentListTitle => 'Lista de Alumnos';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterPending => 'Pendientes';

  @override
  String get courseChannelTitle => 'Canal del Curso';

  @override
  String get studentsAndTutorsConnected => 'alumnos y tutores conectados';

  @override
  String get broadcastBtn => 'Difusión';

  @override
  String get editCourseTitle => 'Editar Curso';

  @override
  String get createCourseTitle => 'Crear Nuevo Curso';

  @override
  String get courseNameLabel => 'Nombre del Curso *';

  @override
  String get sessionsLabel => 'Total de Sesiones *';

  @override
  String get maxCapacityLabel => 'Capacidad Máxima *';

  @override
  String get classDaysLabel => 'Días de Clase (al menos 1) *';

  @override
  String get startTimeLabel => 'Hora de Inicio *';

  @override
  String get endTimeLabel => 'Hora de Fin *';

  @override
  String get monthlyCostLabel => 'Costo Mensual (\$) *';

  @override
  String get paymentScheduleLabel => 'Esquema de Cobro Mensual';

  @override
  String get scheduleFirstHalf => 'Primera quincena (Día 1-15)';

  @override
  String get scheduleEndOfMonth => 'Fin de mes (Día 25-30)';

  @override
  String get chooseIconLabel => 'Seleccionar Icono Representativo';

  @override
  String get deleteCourseBtn => 'Eliminar Curso';

  @override
  String get studentDetailTitle => 'Ficha del Alumno';

  @override
  String get tutorInfoTitle => 'Información del Tutor / Apoderado';

  @override
  String get sendWhatsAppBtn => 'Enviar WhatsApp al Tutor';

  @override
  String get attendanceSummaryTitle => 'Resumen de Asistencia';

  @override
  String get monthlyFeesTitle => 'Cuotas y Mensualidades';

  @override
  String get addFeeBtn => '+ Generar Cuota';

  @override
  String get deactivateStudentBtn => 'Dar de Baja al Alumno';

  @override
  String get calendarTitle => 'Calendario de Actividades';

  @override
  String get newEventBtn => '+ Nuevo Evento';

  @override
  String get allFilter => 'Todos';

  @override
  String get classesFilter => 'Clases';

  @override
  String get eventsFilter => 'Eventos';

  @override
  String get paymentsFilter => 'Vencimientos';

  @override
  String get noEventsDay =>
      'No hay eventos o clases programadas para esta fecha.';

  @override
  String get weekdayMonday => 'Lunes';

  @override
  String get weekdayTuesday => 'Martes';

  @override
  String get weekdayWednesday => 'Miércoles';

  @override
  String get weekdayThursday => 'Jueves';

  @override
  String get weekdayFriday => 'Viernes';

  @override
  String get weekdaySaturday => 'Sábado';

  @override
  String get weekdaySunday => 'Domingo';

  @override
  String get summarySubtitle => 'Aquí tienes el resumen de tus cursos.';

  @override
  String get activeCourseSingular => 'curso activo';

  @override
  String get activeCoursePlural => 'cursos activos';

  @override
  String get studentSingular => 'alumno';

  @override
  String get studentPlural => 'alumnos';

  @override
  String get summaryCardStudents => 'Alumnos';

  @override
  String get summaryCardActiveCourses => 'Cursos activos';

  @override
  String get summaryCardIncome => 'Ingresos del mes';

  @override
  String get noCoursesYet => 'Aún no tienes cursos';

  @override
  String get noCoursesYetDesc =>
      'Crea tu primer curso para comenzar a inscribir alumnos y llevar el control.';

  @override
  String get viewAllCourses => 'Ver todos los cursos';

  @override
  String ofTotal(int total) {
    return 'de $total';
  }
}
