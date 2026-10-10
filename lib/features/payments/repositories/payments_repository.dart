import '../../../core/services/storage_service.dart';
import '../models/payment_model.dart';

abstract class PaymentsRepository {
  Future<List<Payment>> getPaymentsByCourse(String courseId);
  Future<List<Payment>> getPaymentsByStudent(String studentId, String courseId);
  Future<void> confirmPayment(String paymentId, {double? paidAmount, DateTime? paidDate});
  Future<void> addPayment(Payment payment);
}

class LocalPaymentsRepository implements PaymentsRepository {
  List<Payment>? _cached;

  Future<List<Payment>> _all() async {
    if (_cached != null) return _cached!;
    _cached = await StorageService.getPayments();
    return _cached!;
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
    list.add(payment);
    _cached = list;
    await StorageService.savePayments(list);
  }
}
