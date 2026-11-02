import '../../courses/models/course_model.dart';
import '../../students/models/student_model.dart';
import '../models/payment_model.dart';
import '../repositories/payments_repository.dart';

class FeePeriod {
  /// Mes de servicio que se está pagando por adelantado.
  final int year;
  final int month;

  /// Día en que se cobra (antes de que inicie el mes de servicio).
  final DateTime billingDate;

  const FeePeriod({
    required this.year,
    required this.month,
    required this.billingDate,
  });
}

class FeeCycle {
  static DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Día de cobro adelantado: 15 (mitad de mes) o último día del mes.
  static DateTime billingDate(PaymentSchedule schedule, int year, int month) {
    if (schedule == PaymentSchedule.firstHalf) {
      return DateTime(year, month, 15);
    }
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, lastDay);
  }

  /// El cobro del mes calendario M paga por adelantado el mes de servicio M+1.
  static DateTime servicePeriodForBilling(DateTime billing) {
    return DateTime(billing.year, billing.month + 1, 1);
  }

  static DateTime nextBillingDate(PaymentSchedule schedule, DateTime from) {
    final today = dateOnly(from);
    final thisMonth = billingDate(schedule, today.year, today.month);
    if (today.isBefore(thisMonth)) return thisMonth;
    final nextMonth = DateTime(today.year, today.month + 1, 1);
    return billingDate(schedule, nextMonth.year, nextMonth.month);
  }

  static DateTime previousBillingDate(PaymentSchedule schedule, DateTime billing) {
    final prevMonth = DateTime(billing.year, billing.month - 1, 1);
    return billingDate(schedule, prevMonth.year, prevMonth.month);
  }

  static int cycleDays(PaymentSchedule schedule, DateTime from) {
    final next = nextBillingDate(schedule, from);
    final previous = previousBillingDate(schedule, next);
    return next.difference(previous).inDays;
  }

  /// Días que faltan hasta el próximo cobro completo (mensualidad adelantada).
  static int remainingDays(PaymentSchedule schedule, DateTime from) {
    final today = dateOnly(from);
    final thisMonth = billingDate(schedule, today.year, today.month);
    if (isSameDay(today, thisMonth)) return 0;
    return nextBillingDate(schedule, today).difference(today).inDays;
  }

  static double proratedAmount({
    required double monthlyCost,
    required PaymentSchedule schedule,
    required DateTime from,
  }) {
    final remaining = remainingDays(schedule, from);
    final cycle = cycleDays(schedule, from);
    if (remaining <= 0 || cycle <= 0) return 0;
    return double.parse((monthlyCost * remaining / cycle).toStringAsFixed(2));
  }

  /// Cobros adelantados cuya fecha ya llegó: genera la mensualidad del mes siguiente.
  static List<FeePeriod> duePeriods(PaymentSchedule schedule, DateTime from) {
    final today = dateOnly(from);
    final periods = <FeePeriod>[];

    void considerBillingMonth(int year, int month) {
      final billing = billingDate(schedule, year, month);
      if (today.isBefore(billing)) return;
      final service = servicePeriodForBilling(billing);
      periods.add(
        FeePeriod(
          year: service.year,
          month: service.month,
          billingDate: billing,
        ),
      );
    }

    considerBillingMonth(today.year, today.month);
    final previous = DateTime(today.year, today.month - 1, 1);
    considerBillingMonth(previous.year, previous.month);
    return periods;
  }

  static bool wasEnrolledOn(DateTime createdAt, DateTime billing) {
    return !dateOnly(createdAt).isAfter(billing);
  }

  static DueDateOption dueOptionFor(PaymentSchedule schedule) {
    return schedule == PaymentSchedule.firstHalf
        ? DueDateOption.startOfMonth
        : DueDateOption.endOfMonth;
  }

  static PaymentStatus statusForDueDate(DateTime now, DateTime due) {
    final dueEnd = DateTime(due.year, due.month, due.day, 23, 59, 59);
    if (now.isAfter(dueEnd)) return PaymentStatus.overdue;
    if (dueEnd.difference(now).inDays <= 5) return PaymentStatus.upcoming;
    return PaymentStatus.pending;
  }
}

class AutoFeeGenerator {
  static Future<int> generate({
    required List<Course> courses,
    required List<Student> students,
    required PaymentsRepository payments,
    DateTime? now,
  }) async {
    final today = now ?? DateTime.now();
    var created = 0;

    for (final course in courses.where((item) => item.active)) {
      final courseStudents = students.where(
        (student) => student.active && student.courseId == course.id,
      );
      final periods = FeeCycle.duePeriods(course.paymentSchedule, today);

      for (final student in courseStudents) {
        for (final period in periods) {
          if (!FeeCycle.wasEnrolledOn(student.createdAt, period.billingDate)) {
            continue;
          }

          final exists = await payments.hasFeeForPeriod(
            studentId: student.id,
            courseId: course.id,
            year: period.year,
            month: period.month,
          );
          if (exists) continue;

          final payment = Payment(
            id: 'pay-${today.microsecondsSinceEpoch}-$created',
            studentId: student.id,
            courseId: course.id,
            period: Payment.formatPeriodName(period.year, period.month),
            periodMonth: period.month,
            periodYear: period.year,
            amount: course.cost,
            dueDate: FeeCycle.formatDate(period.billingDate),
            dueOption: FeeCycle.dueOptionFor(course.paymentSchedule),
            status: FeeCycle.statusForDueDate(today, period.billingDate),
          );

          try {
            await payments.addPayment(payment);
            created++;
          } on DuplicateFeeException {
            continue;
          }
        }
      }
    }

    return created;
  }
}
