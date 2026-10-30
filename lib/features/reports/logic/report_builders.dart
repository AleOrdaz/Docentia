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
  });
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
  final periodSessions = sessions.where((session) => window.includesDate(session.date)).toList();
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
          presentsByStudent[item.studentId] = (presentsByStudent[item.studentId] ?? 0) + 1;
        case AttendanceStatus.late:
          lates++;
          latesByStudent[item.studentId] = (latesByStudent[item.studentId] ?? 0) + 1;
        case AttendanceStatus.absent:
        case AttendanceStatus.excused:
          absences++;
          absencesByStudent[item.studentId] = (absencesByStudent[item.studentId] ?? 0) + 1;
      }
    }
  }

  final totals = financeTotals(periodPayments, window);
  final expenseSum = periodExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);

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
            .where((payment) => payment.studentId == student.id && payment.status == PaymentStatus.paid)
            .fold<double>(0, (sum, payment) => sum + (payment.paidAmount ?? payment.amount)),
        outstanding: periodPayments
            .where((payment) => payment.studentId == student.id && payment.status != PaymentStatus.paid)
            .fold<double>(0, (sum, payment) => sum + payment.amount),
      ),
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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
  );
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
    if (!window.includes(entry.payment) || entry.payment.status != PaymentStatus.paid) {
      continue;
    }
    final name = entry.courseName.isEmpty ? fallbackCourse : entry.courseName;
    amounts[name] = (amounts[name] ?? 0) + (entry.payment.paidAmount ?? entry.payment.amount);
  }

  final byCourse = [
    for (final entry in amounts.entries) CourseIncomeRow(courseName: entry.key, collected: entry.value),
  ]..sort((a, b) => b.collected.compareTo(a.collected));

  final unpaid = [
    for (final entry in catalog.entries)
      if (window.includes(entry.payment) && entry.payment.status != PaymentStatus.paid)
        UnpaidRow(
          studentName: entry.studentName.isEmpty ? fallbackStudent : entry.studentName,
          courseName: entry.courseName.isEmpty ? fallbackCourse : entry.courseName,
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

String reportFilename(String title, FinanceWindow window) {
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
  return 'reporte-$safe-$period.pdf';
}

String _fileDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}$month$day';
}
