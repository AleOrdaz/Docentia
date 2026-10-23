import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/whatsapp_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../payments/providers/payments_provider.dart';
import '../../payments/models/payment_model.dart';
import '../logic/finance_fees.dart';
import '../providers/finance_catalog_provider.dart';
import 'finance_ui.dart';

Future<void> showFinancePeriodPicker(
  BuildContext context,
  WidgetRef ref,
  List<Payment> payments,
) async {
  final current = ref.read(financeWindowProvider);
  final months = financeMonthOptions(payments);
  final choice = await showModalBottomSheet<Object>(
    context: context,
    backgroundColor: FinancePalette.card(Theme.of(context).brightness == Brightness.dark),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final month in months)
              ListTile(
                title: Text(financeMonthName(ctx, month.year, month.month)),
                trailing: !current.isRange && current.year == month.year && current.month == month.month
                    ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () => Navigator.of(ctx).pop(FinanceWindow.month(month.year, month.month)),
              ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: Text(l10n.financeDateRange),
              onTap: () => Navigator.of(ctx).pop('range'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
  if (!context.mounted || choice == null) return;
  if (choice is FinanceWindow) {
    ref.read(financeWindowProvider.notifier).state = choice;
    return;
  }
  final now = DateTime.now();
  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(now.year - 3),
    lastDate: DateTime(now.year + 1, 12, 31),
    locale: Localizations.localeOf(context),
  );
  if (range == null || !context.mounted) return;
  ref.read(financeWindowProvider.notifier).state = FinanceWindow.range(range.start, range.end);
}

Future<void> showFinanceFilters(BuildContext context, WidgetRef ref, FinanceCatalog catalog) async {
  final window = ref.read(financeWindowProvider);
  final query = ref.read(financeListQueryProvider);
  final result = await showModalBottomSheet<_FilterDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _FilterSheet(
      catalog: catalog,
      initialWindow: window,
      initialQuery: query,
    ),
  );
  if (result == null) return;
  ref.read(financeWindowProvider.notifier).state = result.window;
  ref.read(financeListQueryProvider.notifier).state = result.query;
}

class _FilterDraft {
  final FinanceWindow window;
  final FinanceListQuery query;

  const _FilterDraft(this.window, this.query);
}

class _FilterSheet extends StatefulWidget {
  final FinanceCatalog catalog;
  final FinanceWindow initialWindow;
  final FinanceListQuery initialQuery;

  const _FilterSheet({
    required this.catalog,
    required this.initialWindow,
    required this.initialQuery,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late FinanceWindow _window;
  late String? _courseId;
  late String? _studentId;
  late FinanceListStatus _status;

  @override
  void initState() {
    super.initState();
    _window = widget.initialWindow;
    _courseId = widget.initialQuery.courseId;
    _studentId = widget.initialQuery.studentId;
    _status = widget.initialQuery.status;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final months = financeMonthOptions(widget.catalog.payments);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 48),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      decoration: BoxDecoration(
        color: FinancePalette.card(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.financeFilters,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: FinancePalette.ink(isDark),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            _label(l10n.periodLabel, isDark),
            _box(
              isDark,
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _window.isRange ? 'range' : '${_window.year}-${_window.month}',
                  items: [
                    if (_window.isRange)
                      DropdownMenuItem(
                        value: 'range',
                        child: Text(financeWindowLabel(context, _window)),
                      ),
                    for (final month in months)
                      DropdownMenuItem(
                        value: '${month.year}-${month.month}',
                        child: Text(financeMonthName(context, month.year, month.month)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null || value == 'range') return;
                    final parts = value.split('-');
                    setState(() {
                      _window = FinanceWindow.month(int.parse(parts[0]), int.parse(parts[1]));
                    });
                  },
                ),
              ),
            ),
            _label(l10n.courseFallback, isDark),
            _box(
              isDark,
              DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _courseId,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.financeAllCourses)),
                    for (final course in widget.catalog.courses)
                      DropdownMenuItem(value: course.id, child: Text(course.name)),
                  ],
                  onChanged: (value) => setState(() => _courseId = value),
                ),
              ),
            ),
            _label(l10n.studentFallback, isDark),
            _box(
              isDark,
              DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _studentId,
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.financeAllStudents)),
                    for (final student in widget.catalog.students)
                      DropdownMenuItem(value: student.id, child: Text(student.fullName)),
                  ],
                  onChanged: (value) => setState(() => _studentId = value),
                ),
              ),
            ),
            _label(l10n.financeStatusField, isDark),
            _box(
              isDark,
              DropdownButtonHideUnderline(
                child: DropdownButton<FinanceListStatus>(
                  isExpanded: true,
                  value: _status,
                  items: [
                    DropdownMenuItem(value: FinanceListStatus.all, child: Text(l10n.financeAllStatuses)),
                    DropdownMenuItem(value: FinanceListStatus.pending, child: Text(l10n.pendingStatus)),
                    DropdownMenuItem(value: FinanceListStatus.upcoming, child: Text(l10n.financeUpcomingBadge)),
                    DropdownMenuItem(value: FinanceListStatus.overdue, child: Text(l10n.financeOverdue)),
                    DropdownMenuItem(value: FinanceListStatus.paid, child: Text(l10n.paidStatus)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      setState(() {
                        _window = FinanceWindow.month(now.year, now.month);
                        _courseId = null;
                        _studentId = null;
                        _status = FinanceListStatus.all;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: FinancePalette.border(isDark)),
                    ),
                    child: Text(l10n.financeClear),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(_FilterDraft(
                        _window,
                        FinanceListQuery(
                          courseId: _courseId,
                          studentId: _studentId,
                          status: _status,
                        ),
                      ));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(l10n.financeApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: FinancePalette.muted(isDark),
        ),
      ),
    );
  }

  Widget _box(bool isDark, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FinancePalette.border(isDark)),
      ),
      child: child,
    );
  }
}

