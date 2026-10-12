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

    test('Calculates exact due date for start of month and end of month (including leap years)', () {
      // Octubre (31 días)
      expect(Payment.calculateDueDate(2026, 10, DueDateOption.startOfMonth), '2026-10-01');
      expect(Payment.calculateDueDate(2026, 10, DueDateOption.endOfMonth), '2026-10-31');

      // Febrero año bisiesto 2024 (29 días)
      expect(Payment.calculateDueDate(2024, 2, DueDateOption.endOfMonth), '2024-02-29');

      // Febrero año no bisiesto 2025 (28 días)
      expect(Payment.calculateDueDate(2025, 2, DueDateOption.endOfMonth), '2025-02-28');

      // Noviembre (30 días)
      expect(Payment.calculateDueDate(2026, 11, DueDateOption.endOfMonth), '2026-11-30');
    });

    test('Single monthly fee rule: Prevents duplicate fee for same student, course, month and year', () {
      final payments = <Payment>[
        const Payment(
          id: 'pay-oct-1',
          studentId: 'student-1',
          courseId: 'course-matematicas',
          period: 'Octubre 2026',
          periodMonth: 10,
          periodYear: 2026,
          amount: 500.0,
          dueDate: '2026-10-31',
          status: PaymentStatus.pending,
        ),
      ];

      bool hasDuplicateFee(String studentId, String courseId, int year, int month) {
        return payments.any((p) =>
        p.studentId == studentId &&
            p.courseId == courseId &&
            p.periodYear == year &&
            p.periodMonth == month);
      }

      // Intentar agregar otra cuota para el mismo alumno, curso y mes (Octubre 2026) -> Debe bloquearse
      expect(hasDuplicateFee('student-1', 'course-matematicas', 2026, 10), isTrue);

      // Mismo alumno pero diferente mes (Noviembre 2026) -> Permitido
      expect(hasDuplicateFee('student-1', 'course-matematicas', 2026, 11), isFalse);

      // Mismo alumno y mismo mes pero diferente curso (Física) -> Permitido
      expect(hasDuplicateFee('student-1', 'course-fisica', 2026, 10), isFalse);

      // Diferente alumno en el mismo curso y mes -> Permitido
      expect(hasDuplicateFee('student-2', 'course-matematicas', 2026, 10), isFalse);
    });

    test('Changing due date option updates date in place without modifying amount or creating a second record', () {
      final original = const Payment(
        id: 'pay-1',
        studentId: 'student-1',
        courseId: 'course-1',
        period: 'Octubre 2026',
        periodMonth: 10,
        periodYear: 2026,
        amount: 4500.0,
        dueDate: '2026-10-31',
        dueOption: DueDateOption.endOfMonth,
        status: PaymentStatus.pending,
      );

      // Cambiar a inicio de mes
      final updated = original.copyWith(
        dueDate: Payment.calculateDueDate(original.periodYear, original.periodMonth, DueDateOption.startOfMonth),
        dueOption: DueDateOption.startOfMonth,
      );

      expect(updated.id, original.id);
      expect(updated.amount, 4500.0); // El importe permanece intacto
      expect(updated.dueDate, '2026-10-01'); // Actualizado a inicio de mes
      expect(updated.dueOption, DueDateOption.startOfMonth);
    });
  });
}
