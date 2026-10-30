import '../models/expense_model.dart';
import '../../payments/models/payment_model.dart';

/// Mes cerrado o rango de fechas para la vista de finanzas.
class FinanceWindow {
  final int? year;
  final int? month;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  const FinanceWindow.month(this.year, this.month)
      : rangeStart = null,
        rangeEnd = null;

  const FinanceWindow.range(this.rangeStart, this.rangeEnd)
      : year = null,
        month = null;

  factory FinanceWindow.current([DateTime? now]) {
    final date = now ?? DateTime.now();
    return FinanceWindow.month(date.year, date.month);
  }

  bool get isRange => rangeStart != null && rangeEnd != null;

  DateTime get anchor {
    if (isRange) return DateTime(rangeEnd!.year, rangeEnd!.month);
    return DateTime(year!, month!);
  }

  bool includes(Payment payment) {
    if (!isRange) {
      return payment.periodYear == year && payment.periodMonth == month;
    }
    return includesDate(payment.dueDate);
  }

  bool includesDate(String yyyyMmDd) {
    final parsed = DateTime.tryParse(yyyyMmDd);
    if (parsed == null) return false;
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    if (!isRange) return day.year == year && day.month == month;
    final start = DateTime(rangeStart!.year, rangeStart!.month, rangeStart!.day);
    final end = DateTime(rangeEnd!.year, rangeEnd!.month, rangeEnd!.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  FinanceWindow previous() {
    if (!isRange) {
      final prev = DateTime(year!, month! - 1);
      return FinanceWindow.month(prev.year, prev.month);
    }
    final start = DateTime(rangeStart!.year, rangeStart!.month, rangeStart!.day);
    final end = DateTime(rangeEnd!.year, rangeEnd!.month, rangeEnd!.day);
    final days = end.difference(start).inDays + 1;
    final prevEnd = start.subtract(const Duration(days: 1));
    final prevStart = prevEnd.subtract(Duration(days: days - 1));
    return FinanceWindow.range(prevStart, prevEnd);
  }

  bool isCurrentMonth([DateTime? now]) {
    final date = now ?? DateTime.now();
    return !isRange && year == date.year && month == date.month;
  }
}

enum FinanceListStatus { all, pending, overdue, upcoming, paid }

class FinanceListQuery {
  final String? courseId;
  final String? studentId;
  final FinanceListStatus status;

  const FinanceListQuery({
    this.courseId,
    this.studentId,
    this.status = FinanceListStatus.all,
  });

  bool get isDefault =>
      courseId == null && studentId == null && status == FinanceListStatus.all;

  bool matches(Payment payment) {
    if (courseId != null && payment.courseId != courseId) return false;
    if (studentId != null && payment.studentId != studentId) return false;
    switch (status) {
      case FinanceListStatus.all:
        return true;
      case FinanceListStatus.pending:
        return payment.status == PaymentStatus.pending;
      case FinanceListStatus.overdue:
        return payment.status == PaymentStatus.overdue;
      case FinanceListStatus.upcoming:
        return payment.status == PaymentStatus.upcoming;
      case FinanceListStatus.paid:
        return payment.status == PaymentStatus.paid;
    }
  }
}

class FinanceTotals {
  final double collected;
  final double toCollect;
  final int toCollectCount;
  final double overdue;
  final int overdueCount;
  final double upcoming;
  final int upcomingCount;
  final int? changePercent;

  const FinanceTotals({
    required this.collected,
    required this.toCollect,
    required this.toCollectCount,
    required this.overdue,
    required this.overdueCount,
    required this.upcoming,
    required this.upcomingCount,
    required this.changePercent,
  });
}

FinanceTotals financeTotals(List<Payment> payments, FinanceWindow window) {
  final current = _bucket(payments.where(window.includes));
  final previousCollected = _bucket(payments.where(window.previous().includes)).collected;
  int? change;
  if (previousCollected > 0) {
    change = (((current.collected - previousCollected) / previousCollected) * 100).round();
  }
  return FinanceTotals(
    collected: current.collected,
    toCollect: current.toCollect,
    toCollectCount: current.toCollectCount,
    overdue: current.overdue,
    overdueCount: current.overdueCount,
    upcoming: current.upcoming,
    upcomingCount: current.upcomingCount,
    changePercent: change,
  );
}

class _Bucket {
  double collected = 0;
  double toCollect = 0;
  int toCollectCount = 0;
  double overdue = 0;
  int overdueCount = 0;
  double upcoming = 0;
  int upcomingCount = 0;
}

_Bucket _bucket(Iterable<Payment> payments) {
  final bucket = _Bucket();
  for (final payment in payments) {
    switch (payment.status) {
      case PaymentStatus.paid:
        bucket.collected += payment.paidAmount ?? payment.amount;
      case PaymentStatus.pending:
        bucket.toCollect += payment.amount;
        bucket.toCollectCount++;
      case PaymentStatus.overdue:
        bucket.overdue += payment.amount;
        bucket.overdueCount++;
      case PaymentStatus.upcoming:
        bucket.upcoming += payment.amount;
        bucket.upcomingCount++;
    }
  }
  return bucket;
}

List<Payment> upcomingDues(List<Payment> payments, FinanceWindow window, {int limit = 3}) {
  final items = payments.where((payment) {
    if (!window.includes(payment)) return false;
    return payment.status != PaymentStatus.paid;
  }).toList();
  items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  if (items.length <= limit) return items;
  return items.sublist(0, limit);
}

List<DateTime> financeMonthOptions(List<Payment> payments, [DateTime? now]) {
  final today = now ?? DateTime.now();
  var earliest = DateTime(today.year, today.month - 11);
  for (final payment in payments) {
    if (payment.periodYear < 2000 || payment.periodMonth < 1 || payment.periodMonth > 12) {
      continue;
    }
    final month = DateTime(payment.periodYear, payment.periodMonth);
    if (month.isBefore(earliest)) earliest = month;
  }
  final latest = DateTime(today.year, today.month);
  final months = <DateTime>[];
  var cursor = latest;
  final floor = DateTime(earliest.year, earliest.month);
  while (!cursor.isBefore(floor)) {
    months.add(cursor);
    cursor = DateTime(cursor.year, cursor.month - 1);
  }
  return months;
}

List<DateTime> chartMonths(FinanceWindow window) {
  final anchor = window.anchor;
  return List.generate(6, (index) => DateTime(anchor.year, anchor.month - 5 + index));
}

double collectedInMonth(List<Payment> payments, DateTime month) {
  final window = FinanceWindow.month(month.year, month.month);
  return financeTotals(payments, window).collected;
}

enum FeeMovementKind { generated, paid, overdue }

class FeeMovement {
  final FeeMovementKind kind;
  final DateTime date;
  final bool hasTime;
  final double? amount;

  const FeeMovement({
    required this.kind,
    required this.date,
    required this.hasTime,
    this.amount,
  });
}

/// Historial derivado de los campos reales de la cuota.
/// Una cuota pendiente, que aún no vence, no tiene movimientos.
List<FeeMovement> feeMovements(Payment payment, [DateTime? now]) {
  final today = now ?? DateTime.now();
  final pendingLike = payment.status == PaymentStatus.pending || payment.status == PaymentStatus.upcoming;
  final due = DateTime.tryParse(payment.dueDate);
  final dueDay = due == null ? null : DateTime(due.year, due.month, due.day);
  final isPastDue = dueDay != null && dueDay.isBefore(DateTime(today.year, today.month, today.day));
  if (pendingLike && payment.paidAt == null && !isPastDue && payment.status != PaymentStatus.overdue) {
    return const [];
  }

  final items = <FeeMovement>[
    FeeMovement(
      kind: FeeMovementKind.generated,
      date: DateTime(payment.periodYear, payment.periodMonth, 1),
      hasTime: false,
      amount: payment.amount,
    ),
  ];
  if (payment.status == PaymentStatus.overdue && dueDay != null) {
    items.add(FeeMovement(
      kind: FeeMovementKind.overdue,
      date: dueDay,
      hasTime: false,
    ));
  }
  if (payment.status == PaymentStatus.paid) {
    items.add(FeeMovement(
      kind: FeeMovementKind.paid,
      date: payment.paidAt ?? dueDay ?? DateTime(payment.periodYear, payment.periodMonth, 1),
      hasTime: payment.paidAt != null,
      amount: payment.paidAmount ?? payment.amount,
    ));
  }
  items.sort((a, b) => b.date.compareTo(a.date));
  return items;
}

DateTime feeIssueDate(Payment payment) => DateTime(payment.periodYear, payment.periodMonth, 1);

bool expenseInWindow(Expense expense, FinanceWindow window) {
  final parsed = DateTime.tryParse(expense.date);
  if (parsed == null) return false;
  final day = DateTime(parsed.year, parsed.month, parsed.day);
  if (!window.isRange) return day.year == window.year && day.month == window.month;
  final start = DateTime(window.rangeStart!.year, window.rangeStart!.month, window.rangeStart!.day);
  final end = DateTime(window.rangeEnd!.year, window.rangeEnd!.month, window.rangeEnd!.day);
  return !day.isBefore(start) && !day.isAfter(end);
}

double expensesTotal(Iterable<Expense> expenses, FinanceWindow window) {
  return expenses.where((expense) => expenseInWindow(expense, window)).fold<double>(0, (sum, expense) => sum + expense.amount);
}

/// Cobrado del periodo menos los gastos registrados en ese mismo periodo.
double realProfit(double collected, double expenses) => collected - expenses;
