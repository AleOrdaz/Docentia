import '../../attendance/models/attendance_model.dart';
import '../../courses/models/course_model.dart';
import '../../finance/logic/finance_fees.dart';
import '../../finance/models/expense_model.dart';
import '../../finance/providers/finance_catalog_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../students/models/student_model.dart';

class CourseStudentReportRow {
  final String studentId;
  final String name;
  final int presents;
  final int lates;
  final int absences;
  final PaymentStatus? paymentStatus;
  final double collected;
  final double outstanding;

  const CourseStudentReportRow({
    required this.studentId,
    required this.name,
    required this.presents,
    required this.lates,
    required this.absences,
    required this.paymentStatus,
    required this.collected,
    required this.outstanding,
  });

  int get marked => presents + lates + absences;
}

class CourseReportData {
  final String courseName;
  final String schedule;
  final double cost;
  final int studentCount;
  final int sessionCount;
  final int presents;
  final int lates;
  final int absences;
  final double collected;
  final double toCollect;
  final double overdue;
  final double expenses;
  final double profit;
  final List<CourseStudentReportRow> students;

  /// Ingreso mensual esperado si todos pagan: alumnos × costo.
  final double expectedIncome;

  /// Horas de clase por semana según días y horario.
  final double weeklyHours;

  /// Porcentaje de asistencia del curso (presentes + retardos / marcados).
  final double? attendancePercent;

  /// Alumnos con al menos una cuota pendiente o vencida.
  final int pendingPaymentStudents;

  /// Nombres sugeridos para baja por atraso prolongado (~2 meses).
  final List<String> deactivationSuggestions;

  const CourseReportData({
    required this.courseName,
    required this.schedule,
    required this.cost,
    required this.studentCount,
    required this.sessionCount,
    required this.presents,
    required this.lates,
    required this.absences,
    required this.collected,
    required this.toCollect,
    required this.overdue,
    required this.expenses,
    required this.profit,
    required this.students,
    required this.expectedIncome,
    required this.weeklyHours,
    required this.attendancePercent,
    required this.pendingPaymentStudents,
    required this.deactivationSuggestions,
  });

  int get markedAttendance => presents + lates + absences;
}

class CourseIncomeRow {
  final String courseName;
  final double collected;

  const CourseIncomeRow({required this.courseName, required this.collected});
}

class UnpaidRow {
  final String studentName;
  final String courseName;
  final double amount;
  final PaymentStatus status;

  const UnpaidRow({
    required this.studentName,
    required this.courseName,
    required this.amount,
    required this.status,
  });
}

class FinanceReportData {
  final FinanceTotals totals;
  final double expenses;
  final double profit;
  final List<CourseIncomeRow> byCourse;
  final List<UnpaidRow> unpaid;

  const FinanceReportData({
    required this.totals,
    required this.expenses,
    required this.profit,
    required this.byCourse,
    required this.unpaid,
  });
}

PaymentStatus? worstPaymentStatus(Iterable<Payment> payments) {
  if (payments.isEmpty) return null;
  if (payments.any((payment) => payment.status == PaymentStatus.overdue)) {
    return PaymentStatus.overdue;
  }
  if (payments.any((payment) => payment.status == PaymentStatus.pending)) {
    return PaymentStatus.pending;
  }
  if (payments.any((payment) => payment.status == PaymentStatus.upcoming)) {
    return PaymentStatus.upcoming;
  }
  return PaymentStatus.paid;
}

