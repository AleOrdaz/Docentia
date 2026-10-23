import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/expense_model.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../courses/providers/courses_provider.dart';

enum FinancePeriod { currentMonth, previousMonth, allTime }

final selectedPeriodProvider = StateProvider<FinancePeriod>((ref) => FinancePeriod.currentMonth);

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  ExpensesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final list = await StorageService.getExpenses();
    state = list;
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required String category,
    String? courseId,
    DateTime? date,
  }) async {
    final when = date ?? DateTime.now();
    final dateStr = '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
    final newExp = Expense(
      id: 'exp-${when.millisecondsSinceEpoch}',
      teacherId: 'teacher-1',
      description: description,
      amount: amount,
      date: dateStr,
      category: category,
      courseId: courseId,
    );
    final updated = [newExp, ...state];
    state = updated;
    await StorageService.saveExpenses(updated);
  }
}

final expensesProvider = StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  return ExpensesNotifier();
});

class FinanceSummary {
  final double totalIncome;
  final double pendingIncome;
  final double totalExpenses;
  final double netProfit;
  final int profitMargin;

  const FinanceSummary({
    required this.totalIncome,
    required this.pendingIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
  });
}

final financeSummaryProvider = Provider<FinanceSummary>((ref) {
  final period = ref.watch(selectedPeriodProvider);
  final allExpenses = ref.watch(expensesProvider);
  final courses = ref.watch(coursesProvider).value ?? [];

  final List<Payment> allPayments = [];
  for (final course in courses) {
    final payments = ref.watch(paymentsForCourseProvider(course.id)).value ?? [];
    allPayments.addAll(payments);
  }

  final now = DateTime.now();
  final currentMonthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  final prevMonthDate = DateTime(now.year, now.month - 1, 1);
  final prevMonthStr = '${prevMonthDate.year}-${prevMonthDate.month.toString().padLeft(2, '0')}';

  List<Payment> filteredPayments;
  List<Expense> filteredExpenses;

  switch (period) {
    case FinancePeriod.currentMonth:
      filteredPayments = allPayments.where((p) => p.dueDate.startsWith(currentMonthStr)).toList();
      filteredExpenses = allExpenses.where((e) => e.date.startsWith(currentMonthStr)).toList();
      break;
    case FinancePeriod.previousMonth:
      filteredPayments = allPayments.where((p) => p.dueDate.startsWith(prevMonthStr)).toList();
      filteredExpenses = allExpenses.where((e) => e.date.startsWith(prevMonthStr)).toList();
      break;
    case FinancePeriod.allTime:
      filteredPayments = allPayments;
      filteredExpenses = allExpenses;
      break;
  }

  final totalIncome = filteredPayments
      .where((p) => p.status == PaymentStatus.paid)
      .fold<double>(0.0, (sum, p) => sum + (p.paidAmount ?? p.amount));

  final pendingIncome = filteredPayments
      .where((p) => p.status != PaymentStatus.paid)
      .fold<double>(0.0, (sum, p) => sum + p.amount);

  final totalExpenses = filteredExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
  final netProfit = totalIncome - totalExpenses;
  final margin = totalIncome > 0 ? ((netProfit / totalIncome) * 100).round() : 0;

  return FinanceSummary(
    totalIncome: totalIncome,
    pendingIncome: pendingIncome,
    totalExpenses: totalExpenses,
    netProfit: netProfit,
    profitMargin: margin,
  );
});
