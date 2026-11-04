import '../../../core/services/storage_service.dart';
import '../models/payment_model.dart';
import '../services/fee_generation_service.dart';

class DuplicateFeeException implements Exception {
  final String message;
  const DuplicateFeeException([this.message = 'La cuota de este mes ya está registrada para este alumno y curso.']);
  @override
  String toString() => message;
}

abstract class PaymentsRepository {
  Future<List<Payment>> getAllPayments();
  Future<List<Payment>> getPaymentsByCourse(String courseId);
  Future<List<Payment>> getPaymentsByStudent(String studentId, String courseId);
  Future<bool> hasFeeForPeriod({
    required String studentId,
    required String courseId,
    required int year,
    required int month,
  });
  Future<bool> hasProratedFeeForPeriod({
    required String studentId,
    required String courseId,
    required int year,
    required int month,
  });
  Future<void> confirmPayment(String paymentId, {double? paidAmount, DateTime? paidDate});
  Future<void> addPayment(Payment payment);
  Future<void> updatePaymentDueDate(String paymentId, DueDateOption option);
  /// Recalcula pending/upcoming/overdue de cuotas no pagadas. Devuelve cuántas cambió.
  Future<int> refreshUnpaidStatuses({DateTime? now});
}

class LocalPaymentsRepository implements PaymentsRepository {
  List<Payment>? _cached;

  Future<List<Payment>> _all() async {
    if (_cached != null) return _cached!;
    _cached = await StorageService.getPayments();
    return _cached!;
  }

  @override
  Future<List<Payment>> getAllPayments() async {
    final list = await _all();
    return List.unmodifiable(list);
  }

  @override
  Future<List<Payment>> getPaymentsByCourse(String courseId) async {
    final list = await _all();
    return list.where((p) => p.courseId == courseId).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByStudent(String studentId, String courseId) async {
    final list = await _all();
    return list
        .where((p) => p.studentId == studentId && p.courseId == courseId)
        .toList();
  }

  @override
  Future<bool> hasFeeForPeriod({
    required String studentId,
    required String courseId,
    required int year,
    required int month,
  }) async {
    final list = await _all();
    return list.any((p) =>
    !p.isProrated &&
        p.studentId == studentId &&
        p.courseId == courseId &&
        p.periodYear == year &&
        p.periodMonth == month);
  }

  @override
  Future<bool> hasProratedFeeForPeriod({
    required String studentId,
    required String courseId,
    required int year,
    required int month,
  }) async {
    final list = await _all();
    return list.any((p) =>
    p.isProrated &&
        p.studentId == studentId &&
        p.courseId == courseId &&
        p.periodYear == year &&
        p.periodMonth == month);
  }

  @override
  Future<void> confirmPayment(String paymentId, {double? paidAmount, DateTime? paidDate}) async {
    final list = (await _all()).toList();
    final index = list.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      final current = list[index];
      list[index] = current.copyWith(
        status: PaymentStatus.paid,
        paidAt: paidDate ?? DateTime.now(),
        paidAmount: paidAmount ?? current.amount,
      );
      _cached = list;
      await StorageService.savePayments(list);
    }
  }

  @override
  Future<void> addPayment(Payment payment) async {
    final list = (await _all()).toList();

    final alreadyExists = list.any((p) =>
    p.isProrated == payment.isProrated &&
        p.studentId == payment.studentId &&
        p.courseId == payment.courseId &&
        p.periodYear == payment.periodYear &&
        p.periodMonth == payment.periodMonth);

    if (alreadyExists) {
      throw const DuplicateFeeException();
    }

    list.add(payment);
    _cached = list;
    await StorageService.savePayments(list);
  }

  @override
  Future<void> updatePaymentDueDate(String paymentId, DueDateOption option) async {
    final list = (await _all()).toList();
    final index = list.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      final current = list[index];
      final newDueDate = Payment.calculateDueDate(current.periodYear, current.periodMonth, option);
      final due = DateTime.tryParse(newDueDate) ?? DateTime.now();
      final nextStatus = current.status == PaymentStatus.paid
          ? PaymentStatus.paid
          : FeeCycle.statusForDueDate(DateTime.now(), due);
      list[index] = current.copyWith(
        dueDate: newDueDate,
        dueOption: option,
        status: nextStatus,
      );
      _cached = list;
      await StorageService.savePayments(list);
    }
  }

  @override
  Future<int> refreshUnpaidStatuses({DateTime? now}) async {
    final moment = now ?? DateTime.now();
    final list = (await _all()).toList();
    var changed = 0;

    for (var i = 0; i < list.length; i++) {
      final payment = list[i];
      if (payment.status == PaymentStatus.paid) continue;
      final due = DateTime.tryParse(payment.dueDate);
      if (due == null) continue;
      final next = FeeCycle.statusForDueDate(moment, due);
      if (next == payment.status) continue;
      list[i] = payment.copyWith(status: next);
      changed++;
    }

    if (changed > 0) {
      _cached = list;
      await StorageService.savePayments(list);
    }
    return changed;
  }
}