CourseReportData buildCourseReport({
  required Course course,
  required List<Student> students,
  required List<ClassAttendanceSession> sessions,
  required List<Payment> payments,
  required List<Expense> expenses,
  required FinanceWindow window,
}) {
  final periodSessions =
      sessions.where((session) => window.includesDate(session.date)).toList();
  final periodPayments = payments.where((payment) {
    return payment.courseId == course.id && window.includes(payment);
  }).toList();
  final periodExpenses = expenses.where((expense) {
    return expense.courseId == course.id && expenseInWindow(expense, window);
  }).toList();

  final presentsByStudent = <String, int>{};
  final latesByStudent = <String, int>{};
  final absencesByStudent = <String, int>{};
  var presents = 0;
  var lates = 0;
  var absences = 0;

  for (final session in periodSessions) {
    for (final item in session.students) {
      switch (item.status) {
        case AttendanceStatus.present:
          presents++;
          presentsByStudent[item.studentId] =
              (presentsByStudent[item.studentId] ?? 0) + 1;
        case AttendanceStatus.late:
          lates++;
          latesByStudent[item.studentId] =
              (latesByStudent[item.studentId] ?? 0) + 1;
        case AttendanceStatus.absent:
        case AttendanceStatus.excused:
          absences++;
          absencesByStudent[item.studentId] =
              (absencesByStudent[item.studentId] ?? 0) + 1;
      }
    }
  }

  final totals = financeTotals(periodPayments, window);
  final expenseSum =
      periodExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);

  final rows = [
    for (final student in students)
      CourseStudentReportRow(
        studentId: student.id,
        name: student.fullName,
        presents: presentsByStudent[student.id] ?? 0,
        lates: latesByStudent[student.id] ?? 0,
        absences: absencesByStudent[student.id] ?? 0,
        paymentStatus: worstPaymentStatus(
          periodPayments.where((payment) => payment.studentId == student.id),
        ),
        collected: periodPayments
            .where((payment) =>
                payment.studentId == student.id &&
                payment.status == PaymentStatus.paid)
            .fold<double>(0,
                (sum, payment) => sum + (payment.paidAmount ?? payment.amount)),
        outstanding: periodPayments
            .where((payment) =>
                payment.studentId == student.id &&
                payment.status != PaymentStatus.paid)
            .fold<double>(0, (sum, payment) => sum + payment.amount),
      ),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  final marked = presents + lates + absences;
  final coursePayments =
      payments.where((payment) => payment.courseId == course.id);
  final pendingPaymentStudents = students.where((student) {
    final studentPayments =
        coursePayments.where((payment) => payment.studentId == student.id);
    if (studentPayments.isEmpty) return false;
    return studentPayments.any(
      (payment) =>
          payment.status == PaymentStatus.pending ||
          payment.status == PaymentStatus.overdue,
    );
  }).length;

  return CourseReportData(
    courseName: course.name,
    schedule: course.formattedSchedule,
    cost: course.cost,
    studentCount: students.length,
    sessionCount: periodSessions.length,
    presents: presents,
    lates: lates,
    absences: absences,
    collected: totals.collected,
    toCollect: totals.toCollect,
    overdue: totals.overdue,
    expenses: expenseSum,
    profit: realProfit(totals.collected, expenseSum),
    students: rows,
    expectedIncome: students.length * course.cost,
    weeklyHours: courseWeeklyHours(course),
    attendancePercent: marked == 0 ? null : ((presents + lates) * 100 / marked),
    pendingPaymentStudents: pendingPaymentStudents,
    deactivationSuggestions: studentsSuggestedForDeactivation(
      students: students,
      payments: payments.where((payment) => payment.courseId == course.id),
    ),
  );
}

TimeOfDayMinutes? _parseCourseTime(String raw) {
  final clean = raw.trim().toUpperCase();
  if (clean.isEmpty) return null;
  final isPm = clean.contains('PM');
  final isAm = clean.contains('AM');
  final digits = clean.replaceAll(RegExp(r'[^0-9:]'), '');
  final parts = digits.split(':');
  if (parts.length < 2) return null;
  var hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (isPm && hour < 12) hour += 12;
  if (isAm && hour == 12) hour = 0;
  return TimeOfDayMinutes(hour: hour, minute: minute);
}

class TimeOfDayMinutes {
  final int hour;
  final int minute;
  const TimeOfDayMinutes({required this.hour, required this.minute});
  int get totalMinutes => hour * 60 + minute;
}

double courseWeeklyHours(Course course) {
  var totalMinutes = 0;
  for (final schedule in course.effectiveClassSchedules) {
    final start = _parseCourseTime(schedule.startTime);
    final end = _parseCourseTime(schedule.endTime);
    if (start == null || end == null) continue;
    var minutes = end.totalMinutes - start.totalMinutes;
    if (minutes <= 0) minutes += 24 * 60;
    totalMinutes += minutes;
  }
  return totalMinutes / 60.0;
}

