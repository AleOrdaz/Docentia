import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../students/providers/students_provider.dart';
import '../models/payment_model.dart';
import '../repositories/payments_repository.dart';
import '../services/fee_generation_service.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return LocalPaymentsRepository();
});

final paymentsRevisionProvider = StateProvider<int>((ref) => 0);

class PaymentsNotifier extends StateNotifier<AsyncValue<List<Payment>>> {
  final PaymentsRepository _repository;
  final String _courseId;

  PaymentsNotifier(this._repository, this._courseId)
      : super(const AsyncValue.loading()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    try {
      final payments = await _repository.getPaymentsByCourse(_courseId);
      state = AsyncValue.data(payments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> confirmPayment(String paymentId, {double? paidAmount, DateTime? paidDate}) async {
    await _repository.confirmPayment(paymentId, paidAmount: paidAmount, paidDate: paidDate);
    final updated = await _repository.getPaymentsByCourse(_courseId);
    state = AsyncValue.data(updated);
  }

  Future<({bool success, String message, Payment? payment})> generateFeeForStudent({
    required String studentId,
    required double cost,
    int? year,
    int? month,
    DueDateOption dueOption = DueDateOption.endOfMonth,
    PaymentSchedule? schedule,
  }) async {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    // 1. Consultar si ya existe para ese alumno, curso y periodo (año + mes)
    final exists = await _repository.hasFeeForPeriod(
      studentId: studentId,
      courseId: _courseId,
      year: targetYear,
      month: targetMonth,
    );

    if (exists) {
      return (
      success: false,
      message: 'La cuota de este mes ya está registrada para este alumno y curso.',
      payment: null,
      );
    }

    // 2. Determinar opción de vencimiento si se pasó schedule antiguo
    final effectiveDueOption = schedule != null
        ? (schedule == PaymentSchedule.firstHalf
        ? DueDateOption.startOfMonth
        : DueDateOption.endOfMonth)
        : dueOption;

    // 3. Calcular fecha exacta de vencimiento según la opción seleccionada
    final dueDateStr = Payment.calculateDueDate(targetYear, targetMonth, effectiveDueOption);
    final parts = dueDateStr.split('-');
    final dueDateTime = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    PaymentStatus status;
    if (now.isAfter(dueDateTime)) {
      status = PaymentStatus.overdue;
    } else if (dueDateTime.difference(now).inDays <= 5) {
      status = PaymentStatus.upcoming;
    } else {
      status = PaymentStatus.pending;
    }

    final periodName = Payment.formatPeriodName(targetYear, targetMonth);

    final newPayment = Payment(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      courseId: _courseId,
      period: periodName,
      periodMonth: targetMonth,
      periodYear: targetYear,
      amount: cost,
      dueDate: dueDateStr,
      dueOption: effectiveDueOption,
      status: status,
    );

    try {
      await _repository.addPayment(newPayment);
      final updated = await _repository.getPaymentsByCourse(_courseId);
      state = AsyncValue.data(updated);
      return (
      success: true,
      message: 'Cuota generada correctamente para $periodName.',
      payment: newPayment,
      );
    } on DuplicateFeeException catch (e) {
      return (
      success: false,
      message: e.message,
      payment: null,
      );
    }
  }

  Future<({bool success, String message, Payment? payment, int remainingDays})>
      generateProratedFeeForStudent({
    required String studentId,
    required double cost,
    required PaymentSchedule schedule,
    DateTime? returnDate,
  }) async {
    final now = DateTime.now();
    final from = FeeCycle.dateOnly(returnDate ?? now);
    final remaining = FeeCycle.remainingDays(schedule, from);

    if (remaining <= 0) {
      return (
        success: false,
        message: 'billingDay',
        payment: null,
        remainingDays: 0,
      );
    }

    final exists = await _repository.hasProratedFeeForPeriod(
      studentId: studentId,
      courseId: _courseId,
      year: from.year,
      month: from.month,
    );
    if (exists) {
      return (
        success: false,
        message: 'alreadyExists',
        payment: null,
        remainingDays: remaining,
      );
    }

    final amount = FeeCycle.proratedAmount(
      monthlyCost: cost,
      schedule: schedule,
      from: from,
    );
    final newPayment = Payment(
      id: 'pay-${now.microsecondsSinceEpoch}',
      studentId: studentId,
      courseId: _courseId,
      period: Payment.formatPeriodName(from.year, from.month),
      periodMonth: from.month,
      periodYear: from.year,
      amount: amount,
      dueDate: FeeCycle.formatDate(from),
      dueOption: FeeCycle.dueOptionFor(schedule),
      status: FeeCycle.statusForDueDate(now, from),
      isProrated: true,
    );

    try {
      await _repository.addPayment(newPayment);
      final updated = await _repository.getPaymentsByCourse(_courseId);
      state = AsyncValue.data(updated);
      return (
        success: true,
        message: 'created',
        payment: newPayment,
        remainingDays: remaining,
      );
    } on DuplicateFeeException {
      return (
        success: false,
        message: 'alreadyExists',
        payment: null,
        remainingDays: remaining,
      );
    }
  }

  Future<void> updatePaymentDueDate(String paymentId, DueDateOption newOption) async {
    await _repository.updatePaymentDueDate(paymentId, newOption);
    final updated = await _repository.getPaymentsByCourse(_courseId);
    state = AsyncValue.data(updated);
  }
}

final paymentsForCourseProvider = StateNotifierProvider.family<
    PaymentsNotifier, AsyncValue<List<Payment>>, String>((ref, courseId) {
  ref.watch(paymentsRevisionProvider);
  final repo = ref.watch(paymentsRepositoryProvider);
  return PaymentsNotifier(repo, courseId);
});

final studentPaymentsProvider =
FutureProvider.family<List<Payment>, ({String studentId, String courseId})>(
      (ref, arg) async {
    // Watch paymentsForCourseProvider to trigger updates when a payment is confirmed
    ref.watch(paymentsForCourseProvider(arg.courseId));
    final repo = ref.watch(paymentsRepositoryProvider);
    return repo.getPaymentsByStudent(arg.studentId, arg.courseId);
  },
);

final allPaymentsProvider = FutureProvider<List<Payment>>((ref) async {
  ref.watch(paymentsRevisionProvider);
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.getAllPayments();
});

final autoGenerateFeesProvider = FutureProvider<int>((ref) async {
  ref.watch(studentsRevisionProvider);
  final courses = await ref.watch(coursesRepositoryProvider).getCourses();
  final students = await ref.watch(studentsRepositoryProvider).getAllStudents();
  final payments = ref.watch(paymentsRepositoryProvider);
  final created = await AutoFeeGenerator.generate(
    courses: courses,
    students: students,
    payments: payments,
  );
  if (created > 0) {
    ref.read(paymentsRevisionProvider.notifier).state++;
  }
  return created;
});