Future<void> showRegisterPaymentSheet(BuildContext context, WidgetRef ref, List<FeeEntry> unpaid) async {
  final l10n = AppLocalizations.of(context)!;
  if (unpaid.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.financeNoUnpaid)));
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: FinancePalette.card(Theme.of(context).brightness == Brightness.dark),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.financeRegisterPayment,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: FinancePalette.ink(isDark),
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: unpaid.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: FinancePalette.border(isDark)),
                itemBuilder: (_, index) {
                  final entry = unpaid[index];
                  return FinancePaymentTile(
                    entry: entry,
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await registerFinancePayment(context, ref, entry);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> registerFinancePayment(BuildContext context, WidgetRef ref, FeeEntry entry) async {
  final l10n = AppLocalizations.of(context)!;
  final student = entry.studentName.isEmpty ? l10n.studentFallback : entry.studentName;
  final course = entry.courseName.isEmpty ? l10n.courseFallback : entry.courseName;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.confirmPayment),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(course),
          const SizedBox(height: 4),
          Text(entry.payment.period),
          const SizedBox(height: 12),
          Text(
            financeMoney(entry.payment.amount),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: FinancePalette.collected,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.financeRegisterPayment),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await ref.read(paymentsForCourseProvider(entry.payment.courseId).notifier).confirmPayment(
        entry.payment.id,
        paidAmount: entry.payment.amount,
        paidDate: DateTime.now(),
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.paymentConfirmed(financeMoney(entry.payment.amount), student))),
  );
}

Future<void> notifyTutor(BuildContext context, FeeEntry entry) async {
  final l10n = AppLocalizations.of(context)!;
  if (entry.tutorPhone.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.financeNoTutorPhone)));
    return;
  }
  final student = entry.studentName.isEmpty ? l10n.studentFallback : entry.studentName;
  final course = entry.courseName.isEmpty ? l10n.courseFallback : entry.courseName;
  final due = DateTime.tryParse(entry.payment.dueDate);
  final opened = await WhatsAppService.openWhatsApp(
    phone: entry.tutorPhone,
    message: l10n.financeReminderMessage(
      entry.tutorName.isEmpty ? l10n.studentFallback : entry.tutorName,
      student,
      course,
      entry.payment.period,
      financeMoney(entry.payment.amount),
      due == null ? entry.payment.dueDate : financeDay(context, due),
    ),
  );
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.whatsappOpenError)));
  }
}
