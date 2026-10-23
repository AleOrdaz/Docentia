import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/models/course_model.dart';
import '../logic/finance_fees.dart';
import '../models/expense_model.dart';
import '../providers/finance_catalog_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/finance_ui.dart';

class FinanceExpensesScreen extends ConsumerStatefulWidget {
  const FinanceExpensesScreen({super.key});

  @override
  ConsumerState<FinanceExpensesScreen> createState() => _FinanceExpensesScreenState();
}

class _FinanceExpensesScreenState extends ConsumerState<FinanceExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String? _courseId;
  String _category = 'Materiales';
  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final window = ref.watch(financeWindowProvider);
    final catalog = ref.watch(financeCatalogProvider);
    final expenses = ref.watch(expensesProvider);
    final courses = catalog.value?.courses ?? const <Course>[];
    _courseId ??= courses.isEmpty ? null : courses.first.id;
    final selectedDate = _date ?? _defaultDate(window);
    final collected = catalog.value == null ? 0.0 : financeTotals(catalog.value!.payments, window).collected;
    final spent = expensesTotal(expenses, window);
    final profit = realProfit(collected, spent);
    final visible = expenses.where((expense) => expenseInWindow(expense, window)).toList();

    return Scaffold(
      backgroundColor: FinancePalette.page(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        title: Text(
          l10n.financeExpenses,
          style: TextStyle(fontWeight: FontWeight.w800, color: primary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          FinanceSectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.financeRealProfit, style: TextStyle(color: FinancePalette.muted(isDark))),
                  const SizedBox(height: 4),
                  Text(
                    financeMoney(profit),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: profit >= 0 ? FinancePalette.collected : FinancePalette.overdue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.financeRealProfitHint,
                    style: TextStyle(fontSize: 12, height: 1.35, color: FinancePalette.muted(isDark)),
                  ),
                  const SizedBox(height: 12),
                  _AmountLine(label: l10n.financeCollected, value: financeMoney(collected), color: FinancePalette.collected),
                  const SizedBox(height: 4),
                  _AmountLine(label: l10n.financeExpenses, value: financeMoney(spent), color: FinancePalette.overdue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (courses.isEmpty)
            FinanceStateMessage(
              icon: Icons.school_outlined,
              iconColor: primary,
              iconBackground: primary.withValues(alpha: 0.12),
              title: l10n.financeExpenses,
              description: l10n.financeNoCoursesForExpense,
            )
          else
            FinanceSectionCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppFieldLabel(l10n.courseFallback),
                      const SizedBox(height: 4),
                      _DropdownBox(
                        child: DropdownButtonFormField<String>(
                          initialValue: _courseId,
                          isExpanded: true,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          items: [
                            for (final course in courses)
                              DropdownMenuItem(value: course.id, child: Text(course.name)),
                          ],
                          onChanged: (value) => setState(() => _courseId = value),
                          validator: (value) => value == null ? l10n.financePickCourse : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: l10n.expenseDescriptionLabel,
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) => value == null || value.trim().isEmpty ? l10n.required : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: l10n.amountDollarLabel,
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) return l10n.required;
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppFieldLabel(l10n.financeExpenseCategory),
                      const SizedBox(height: 4),
                      _DropdownBox(
                        child: DropdownButtonFormField<String>(
                          initialValue: _category,
                          isExpanded: true,
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                          items: [
                            DropdownMenuItem(value: 'Materiales', child: Text(l10n.categoryMaterials)),
                            DropdownMenuItem(value: 'Software', child: Text(l10n.categorySoftware)),
                            DropdownMenuItem(value: 'Insumos', child: Text(l10n.categorySupplies)),
                            DropdownMenuItem(value: 'Transporte', child: Text(l10n.categoryTransport)),
                            DropdownMenuItem(value: 'Varios', child: Text(l10n.categoryMisc)),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _category = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppFieldLabel(l10n.dateLabel),
                      const SizedBox(height: 4),
                      _DropdownBox(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(DateTime.now().year - 3),
                              lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                            );
                            if (picked != null) setState(() => _date = picked);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 18, color: FinancePalette.muted(isDark)),
                                const SizedBox(width: 8),
                                Text(
                                  financeDay(context, selectedDate),
                                  style: TextStyle(color: FinancePalette.ink(isDark)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: l10n.addExpenseBtn,
                        icon: Icons.add,
                        loading: _saving,
                        onPressed: () => _save(selectedDate),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            l10n.financeExpenses,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FinancePalette.ink(isDark)),
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            Text(
              l10n.financeNoExpensesPeriod,
              style: TextStyle(color: FinancePalette.muted(isDark)),
            )
          else
            FinanceSectionCard(
              child: Column(
                children: [
                  for (var i = 0; i < visible.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: FinancePalette.border(isDark)),
                    _ExpenseRow(expense: visible[i], courses: courses),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _save(DateTime date) async {
    if (!_formKey.currentState!.validate() || _courseId == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    await ref.read(expensesProvider.notifier).addExpense(
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          category: _category,
          courseId: _courseId,
          date: date,
        );
    if (!mounted) return;
    _descriptionController.clear();
    _amountController.clear();
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.financeExpenseSaved)));
  }
}

DateTime _defaultDate(FinanceWindow window) {
  final today = DateTime.now();
  final day = DateTime(today.year, today.month, today.day);
  if (!window.isRange && day.year == window.year && day.month == window.month) return day;
  if (window.isRange) {
    final start = DateTime(window.rangeStart!.year, window.rangeStart!.month, window.rangeStart!.day);
    final end = DateTime(window.rangeEnd!.year, window.rangeEnd!.month, window.rangeEnd!.day);
    if (!day.isBefore(start) && !day.isAfter(end)) return day;
    return start;
  }
  return DateTime(window.year!, window.month!, 1);
}

class _DropdownBox extends StatelessWidget {
  final Widget child;

  const _DropdownBox({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A42) : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FinancePalette.border(isDark)),
      ),
      child: child,
    );
  }
}

class _AmountLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AmountLine({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: FinancePalette.muted(isDark)))),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  final List<Course> courses;

  const _ExpenseRow({required this.expense, required this.courses});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseName = courses
            .where((course) => course.id == expense.courseId)
            .map((course) => course.name)
            .firstOrNull ??
        l10n.courseFallback;
    final date = DateTime.tryParse(expense.date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: TextStyle(fontWeight: FontWeight.w700, color: FinancePalette.ink(isDark)),
                ),
                Text(
                  '$courseName · ${_categoryLabel(l10n, expense.category)}',
                  style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                ),
                if (date != null)
                  Text(
                    financeDay(context, date),
                    style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                  ),
              ],
            ),
          ),
          Text(
            '-${financeMoney(expense.amount)}',
            style: const TextStyle(fontWeight: FontWeight.w800, color: FinancePalette.overdue),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Materiales':
      return l10n.categoryMaterials;
    case 'Software':
      return l10n.categorySoftware;
    case 'Insumos':
      return l10n.categorySupplies;
    case 'Transporte':
      return l10n.categoryTransport;
    case 'Varios':
      return l10n.categoryMisc;
    default:
      return category;
  }
}