/// Alumnos con ~2 meses o más de atraso (2+ cuotas vencidas o vencimiento ≥ 60 días).
List<String> studentsSuggestedForDeactivation({
  required List<Student> students,
  required Iterable<Payment> payments,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final names = <String>[];
  for (final student in students) {
    final overdue = payments
        .where(
          (payment) =>
              payment.studentId == student.id &&
              payment.status == PaymentStatus.overdue,
        )
        .toList();
    if (overdue.length >= 2) {
      names.add(student.fullName);
      continue;
    }
    final hasLongOverdue = overdue.any((payment) {
      final due = DateTime.tryParse(payment.dueDate);
      if (due == null) return false;
      return today.difference(due).inDays >= 60;
    });
    if (hasLongOverdue) names.add(student.fullName);
  }
  names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return names;
}

FinanceReportData buildFinanceReport({
  required FinanceCatalog catalog,
  required FinanceWindow window,
  required List<Expense> expenses,
  required String fallbackCourse,
  required String fallbackStudent,
}) {
  final totals = financeTotals(catalog.payments, window);
  final expenseSum = expensesTotal(expenses, window);
  final amounts = <String, double>{};

  for (final entry in catalog.entries) {
    if (!window.includes(entry.payment) ||
        entry.payment.status != PaymentStatus.paid) {
      continue;
    }
    final name = entry.courseName.isEmpty ? fallbackCourse : entry.courseName;
    amounts[name] = (amounts[name] ?? 0) +
        (entry.payment.paidAmount ?? entry.payment.amount);
  }

  final byCourse = [
    for (final entry in amounts.entries)
      CourseIncomeRow(courseName: entry.key, collected: entry.value),
  ]..sort((a, b) => b.collected.compareTo(a.collected));

  final unpaid = [
    for (final entry in catalog.entries)
      if (window.includes(entry.payment) &&
          entry.payment.status != PaymentStatus.paid)
        UnpaidRow(
          studentName:
              entry.studentName.isEmpty ? fallbackStudent : entry.studentName,
          courseName:
              entry.courseName.isEmpty ? fallbackCourse : entry.courseName,
          amount: entry.payment.amount,
          status: entry.payment.status,
        ),
  ]..sort((a, b) => b.amount.compareTo(a.amount));

  return FinanceReportData(
    totals: totals,
    expenses: expenseSum,
    profit: realProfit(totals.collected, expenseSum),
    byCourse: byCourse,
    unpaid: unpaid,
  );
}

class StudentMonthExportRow {
  final String name;
  final int attendances;
  final double dailyRate;
  final double total;
  final double hours;

  const StudentMonthExportRow({
    required this.name,
    required this.attendances,
    required this.dailyRate,
    required this.total,
    required this.hours,
  });
}

DateTime reportWindowStart(FinanceWindow window) {
  if (window.isRange) {
    final start = window.rangeStart!;
    return DateTime(start.year, start.month, start.day);
  }
  return DateTime(window.year!, window.month!);
}

DateTime reportWindowEnd(FinanceWindow window) {
  if (window.isRange) {
    final end = window.rangeEnd!;
    return DateTime(end.year, end.month, end.day);
  }
  return DateTime(window.year!, window.month! + 1, 0);
}

int scheduledClassDaysInWindow(Course course, FinanceWindow window) {
  final end = reportWindowEnd(window);
  var count = 0;
  for (var day = reportWindowStart(window);
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))) {
    if (course.isClassDay(day)) count++;
  }
  return count;
}

/// Precio de un día de clase según la frecuencia de cobro del curso.
double courseDailyRate(Course course, FinanceWindow window) {
  final daysPerWeek = course.effectiveClassDays.isEmpty
      ? 1
      : course.effectiveClassDays.length;
  switch (course.billingFrequency) {
    case BillingFrequency.perClass:
      return course.cost;
    case BillingFrequency.weekly:
      return course.cost / daysPerWeek;
    case BillingFrequency.biweekly:
      return course.cost / (daysPerWeek * 2);
    case BillingFrequency.monthly:
      final scheduled = scheduledClassDaysInWindow(course, window);
      if (scheduled <= 0) return 0;
      return course.cost / scheduled;
  }
}

