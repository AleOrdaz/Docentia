import 'package:docentia/core/services/storage_service.dart';
import 'package:docentia/features/payments/models/payment_model.dart';
import 'package:docentia/features/payments/repositories/payments_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    StorageService.resetCacheForTest();
  });

  Payment payment({
    required String id,
    required String dueDate,
    required PaymentStatus status,
    DueDateOption dueOption = DueDateOption.endOfMonth,
  }) {
    final parts = dueDate.split('-');
    return Payment(
      id: id,
      studentId: 's1',
      courseId: 'c1',
      period: 'Test',
      periodYear: int.parse(parts[0]),
      periodMonth: int.parse(parts[1]),
      amount: 1000,
      dueDate: dueDate,
      dueOption: dueOption,
      status: status,
    );
  }

  test('refreshUnpaidStatuses pasa pending a overdue cuando la fecha ya pasó', () async {
    final repo = LocalPaymentsRepository();
    await repo.addPayment(
      payment(
        id: 'p1',
        dueDate: '2026-01-01',
        status: PaymentStatus.pending,
      ),
    );
    await repo.addPayment(
      payment(
        id: 'p2',
        dueDate: '2099-12-31',
        status: PaymentStatus.pending,
      ),
    );
    await repo.addPayment(
      payment(
        id: 'p3',
        dueDate: '2025-12-01',
        status: PaymentStatus.paid,
      ),
    );

    final changed = await repo.refreshUnpaidStatuses(
      now: DateTime(2026, 11, 2, 12),
    );

    expect(changed, greaterThanOrEqualTo(1));
    final all = await repo.getAllPayments();
    expect(
      all.firstWhere((p) => p.id == 'p1').status,
      PaymentStatus.overdue,
    );
    expect(
      all.firstWhere((p) => p.id == 'p3').status,
      PaymentStatus.paid,
    );
  });

  test('updatePaymentDueDate recalcula status de cuotas no pagadas', () async {
    final repo = LocalPaymentsRepository();
    await repo.addPayment(
      payment(
        id: 'p1',
        dueDate: '2026-11-30',
        status: PaymentStatus.pending,
        dueOption: DueDateOption.endOfMonth,
      ),
    );

    await repo.updatePaymentDueDate('p1', DueDateOption.startOfMonth);

    final updated = (await repo.getAllPayments()).first;
    expect(updated.dueDate, '2026-11-01');
    expect(updated.status, PaymentStatus.overdue);
  });
}
