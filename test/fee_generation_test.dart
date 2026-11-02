import 'package:flutter_test/flutter_test.dart';
import 'package:docentia/features/courses/models/course_model.dart';
import 'package:docentia/features/payments/services/fee_generation_service.dart';

void main() {
  group('FeeCycle', () {
    test('first half bills on the 15th and end of month uses the last day', () {
      expect(
        FeeCycle.billingDate(PaymentSchedule.firstHalf, 2026, 10),
        DateTime(2026, 10, 15),
      );
      expect(
        FeeCycle.billingDate(PaymentSchedule.endOfMonth, 2026, 10),
        DateTime(2026, 10, 31),
      );
      expect(
        FeeCycle.billingDate(PaymentSchedule.endOfMonth, 2026, 2),
        DateTime(2026, 2, 28),
      );
    });

    test('next billing stays in the current month before the due day', () {
      expect(
        FeeCycle.nextBillingDate(PaymentSchedule.firstHalf, DateTime(2026, 10, 10)),
        DateTime(2026, 10, 15),
      );
      expect(
        FeeCycle.nextBillingDate(PaymentSchedule.endOfMonth, DateTime(2026, 10, 20)),
        DateTime(2026, 10, 31),
      );
    });

    test('next billing moves to the following month on or after the due day', () {
      expect(
        FeeCycle.nextBillingDate(PaymentSchedule.firstHalf, DateTime(2026, 10, 15)),
        DateTime(2026, 11, 15),
      );
      expect(
        FeeCycle.nextBillingDate(PaymentSchedule.endOfMonth, DateTime(2026, 10, 31)),
        DateTime(2026, 11, 30),
      );
    });

    test('prorated amount uses remaining days until the next charge', () {
      final amount = FeeCycle.proratedAmount(
        monthlyCost: 30000,
        schedule: PaymentSchedule.endOfMonth,
        from: DateTime(2026, 10, 21),
      );
      // 10 days left (21 → 31) over a 31-day cycle (30 Sep → 31 Oct)
      expect(amount, closeTo(30000 * 10 / 31, 0.01));
    });

    test('prorated amount is zero on the billing day', () {
      expect(
        FeeCycle.proratedAmount(
          monthlyCost: 30000,
          schedule: PaymentSchedule.firstHalf,
          from: DateTime(2026, 10, 15),
        ),
        0,
      );
    });

    test('prepaid due periods charge the next service month after billing day', () {
      final periods = FeeCycle.duePeriods(
        PaymentSchedule.firstHalf,
        DateTime(2026, 10, 16),
      );
      // Billing 15 Oct → Nov; billing 15 Sep → Oct
      expect(periods.map((p) => p.month), containsAll([11, 10]));
      expect(
        periods.firstWhere((p) => p.month == 11).billingDate,
        DateTime(2026, 10, 15),
      );
    });

    test('prepaid due periods skip unreached billing days', () {
      final periods = FeeCycle.duePeriods(
        PaymentSchedule.firstHalf,
        DateTime(2026, 10, 10),
      );
      // Only Sep 15 billing has passed → service month Oct
      expect(periods.map((p) => p.month), contains(10));
      expect(periods.map((p) => p.month), isNot(contains(11)));
    });

    test('service period for billing is the following month', () {
      expect(
        FeeCycle.servicePeriodForBilling(DateTime(2026, 10, 31)),
        DateTime(2026, 11, 1),
      );
      expect(
        FeeCycle.servicePeriodForBilling(DateTime(2026, 12, 15)),
        DateTime(2027, 1, 1),
      );
    });

    test('students created after the billing day are not auto-enrolled', () {
      expect(
        FeeCycle.wasEnrolledOn(DateTime(2026, 10, 16), DateTime(2026, 10, 15)),
        isFalse,
      );
      expect(
        FeeCycle.wasEnrolledOn(DateTime(2026, 10, 15), DateTime(2026, 10, 15)),
        isTrue,
      );
    });
  });
}
