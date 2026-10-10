import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../courses/models/course_model.dart';
import '../models/payment_model.dart';
import '../repositories/payments_repository.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return LocalPaymentsRepository();
});

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

  Future<Payment> generateFeeForStudent({
    required String studentId,
    required double cost,
    required PaymentSchedule schedule,
  }) async {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Nombre de periodo (ej. Octubre 2026)
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final periodName = '${monthNames[month - 1]} $year';

    final dueDay = schedule == PaymentSchedule.firstHalf ? 15 : 30;
    final dueDateStr = '$year-${month.toString().padLeft(2, '0')}-${dueDay.toString().padLeft(2, '0')}';
    final dueDateTime = DateTime(year, month, dueDay);

    PaymentStatus status;
    if (now.isAfter(dueDateTime)) {
      status = PaymentStatus.overdue;
    } else if (dueDateTime.difference(now).inDays <= 5) {
      status = PaymentStatus.upcoming;
    } else {
      status = PaymentStatus.pending;
    }

    final newPayment = Payment(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      courseId: _courseId,
      period: periodName,
      amount: cost,
      dueDate: dueDateStr,
      status: status,
    );

    await _repository.addPayment(newPayment);
    final updated = await _repository.getPaymentsByCourse(_courseId);
    state = AsyncValue.data(updated);
    return newPayment;
  }
}

final paymentsForCourseProvider = StateNotifierProvider.family<
    PaymentsNotifier, AsyncValue<List<Payment>>, String>((ref, courseId) {
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
