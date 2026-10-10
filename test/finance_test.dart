import 'package:flutter_test/flutter_test.dart';
import 'package:docentia/features/finance/models/expense_model.dart';
import 'package:docentia/features/payments/models/payment_model.dart';

void main() {
  group('Finance Calculations Tests', () {
    test('Calculates net profit as total income minus expenses', () {
      final payments = [
        Payment(
          id: 'p1',
          studentId: 's1',
          courseId: 'c1',
          amount: 45000,
          dueDate: '2026-09-15',
          status: PaymentStatus.paid,
        ),
        Payment(
          id: 'p2',
          studentId: 's2',
          courseId: 'c1',
          amount: 45000,
          dueDate: '2026-09-15',
          status: PaymentStatus.paid,
        ),
        Payment(
          id: 'p3',
          studentId: 's3',
          courseId: 'c1',
          amount: 45000,
          dueDate: '2026-09-15',
          status: PaymentStatus.pending,
        ),
      ];

      final expenses = [
        const Expense(
          id: 'e1',
          teacherId: 't1',
          description: 'Libros',
          amount: 30000,
          date: '2026-09-10',
          category: 'Materiales',
        ),
      ];

      final totalIncome = payments
          .where((p) => p.status == PaymentStatus.paid)
          .fold<double>(0.0, (sum, p) => sum + p.amount);

      final totalExpenses = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      final netProfit = totalIncome - totalExpenses;

      expect(totalIncome, 90000);
      expect(totalExpenses, 30000);
      expect(netProfit, 60000);
    });
  });
}
