import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/providers/courses_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../students/providers/students_provider.dart';
import '../logic/finance_fees.dart';
import '../providers/finance_catalog_provider.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/finance_ui.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final catalog = ref.watch(financeCatalogProvider);

    return Scaffold(
      backgroundColor: FinancePalette.page(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        title: Text(
          l10n.financePaymentDetail,
          style: TextStyle(fontWeight: FontWeight.w800, color: primary),
        ),
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => Padding(
          padding: const EdgeInsets.all(16),
          child: FinanceStateMessage(
            icon: Icons.error_outline,
            iconColor: FinancePalette.overdue,
            iconBackground: FinancePalette.overdueBg(isDark),
            title: l10n.financeLoadErrorTitle,
            description: l10n.financeLoadErrorDesc,
            actionLabel: l10n.financeRetry,
            onAction: () => reloadFinance(ref),
          ),
        ),
        data: (data) {
          FeeEntry? entry;
          for (final item in data.entries) {
            if (item.payment.id == paymentId) entry = item;
          }
          if (entry == null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: FinanceStateMessage(
                icon: Icons.search_off_outlined,
                iconColor: primary,
                iconBackground: primary.withValues(alpha: 0.12),
                title: l10n.financeNoResultsTitle,
                description: l10n.financeNoResultsDesc,
              ),
            );
          }
          return _DetailBody(entry: entry);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  final FeeEntry entry;

  const _DetailBody({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final payment = entry.payment;
    final student = entry.studentName.isEmpty ? l10n.studentFallback : entry.studentName;
    final courseName = entry.courseName.isEmpty ? l10n.courseFallback : entry.courseName;
    final due = DateTime.tryParse(payment.dueDate);
    final today = DateTime.now();
    final dueIsLate = due != null &&
        DateTime(due.year, due.month, due.day).isBefore(DateTime(today.year, today.month, today.day));
    final movements = feeMovements(payment);
    final canRegister = payment.status != PaymentStatus.paid;
    final locale = Localizations.localeOf(context).toString();
    final period = payment.period.isEmpty
        ? Payment.formatPeriodName(payment.periodYear, payment.periodMonth, locale)
        : payment.period;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        FinanceSectionCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FinanceAvatar(initials: entry.initials, seed: payment.studentId, size: 46),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: FinancePalette.ink(isDark),
                            ),
                          ),
                          Text(
                            courseName,
                            style: TextStyle(color: FinancePalette.muted(isDark)),
                          ),
                        ],
                      ),
                    ),
                    if (entry.student != null)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: FinancePalette.ink(isDark)),
                        onSelected: (value) {
                          if (value == 'student') {
                            ref.read(selectedStudentIdProvider.notifier).state = entry.student!.id;
                            context.push('/student-detail/${entry.student!.id}');
                          } else if (value == 'pay') {
                            registerFinancePayment(context, ref, entry);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(value: 'student', child: Text(l10n.financeViewStudent)),
                          if (canRegister)
                            PopupMenuItem(value: 'pay', child: Text(l10n.financeRegisterPayment)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FinanceStatusBadge(status: payment.status),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _Fact(label: l10n.financeFeeLabel, value: financeMoney(payment.amount), emphasize: true)),
                    Expanded(child: _Fact(label: l10n.periodLabel, value: period)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Fact(
                        label: l10n.financeIssueDate,
                        value: financeDay(context, feeIssueDate(payment)),
                      ),
                    ),
                    Expanded(
                      child: _Fact(
                        label: l10n.financeDueDateLabel,
                        value: due == null ? payment.dueDate : financeDay(context, due),
                        valueColor: dueIsLate || payment.status == PaymentStatus.overdue
                            ? FinancePalette.overdue
                            : null,
                      ),
                    ),
                  ],
                ),
                if (canRegister) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => registerFinancePayment(context, ref, entry),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.credit_score_outlined, size: 18),
                    label: Text(l10n.financeRegisterPayment),
                  ),
                ],
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => notifyTutor(context, entry),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary.withValues(alpha: 0.12),
                    foregroundColor: primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: Text(l10n.financeNotifyParents),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.financeCourseInfo,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FinancePalette.ink(isDark)),
        ),
        const SizedBox(height: 8),
        FinanceSectionCard(
          child: ListTile(
            onTap: entry.course == null
                ? null
                : () {
                    ref.read(selectedCourseIdProvider.notifier).state = entry.course!.id;
                    context.push('/course-detail/${entry.course!.id}');
                  },
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: getCourseIconColors(entry.course?.iconKey).background(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getCourseIcon(entry.course?.iconKey),
                color: getCourseIconColors(entry.course?.iconKey).icon(isDark),
                size: 20,
              ),
            ),
            title: Text(
              courseName,
              style: TextStyle(fontWeight: FontWeight.w700, color: FinancePalette.ink(isDark)),
            ),
            subtitle: entry.course == null
                ? null
                : Text(
                    entry.course!.getLocalizedSchedule(context),
                    style: TextStyle(color: FinancePalette.muted(isDark)),
                  ),
            trailing: Icon(Icons.chevron_right, color: FinancePalette.muted(isDark)),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.financeMovementHistory,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: FinancePalette.ink(isDark)),
        ),
        const SizedBox(height: 8),
        if (movements.isEmpty)
          FinanceStateMessage(
            icon: Icons.receipt_long_outlined,
            iconColor: FinancePalette.muted(isDark),
            iconBackground: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F7),
            title: l10n.financeNoMovements,
            description: l10n.financeNoMovementsDesc,
          )
        else
          FinanceSectionCard(
            child: Column(
              children: [
                for (final movement in movements) _MovementRow(movement: movement),
              ],
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  const _Fact({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 20 : 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? FinancePalette.ink(isDark),
          ),
        ),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  final FeeMovement movement;

  const _MovementRow({required this.movement});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color, label) = switch (movement.kind) {
      FeeMovementKind.paid => (Icons.check_circle, FinancePalette.collected, l10n.financeMovementPaid),
      FeeMovementKind.generated => (Icons.description_outlined, FinancePalette.muted(isDark), l10n.financeMovementGenerated),
      FeeMovementKind.overdue => (Icons.schedule, FinancePalette.overdue, l10n.financeMovementOverdue),
    };
    final when = movement.hasTime ? financeDayTime(context, movement.date) : financeDay(context, movement.date);
    final amount = movement.amount == null
        ? '—'
        : movement.kind == FeeMovementKind.paid
            ? '+${financeMoney(movement.amount!)}'
            : financeMoney(movement.amount!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: FinancePalette.ink(isDark))),
                Text(when, style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark))),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: movement.kind == FeeMovementKind.paid ? FinancePalette.collected : FinancePalette.muted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