double sessionDurationHours(ClassAttendanceSession session, Course course) {
  var start = _parseCourseTime(session.startTime);
  var end = _parseCourseTime(session.endTime);
  if (start == null || end == null) {
    final date = DateTime.tryParse(session.date);
    final schedule = date == null ? null : course.scheduleForDay(date.weekday);
    start ??= schedule == null ? null : _parseCourseTime(schedule.startTime);
    end ??= schedule == null ? null : _parseCourseTime(schedule.endTime);
  }
  if (start == null || end == null) return 0;
  var minutes = end.totalMinutes - start.totalMinutes;
  if (minutes <= 0) minutes += 24 * 60;
  return minutes / 60;
}

/// Métricas del periodo por alumno para la exportación a Excel.
///
/// Las asistencias y las horas cuentan presentes y retardos. El total sigue
/// la frecuencia del curso: por clase, semana o quincena se cobra lo
/// trabajado; el cobro mensual conserva el costo del mes.
List<StudentMonthExportRow> buildStudentMonthExport({
  required Course course,
  required List<Student> students,
  required List<ClassAttendanceSession> sessions,
  required FinanceWindow window,
}) {
  final periodSessions =
      sessions.where((session) => window.includesDate(session.date)).toList();
  final dailyRate = courseDailyRate(course, window);
  final rows = [
    for (final student in students)
      _studentMonthRow(
        course: course,
        student: student,
        sessions: periodSessions,
        dailyRate: dailyRate,
      ),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return rows;
}

StudentMonthExportRow _studentMonthRow({
  required Course course,
  required Student student,
  required List<ClassAttendanceSession> sessions,
  required double dailyRate,
}) {
  final attendedDates = <DateTime>{};
  var attendances = 0;
  var hours = 0.0;
  for (final session in sessions) {
    final attended = session.students.any(
      (item) =>
          item.studentId == student.id &&
          (item.status == AttendanceStatus.present ||
              item.status == AttendanceStatus.late),
    );
    if (!attended) continue;
    attendances++;
    final date = DateTime.tryParse(session.date);
    if (date != null) {
      attendedDates.add(DateTime(date.year, date.month, date.day));
    }
    hours += sessionDurationHours(session, course);
  }

  return StudentMonthExportRow(
    name: student.fullName,
    attendances: attendances,
    dailyRate: dailyRate,
    total: _studentPeriodTotal(
      course: course,
      attendances: attendedDates.length,
      attendedDates: attendedDates,
    ),
    hours: hours,
  );
}

double _studentPeriodTotal({
  required Course course,
  required int attendances,
  required Set<DateTime> attendedDates,
}) {
  switch (course.billingFrequency) {
    case BillingFrequency.perClass:
      return course.cost * attendances;
    case BillingFrequency.weekly:
      return course.cost * _distinctWeeks(attendedDates);
    case BillingFrequency.biweekly:
      return course.cost * _distinctBiweeks(attendedDates);
    case BillingFrequency.monthly:
      return course.cost;
  }
}

int _distinctWeeks(Set<DateTime> dates) {
  final weeks = <DateTime>{};
  for (final date in dates) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    weeks.add(DateTime(monday.year, monday.month, monday.day));
  }
  return weeks.length;
}

int _distinctBiweeks(Set<DateTime> dates) {
  final halves = <String>{};
  for (final date in dates) {
    final half = date.day <= 15 ? 1 : 2;
    halves.add('${date.year}-${date.month}-$half');
  }
  return halves.length;
}

String reportFilename(
  String title,
  FinanceWindow window, {
  String fileExtension = 'pdf',
}) {
  const from = 'áéíóúüñÁÉÍÓÚÜÑ';
  const to = 'aeiouunAEIOUUN';
  var normalized = title;
  for (var i = 0; i < from.length; i++) {
    normalized = normalized.replaceAll(from[i], to[i]);
  }
  final slug = normalized
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final period = window.isRange
      ? '${_fileDate(window.rangeStart!)}-${_fileDate(window.rangeEnd!)}'
      : '${window.year}-${window.month.toString().padLeft(2, '0')}';
  final safe = slug.isEmpty ? 'docentia' : slug;
  return 'reporte-$safe-$period.$fileExtension';
}

String _fileDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}$month$day';
}
