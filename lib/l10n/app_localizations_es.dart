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
  String get navProfile => 'Perfil';

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
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

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
  String get todaysCoursesTitle => 'Cursos de hoy';

  @override
  String get homeShortcutsTitle => 'Accesos rápidos';

  @override
  String get newEventShortcut => 'Nuevo evento';

  @override
  String get recordExpenseShortcut => 'Registrar gasto';

  @override
  String get selectCourseTitle => 'Selecciona un curso';

  @override
  String get createCourseFirst => 'Crea un curso para agregar alumnos';

  @override
  String get homeActivityTitle => 'Tu actividad de hoy';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get feeDueSoonTitle => 'Cuota por vencer';

  @override
  String dueOnDate(String date) {
    return 'Vence el $date';
  }

  @override
  String get homeNoActivityTitle => 'Nada por hoy';

  @override
  String get homeNoActivityDesc =>
      'Cuando tengas clases, eventos o cuotas, aparecerán aquí.';

  @override
  String get newCourseBtn => 'Nuevo curso';

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
  String get allPeriodTab => 'Todo el período';

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
  String get noExpensesPeriod => 'No hay gastos registrados en este período.';

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
  String get courseDetailTitle => 'Detalle del curso';

  @override
  String get addStudentBtn => '+ Agregar alumno';

  @override
  String get attendanceRecordBtn => 'Historial de asistencia';

  @override
  String get studentListTitle => 'Lista de alumnos';

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
  String get editCourseTitle => 'Editar curso';

  @override
  String get createCourseTitle => 'Crear nuevo curso';

  @override
  String get courseNameLabel => 'Nombre del curso *';

  @override
  String get sessionsLabel => 'Total de sesiones *';

  @override
  String get maxCapacityLabel => 'Capacidad máxima *';

  @override
  String get classDaysLabel => 'Días de clase (al menos 1) *';

  @override
  String get startTimeLabel => 'Hora de inicio *';

  @override
  String get endTimeLabel => 'Hora de fin *';

  @override
  String get classScheduleLabel => 'Horario de clase';

  @override
  String get monthlyCostLabel => 'Costo mensual (\$) *';

  @override
  String get paymentScheduleLabel => 'Esquema de cobro mensual';

  @override
  String get scheduleFirstHalf => 'Primera quincena (día 1-15)';

  @override
  String get scheduleEndOfMonth => 'Fin de mes (día 25-30)';

  @override
  String get chooseIconLabel => 'Seleccionar icono representativo';

  @override
  String get deleteCourseBtn => 'Eliminar curso';

  @override
  String get studentDetailTitle => 'Ficha del alumno';

  @override
  String get tutorInfoTitle => 'Información del tutor';

  @override
  String get sendWhatsAppBtn => 'Enviar WhatsApp al tutor';

  @override
  String get attendanceSummaryTitle => 'Resumen de asistencia';

  @override
  String get monthlyFeesTitle => 'Cuotas y mensualidades';

  @override
  String get addFeeBtn => '+ Generar cuota';

  @override
  String get deactivateStudentBtn => 'Dar de baja al alumno';

  @override
  String get calendarTitle => 'Calendario de actividades';

  @override
  String get newEventBtn => '+ Nuevo evento';

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
  String get pendingPaymentSingular => 'pago pendiente';

  @override
  String get pendingPaymentPlural => 'pagos pendientes';

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

  @override
  String get accept => 'Aceptar';

  @override
  String get required => 'Requerido';

  @override
  String errorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String get courseFallback => 'Curso';

  @override
  String get studentFallback => 'Alumno';

  @override
  String get teacherFallback => 'Profesor';

  @override
  String yearsOld(int age) {
    return '$age años';
  }

  @override
  String get duePrefix => 'Vence';

  @override
  String get paidStatus => 'Pagado';

  @override
  String get overdueStatus => 'Atrasado';

  @override
  String get pendingStatus => 'Pendiente';

  @override
  String get upcomingStatus => 'Próximo a vencer';

  @override
  String get paymentUpToDate => 'Al corriente';

  @override
  String get noFeeStatus => 'Sin cuota';

  @override
  String get allStudentsCurrent => 'Todos los alumnos están al corriente';

  @override
  String get presentStatus => 'Presente';

  @override
  String get lateStatus => 'Retardo';

  @override
  String get absentStatus => 'Falta';

  @override
  String get excusedStatus => 'Justificado';

  @override
  String get excusedNoteFallback => 'Justificada';

  @override
  String get unmarkedStatus => 'Sin marcar';

  @override
  String get notRecorded => 'Sin registrar';

  @override
  String get register => 'Registrar';

  @override
  String get perMonth => 'mes';

  @override
  String get enrolledWord => 'inscritos';

  @override
  String get appVersion => 'Docentia v1.0.0';

  @override
  String get loginShortSubtitle =>
      'Plataforma de gestión académica y control de asistencia para docentes.';

  @override
  String get continueWithGoogleShort => 'Continuar con Google';

  @override
  String get termsPrefix => 'Al continuar, aceptas nuestros';

  @override
  String get termsLink => 'Términos y Condiciones';

  @override
  String get privacyLink => 'Política de Privacidad';

  @override
  String get whatsappPhone => 'WhatsApp / Teléfono';

  @override
  String get biography => 'Biografía';

  @override
  String get myCourses => 'Mis cursos';

  @override
  String get courseFee => 'Cuota del curso';

  @override
  String get noCoursesManageDesc =>
      'Crea tu primer curso para comenzar a gestionar alumnos, asistencias y pagos.';

  @override
  String get selectStartTime => 'Seleccionar hora de inicio';

  @override
  String get selectEndTime => 'Seleccionar hora de finalización';

  @override
  String get selectAtLeastOneDay =>
      'Por favor, selecciona al menos un día de clase.';

  @override
  String courseUpdatedSuccess(String name) {
    return 'Curso \"$name\" actualizado con éxito';
  }

  @override
  String courseCreatedSuccess(String name) {
    return 'Curso \"$name\" creado con éxito';
  }

  @override
  String get deleteCourseConfirmTitle => '¿Eliminar este curso?';

  @override
  String deleteCourseConfirmBody(String name) {
    return 'Estás a punto de eliminar el curso \"$name\". Esta acción dará de baja el curso y no podrá deshacerse.';
  }

  @override
  String get yesDeleteCourse => 'Sí, eliminar curso';

  @override
  String courseDeletedSuccess(String name) {
    return 'Curso \"$name\" eliminado correctamente.';
  }

  @override
  String get courseNameHint => 'Ej. Inglés avanzado B2';

  @override
  String get courseNameRequired => 'Nombre obligatorio';

  @override
  String get cannotSaveAttendanceNotClassDay =>
      'No es posible registrar asistencia: Hoy no es día de clase para este curso.';

  @override
  String attendanceSaved(int count) {
    return 'Asistencia guardada correctamente ($count presentes)';
  }

  @override
  String get courseOptions => 'Opciones del curso';

  @override
  String get notClassDayBanner =>
      'Hoy no hay clase. La asistencia solo está disponible los días de clase.';

  @override
  String get addStudentShort => 'Agregar alumno';

  @override
  String get attendanceLog => 'Registro de asistencia';

  @override
  String attendanceStudentOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get noStudentsForAttendance => 'Agrega alumnos para tomar asistencia.';

  @override
  String get attendanceRollComplete => 'Lista tomada correctamente';

  @override
  String get attendanceDaySummary => 'Resumen del día';

  @override
  String get allStudentsMarkedToday =>
      'Todos los alumnos tienen asistencia asignada hoy';

  @override
  String get noStudentsInCourse => 'Aún no hay alumnos inscritos en este curso';

  @override
  String sessionOf(int current, int total) {
    return 'Sesión $current de $total';
  }

  @override
  String get todayAttendance => 'Hoy, Asistencia';

  @override
  String get enrolledLabel => 'Inscritos';

  @override
  String get activeLabel => 'Activos';

  @override
  String get courseActiveBadge => 'Activo';

  @override
  String get presentsLabel => 'Presentes';

  @override
  String get latesLabel => 'Retardos';

  @override
  String get absencesLabel => 'Faltas';

  @override
  String get spotsLabel => 'Cupos';

  @override
  String ofCapacity(int capacity) {
    return 'De $capacity';
  }

  @override
  String get studentRegisteredSuccess => 'Alumno registrado con éxito';

  @override
  String get addStudentTitle => 'Agregar alumno';

  @override
  String addStudentDesc(String course) {
    return 'Ingresa los datos para matricular e inscribir en $course.';
  }

  @override
  String get firstNamesLabel => 'Nombres *';

  @override
  String get firstNameHint => 'Ej. Camila';

  @override
  String get lastNamesLabel => 'Apellidos *';

  @override
  String get lastNameHint => 'Ej. Morales Díaz';

  @override
  String get ageLabel => 'Edad';

  @override
  String get relationshipLabel => 'Parentesco';

  @override
  String get relationshipMother => 'Madre';

  @override
  String get relationshipFather => 'Padre';

  @override
  String get relationshipTutor => 'Tutor';

  @override
  String get tutorNameLabel => 'Nombre del tutor';

  @override
  String get tutorNameHint => 'Ej. Patricia Díaz';

  @override
  String get tutorPhoneRequiredLabel => 'Teléfono móvil (WhatsApp) *';

  @override
  String get phoneRequiredWhatsapp => 'Teléfono requerido para WhatsApp';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'tutor@ejemplo.com';

  @override
  String get tutorFallback => 'Tutor';

  @override
  String get noTutorPhone => 'El alumno no tiene registrado teléfono de tutor';

  @override
  String whatsappProgressMessage(String tutor, String student) {
    return 'Hola, $tutor. Le escribo desde Docentia para informarle sobre el progreso de $student.';
  }

  @override
  String get whatsappOpenError =>
      'No se pudo abrir WhatsApp en este dispositivo';

  @override
  String get deactivateStudentTitle => '¿Dar de baja al alumno?';

  @override
  String deactivateStudentBody(String name) {
    return 'El alumno $name dejará de figurar en la lista activa del curso, pero sus asistencias y pagos se conservarán intactos.';
  }

  @override
  String get studentDeactivated => 'Alumno dado de baja. Historial conservado.';

  @override
  String get confirmDeactivate => 'Confirmar baja';

  @override
  String get newMonthlyFee => 'Cuota proporcional';

  @override
  String get feeConfigHelp =>
      'Para alumnos que regresan a mitad de ciclo. Se cobra solo los días que faltan hasta el próximo cobro automático.';

  @override
  String get returnDateLabel => 'Fecha de reingreso';

  @override
  String get nextChargeDate => 'Próximo cobro automático';

  @override
  String remainingDaysCount(int days) {
    return '$days días restantes';
  }

  @override
  String proratedBreakdown(int remaining, int cycle) {
    return '$remaining de $cycle días del ciclo';
  }

  @override
  String get proratedBadge => 'Proporcional';

  @override
  String get proratedOnBillingDay =>
      'Hoy es el día de cobro de este curso. La cuota mensual se genera sola.';

  @override
  String proratedFeeCreated(int days) {
    return 'Cuota proporcional creada por $days días.';
  }

  @override
  String get proratedAlreadyExists =>
      'Ya hay una cuota proporcional hasta el próximo cobro.';

  @override
  String get createProratedFee => 'Crear proporcional';

  @override
  String get addProratedFee => 'Proporcional';

  @override
  String get monthAndYear => 'Mes y año:';

  @override
  String get dueDateField => 'Vencimiento:';

  @override
  String get monthStart => 'Inicio de mes';

  @override
  String get monthStartDay1 => 'Día 1 del mes correspondiente';

  @override
  String get monthEnd => 'Fin de mes';

  @override
  String get monthEndLastDay => 'Último día válido (considera bisiestos)';

  @override
  String get calculatedDate => 'Fecha calculada:';

  @override
  String get amountToCharge => 'Monto a cobrar:';

  @override
  String get createFee => 'Crear cuota';

  @override
  String feeCreated(String period) {
    return 'Cuota generada correctamente para $period.';
  }

  @override
  String get feeAlreadyExists =>
      'La cuota de este mes ya está registrada para este alumno y curso.';

  @override
  String get modifyDueDate => 'Modificar vencimiento';

  @override
  String changeDueOption(String period) {
    return 'Cambiar opción de vencimiento para la cuota de $period:';
  }

  @override
  String get monthStartDay1Short => 'Inicio de mes (Día 1)';

  @override
  String get monthEndLastDayShort => 'Fin de mes (Último día)';

  @override
  String resultingDueDate(String date) {
    return 'Fecha de vencimiento resultante: $date';
  }

  @override
  String dueDateUpdated(String date) {
    return 'Vencimiento actualizado a $date';
  }

  @override
  String get update => 'Actualizar';

  @override
  String get confirmPayment => 'Confirmar pago';

  @override
  String get reviewPaymentData =>
      'Revisa los datos del pago que vas a registrar:';

  @override
  String get studentColon => 'Alumno:';

  @override
  String get courseColon => 'Curso:';

  @override
  String get monthlyFeeColon => 'Mensualidad:';

  @override
  String get feeConceptLabel => 'Concepto';

  @override
  String get monthlyFeeConcept => 'Mensualidad';

  @override
  String get courseMonthlyFee => 'Mensualidad del curso';

  @override
  String get periodLabel => 'Periodo';

  @override
  String get paymentDateColon => 'Fecha de pago:';

  @override
  String get amountToPay => 'Monto a pagar:';

  @override
  String paymentConfirmed(String amount, String student) {
    return 'Pago de $amount confirmado para $student';
  }

  @override
  String get studentNotFound => 'Alumno no encontrado';

  @override
  String get regularStudent => 'Alumno regular';

  @override
  String get deactivatedStudent => 'Dado de baja';

  @override
  String get whatsappTutor => 'WhatsApp al tutor';

  @override
  String get studentAttendance => 'Asistencia del alumno';

  @override
  String get realtimeRecord => 'Registro en tiempo real';

  @override
  String get classesLabel => 'Clases';

  @override
  String get attendancesLabel => 'Asistencias';

  @override
  String get percentageLabel => 'Porcentaje';

  @override
  String get metricsError => 'Error al calcular las métricas';

  @override
  String get tutorDataTitle => 'Datos del tutor';

  @override
  String get editTutorBtn => 'Editar';

  @override
  String get editTutorTitle => 'Editar datos del tutor';

  @override
  String get tutorUpdatedSuccess => 'Datos del tutor actualizados';

  @override
  String get editStudentTitle => 'Editar datos del alumno';

  @override
  String get studentUpdatedSuccess => 'Datos del alumno actualizados';

  @override
  String get emergencyContactTitle => 'Contacto de emergencia';

  @override
  String get editEmergencyTitle => 'Editar contacto de emergencia';

  @override
  String get emergencyUpdatedSuccess => 'Contacto de emergencia actualizado';

  @override
  String get noEmergencyContact => 'Sin contacto de emergencia';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get mobilePhone => 'Teléfono móvil';

  @override
  String get secondaryPhone => 'Teléfono secundario';

  @override
  String get noFeesYet => 'Aún no hay cuotas emitidas para este alumno.';

  @override
  String get generateMonthly => 'Generar mensualidad';

  @override
  String dueOn(String date) {
    return 'Vence: $date';
  }

  @override
  String get startShort => 'Inicio';

  @override
  String get confirmPaymentShort => 'Confirmar pago';

  @override
  String get sendFeeBtn => 'Enviar';

  @override
  String get paymentsLoadError => 'Error al cargar pagos';

  @override
  String get swipeMarkHint => 'Desliza: ⟵ Falta | Presente ⟶';

  @override
  String get swipeCorrectHint => 'Desliza en sentido contrario para corregir';

  @override
  String get classDaysOnly => 'Solo días de clase';

  @override
  String get noteTitle => 'Nota / Justificante';

  @override
  String get noteReasonLabel => 'Motivo de falta / observación';

  @override
  String get noteHint => 'Ej. Cita médica, permiso familiar...';

  @override
  String get viewNote => 'Ver nota';

  @override
  String get attendanceHistoryTitle => 'Registro de asistencia';

  @override
  String get noSessionsYet => 'Sin clases registradas aún';

  @override
  String get noSessionsDesc =>
      'Cuando guardes la asistencia de una clase, su fecha, horario y detalle de alumnos presentes y faltas se conservarán aquí.';

  @override
  String historyLoadError(String detail) {
    return 'Error al cargar historial: $detail';
  }

  @override
  String presentsCount(int count) {
    return 'Presentes: $count';
  }

  @override
  String latesCount(int count) {
    return 'Retardos: $count';
  }

  @override
  String absencesCount(int count) {
    return 'Faltas: $count';
  }

  @override
  String presentsHeader(int count) {
    return 'Presentes — $count';
  }

  @override
  String get noPresentsRecorded => 'Ningún alumno presente registrado';

  @override
  String absencesHeader(int count) {
    return 'Faltas — $count';
  }

  @override
  String get noAbsences => 'Sin inasistencias en esta clase';

  @override
  String get financeStatsTitle => 'Estadísticas Financieras';

  @override
  String get allYearTab => 'Todo el Año';

  @override
  String get netProfitFormula => 'Ganancia Neta (Ingresos - Gastos)';

  @override
  String marginLabel(String percent) {
    return 'Margen: $percent%';
  }

  @override
  String collectedWithAmount(String amount) {
    return 'Cobrado: $amount';
  }

  @override
  String expensesWithAmount(String amount) {
    return 'Gastos: $amount';
  }

  @override
  String get teacherExpenses => 'Gastos del Docente';

  @override
  String get expenseDescriptionLabel => 'Descripción del gasto';

  @override
  String get amountDollarLabel => 'Monto (\$)';

  @override
  String get categoryMaterials => 'Materiales y Libros';

  @override
  String get categorySoftware => 'Software y Licencias';

  @override
  String get categorySupplies => 'Insumos de Aula';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryMisc => 'Varios';

  @override
  String get newSchoolEvent => 'Nuevo evento escolar';

  @override
  String get eventTitleLabel => 'Título del evento *';

  @override
  String get eventTitleHint =>
      'Ej. Primer examen parcial / Entrega de proyectos';

  @override
  String get activityType => 'Tipo de actividad';

  @override
  String get eventTypeExam => 'Examen';

  @override
  String get eventTypeProject => 'Proyecto';

  @override
  String get eventTypeMeeting => 'Reunión de apoderados';

  @override
  String get eventTypeHoliday => 'Día festivo';

  @override
  String get eventTypeSpecial => 'Especial';

  @override
  String get associatedCourse => 'Curso asociado';

  @override
  String get allCoursesGeneral => 'General / Todos los cursos';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get timeLabel => 'Horario';

  @override
  String get locationLabel => 'Ubicación / salón / enlace (opcional)';

  @override
  String get locationHint => 'Ej. Aula 3B, Laboratorio o Google Meet';

  @override
  String get descriptionInstructionsLabel => 'Descripción / instrucciones *';

  @override
  String get descriptionHint =>
      'Detalles de la actividad, temas a evaluar o materiales requeridos...';

  @override
  String get extraEmailsLabel => 'Correos adicionales de tutores (opcional)';

  @override
  String get extraEmailsHint => 'apoderado@ejemplo.com, direccion@colegio.edu';

  @override
  String get eventTitleRequired => 'El título del evento es obligatorio.';

  @override
  String get eventDescriptionRequired =>
      'Por favor ingresa una descripción para el evento.';

  @override
  String eventSaved(String title) {
    return 'Evento \"$title\" registrado en el calendario';
  }

  @override
  String get saveEvent => 'Guardar evento';

  @override
  String get sendEventToParents => 'Enviar evento a padres';

  @override
  String bccPrivacyNotice(int count) {
    return 'Se preparará el correo para $count tutores con copia oculta (CCO) para proteger su privacidad.';
  }

  @override
  String get subjectPrefix => 'Asunto:';

  @override
  String get noticeCopied => 'Aviso copiado al portapapeles';

  @override
  String get copyText => 'Copiar texto';

  @override
  String get openMail => 'Abrir correo';

  @override
  String get noMailClient =>
      'No se encontró cliente de correo instalado. Mensaje copiado.';

  @override
  String get calendarClassesTitle => 'Calendario';

  @override
  String get schoolEvents => 'Eventos escolares';

  @override
  String get noSchoolEvents => 'Sin eventos escolares registrados';

  @override
  String get noSchoolEventsDesc =>
      'Puedes agregar exámenes, reuniones de apoderados o actividades con el botón \"Nuevo evento\".';

  @override
  String get createEvent => 'Crear evento';

  @override
  String get coursePaymentsTitle => 'Pagos y cuotas de cursos';

  @override
  String get noDueDatesToday => 'Sin vencimientos de cuotas hoy';

  @override
  String get noDueDatesDesc =>
      'No hay pagos con fecha límite programada para este día.';

  @override
  String get scheduledClasses => 'Clases programadas';

  @override
  String get noClassesThisDay => 'No hay clases programadas para este día';

  @override
  String get noClassesThisDayDesc =>
      'Selecciona otro día en el calendario semanal para consultar los horarios.';

  @override
  String get deleteEvent => 'Eliminar evento';

  @override
  String get eventDeleted => 'Evento escolar eliminado';

  @override
  String get notifyParents => 'Avisar a padres';

  @override
  String get groupSingular => 'grupo';

  @override
  String get groupPlural => 'grupos';

  @override
  String feeReminder(String name) {
    return 'Recordatorio de cuota: $name';
  }

  @override
  String feeScheduleLine(String schedule, String amount) {
    return 'Fecha de cobro establecida: $schedule · Cuota: $amount';
  }

  @override
  String get monthStartRange => 'Inicio de mes (día 1-10)';

  @override
  String get monthEndDay30 => 'Fin de mes (día 30)';

  @override
  String get attendanceAction => 'Asistencia';

  @override
  String classesTabCount(int count) {
    return 'Clases ($count)';
  }

  @override
  String eventsTabCount(int count) {
    return 'Eventos ($count)';
  }

  @override
  String paymentsTabCount(int count) {
    return 'Pagos ($count)';
  }

  @override
  String schoolNoticeSubject(String title, String date) {
    return '[Docentia] Aviso escolar: $title ($date)';
  }

  @override
  String schoolNoticeBody(String title, String date, String schedule,
      String location, String description, String teacher) {
    return 'Estimados padres de familia y tutores:\n\nPor medio del presente aviso escolar, les informamos de la siguiente actividad programada en Docentia:\n• Evento: $title\n• Fecha: $date\n• Horario: $schedule$location\n• Descripción: $description\n\nAgradecemos su valioso apoyo y puntual acompañamiento.\n\nAtentamente,\n$teacher\nDocentia - Plataforma académica';
  }

  @override
  String get principalTeacher => 'Profesor titular';

  @override
  String locationLine(String place) {
    return '\n• Ubicación: $place';
  }

  @override
  String attendancePctShort(int percent) {
    return '$percent% asist.';
  }

  @override
  String excusedCompact(int count) {
    return '$count just.';
  }

  @override
  String get completeProfileTitle => 'Personaliza tu cuenta';

  @override
  String get completeProfileSubtitle =>
      'Tu cuenta no incluye un nombre. Completa tu perfil para continuar.';

  @override
  String get completeProfileNameLabel => 'Nombre *';

  @override
  String get completeProfileNameHint => 'Ej. Ana García';

  @override
  String get completeProfilePhoneLabel => 'Teléfono / WhatsApp';

  @override
  String get completeProfilePhoneHint => '+52 55 1234 5678';

  @override
  String get completeProfileBioLabel => 'Biografía';

  @override
  String get completeProfileBioHint => 'Cuéntanos sobre tu labor docente';

  @override
  String get completeProfileContinue => 'Continuar';

  @override
  String get completeProfilePhotoHint => 'Agregar foto';

  @override
  String get completeProfileNameRequired => 'Ingresa tu nombre';

  @override
  String get completeProfileNameInvalid => 'Usa tu nombre, no un correo';

  @override
  String get completeProfileGallery => 'Elegir de la galería';

  @override
  String get completeProfileCamera => 'Tomar foto';

  @override
  String get loginWelcomeTagline =>
      'Bienvenido a Docentia. El verdadero trabajo lo realizamos nosotros.';

  @override
  String get loginEmailLabel => 'Correo';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSignIn => 'Iniciar sesión';

  @override
  String get loginOrSeparator => 'o';

  @override
  String get loginEmailRequired => 'Ingresa tu correo';

  @override
  String get loginEmailInvalid => 'El correo no es válido';

  @override
  String get loginPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get loginPasswordTooShort => 'Usa al menos 6 caracteres';

  @override
  String get loginResetEmailRequired => 'Escribe tu correo para recuperarla';

  @override
  String get loginResetPasswordSent =>
      'Te enviamos un correo para restablecer tu contraseña.';

  @override
  String get financeScreenSubtitle => 'Control de cuotas y cobros.';

  @override
  String get financeCollected => 'Cobrado';

  @override
  String get financeToCollect => 'Por cobrar';

  @override
  String get financeOverdue => 'Vencido';

  @override
  String get financeUpcoming => 'Próximos';

  @override
  String get financeUpcomingBadge => 'Próximo';

  @override
  String get financeFeeSingular => 'cuota';

  @override
  String get financeFeePlural => 'cuotas';

  @override
  String get financeQuickAccess => 'Accesos rápidos';

  @override
  String get financeRegisterPayment => 'Registrar pago';

  @override
  String get financeReminders => 'Recordatorios';

  @override
  String get financeReports => 'Reportes';

  @override
  String get financeUpcomingDues => 'Próximos vencimientos';

  @override
  String get financeSeeAll => 'Ver todos';

  @override
  String get financeSearchHint => 'Buscar alumno o curso...';

  @override
  String get financeFilterPending => 'Pendientes';

  @override
  String get financeFilterOverdue => 'Vencidos';

  @override
  String get financeFilterPaid => 'Pagados';

  @override
  String get financePaymentDetail => 'Detalle del pago';

  @override
  String get financeFeeLabel => 'Cuota';

  @override
  String get financeIssueDate => 'Fecha de emisión';

  @override
  String get financeDueDateLabel => 'Fecha límite';

  @override
  String get financeNotifyParents => 'Avisar a padres';

  @override
  String get financeCourseInfo => 'Información del curso';

  @override
  String get financeMovementHistory => 'Historial de movimientos';

  @override
  String get financeNoMovements => 'Aún no hay movimientos';

  @override
  String get financeNoMovementsDesc =>
      'Este pago todavía no ha sido registrado en el sistema.';

  @override
  String get financeFilters => 'Filtros';

  @override
  String get financeAllCourses => 'Todos los cursos';

  @override
  String get financeAllStudents => 'Todos los alumnos';

  @override
  String get financeAllStatuses => 'Todos';

  @override
  String get financeStatusField => 'Estado';

  @override
  String get financeClear => 'Limpiar';

  @override
  String get financeApply => 'Aplicar';

  @override
  String get financeIncome => 'Ingresos';

  @override
  String get financeByCourse => 'Por curso';

  @override
  String get financeCompliance => 'Cumplimiento';

  @override
  String get financeThisMonth => 'Este mes';

  @override
  String get financeIncomeByMonth => 'Ingresos por mes';

  @override
  String get financeNoPaymentsTitle => 'Sin pagos';

  @override
  String get financeNoPaymentsDesc =>
      'Aún no hay pagos registrados. Cuando registres pagos, los verás aquí.';

  @override
  String get financeNoResultsTitle => 'Sin resultados';

  @override
  String get financeNoResultsDesc =>
      'No encontramos pagos. Intenta con otro nombre o ajusta los filtros.';

  @override
  String get financeLoadErrorTitle => 'Error de carga';

  @override
  String get financeLoadErrorDesc =>
      'No se pudieron cargar los pagos. Intenta nuevamente.';

  @override
  String get financeRetry => 'Reintentar';

  @override
  String get financeMovementPaid => 'Pago registrado';

  @override
  String get financeMovementGenerated => 'Cuota generada';

  @override
  String get financeMovementOverdue => 'Pago vencido';

  @override
  String get financeDateRange => 'Rango de fechas';

  @override
  String get financeNoUnpaid => 'No hay cuotas pendientes en este periodo.';

  @override
  String get financeNoReminders => 'No hay cuotas pendientes de aviso.';

  @override
  String get financeReminderHint =>
      'Avisa a los tutores de las cuotas por cobrar, próximas o vencidas.';

  @override
  String get financeNoTutorPhone =>
      'Este alumno no tiene un teléfono de tutor.';

  @override
  String get financeViewStudent => 'Ver alumno';

  @override
  String get financeNoPeriodDues => 'No hay vencimientos en este periodo.';

  @override
  String get financeNoCourseIncome =>
      'No hay ingresos por curso en este periodo.';

  @override
  String get financeExpenses => 'Gastos';

  @override
  String get financeRealProfit => 'Ganancia real';

  @override
  String get financeRealProfitHint =>
      'Lo cobrado en este periodo, menos los gastos de los cursos.';

  @override
  String get financeExpenseSaved => 'Gasto registrado';

  @override
  String get financePickCourse => 'Selecciona un curso';

  @override
  String get financeNoExpensesPeriod => 'Aún no hay gastos en este periodo.';

  @override
  String get financeNoCoursesForExpense =>
      'Crea un curso para poder registrar sus gastos.';

  @override
  String get financeExpenseCategory => 'Categoría';

  @override
  String get certificatesBtn => 'Certificados';

  @override
  String get certificatesTitle => 'Certificados';

  @override
  String get certificatesSubtitle =>
      'Elige el estilo, el tipo y los alumnos para generar los diplomas.';

  @override
  String get certificateStyleLabel => 'Estilo';

  @override
  String get certificateStyleClassic => 'Clásico';

  @override
  String get certificateStyleModern => 'Moderno';

  @override
  String get certificateStyleElegant => 'Elegante';

  @override
  String get certificateTypeLabel => 'Tipo de certificado';

  @override
  String get certificateTypeCompletion => 'Finalización';

  @override
  String get certificateTypeApproval => 'Aprobación';

  @override
  String get certificateTypeParticipation => 'Participación';

  @override
  String get certificateTitleCompletion => 'Certificado de finalización';

  @override
  String get certificateTitleApproval => 'Certificado de aprobación';

  @override
  String get certificateTitleParticipation => 'Certificado de participación';

  @override
  String get certificateStudentsLabel => 'Alumnos';

  @override
  String get certificateSelectAll => 'Seleccionar todos';

  @override
  String get certificateClearSelection => 'Quitar selección';

  @override
  String certificateSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get certificateGenerate => 'Generar PDF';

  @override
  String get certificatePreviewTitle => 'Vista previa';

  @override
  String get certificateShare => 'Compartir PDF';

  @override
  String get certificateSaved =>
      'El PDF se guardó en los documentos de la app.';

  @override
  String get certificateNoStudents =>
      'Agrega alumnos al curso para emitir certificados.';

  @override
  String get certificatePickStudents => 'Selecciona al menos un alumno.';

  @override
  String certificateGenerated(int count) {
    return 'Se generaron $count diplomas.';
  }

  @override
  String get certificateConfers => 'Otorga el presente diploma a';

  @override
  String get certificateCompletionBody =>
      'por haber finalizado satisfactoriamente el curso';

  @override
  String get certificateApprovalBody => 'por haber aprobado el curso';

  @override
  String get certificateParticipationBody => 'por su participación en el curso';

  @override
  String certificateIssuedIn(String date) {
    return 'Expedido el $date';
  }

  @override
  String get certificateTeacherSign => 'Docente';

  @override
  String get certificateFolioLabel => 'Folio';

  @override
  String get courseReportBtn => 'Reporte';

  @override
  String get courseReportTitle => 'Reporte del curso';

  @override
  String get financeReportTitle => 'Reporte financiero';

  @override
  String get financeExportPdf => 'Exportar PDF';

  @override
  String get reportAttendance => 'Asistencia';

  @override
  String get reportSchedule => 'Horario';

  @override
  String get reportMonthlyCost => 'Costo mensual';

  @override
  String get reportStudent => 'Alumno';

  @override
  String get reportCourse => 'Curso';

  @override
  String get reportAmount => 'Monto';

  @override
  String get reportPayment => 'Pago';

  @override
  String get reportPendingPayments => 'Pagos pendientes';

  @override
  String reportGeneratedOn(String date) {
    return 'Generado el $date';
  }

  @override
  String financeReminderMessage(String tutor, String student, String course,
      String period, String amount, String due) {
    return 'Hola $tutor, te contactamos de Docentia. La cuota de $student del curso $course ($period) es de $amount y vence el $due.';
  }
}
