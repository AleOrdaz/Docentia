import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../payments/models/payment_model.dart';
import '../logic/finance_fees.dart';
import '../providers/finance_catalog_provider.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/finance_ui.dart';

enum _ReportTab { income, course, compliance }

class FinanceReportsScreen extends ConsumerStatefulWidget {
  const FinanceReportsScreen({super.key});

  @override
  ConsumerState<FinanceReportsScreen> createState() => _FinanceReportsScreenState();
}

class _FinanceReportsScreenState extends ConsumerState<FinanceReportsScreen> {
  _ReportTab _tab = _ReportTab.income;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final catalog = ref.watch(financeCatalogProvider);
    final window = ref.watch(financeWindowProvider);

    return Scaffold(
      backgroundColor: FinancePalette.page(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        title: Text(l10n.financeReports, style: TextStyle(fontWeight: FontWeight.w800, color: primary)),
        actions: [
          catalog.maybeWhen(
            data: (data) => TextButton(
              onPressed: () => showFinancePeriodPicker(context, ref, data.payments),
              child: Text(
                financeWindowLabel(context, window, thisMonth: true),
                style: TextStyle(color: primary, fontWeight: FontWeight.w700),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
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
          final totals = financeTotals(data.payments, window);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              Row(
                children: [
                  _Tab(label: l10n.financeIncome, selected: _tab == _ReportTab.income, onTap: () => setState(() => _tab = _ReportTab.income)),
                  _Tab(label: l10n.financeByCourse, selected: _tab == _ReportTab.course, onTap: () => setState(() => _tab = _ReportTab.course)),
                  _Tab(label: l10n.financeCompliance, selected: _tab == _ReportTab.compliance, onTap: () => setState(() => _tab = _ReportTab.compliance)),
                ],
              ),
              const SizedBox(height: 14),
              if (_tab == _ReportTab.income) _IncomeChart(payments: data.payments, window: window, totals: totals),
              if (_tab == _ReportTab.course) _CourseBreakdown(catalog: data, window: window),
              if (_tab == _ReportTab.compliance) _Compliance(totals: totals),
            ],
          );
        },
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : FinancePalette.muted(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomeChart extends StatelessWidget {
  final List<Payment> payments;
  final FinanceWindow window;
  final FinanceTotals totals;

  const _IncomeChart({required this.payments, required this.window, required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final months = chartMonths(window);
    final values = [for (final month in months) collectedInMonth(payments, month)];
    final maxValue = values.fold<double>(0, math.max);
    final scale = _niceMax(maxValue);
    final locale = Localizations.localeOf(context).toString();

    return FinanceSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.financeIncomeByMonth, style: TextStyle(color: FinancePalette.muted(isDark))),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  financeMoney(totals.collected),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: FinancePalette.ink(isDark)),
                ),
                const SizedBox(width: 8),
                if (totals.changePercent != null)
                  Text(
                    '${totals.changePercent! >= 0 ? '+' : ''}${totals.changePercent}%',
                    style: TextStyle(
                      color: totals.changePercent! >= 0 ? FinancePalette.collected : FinancePalette.overdue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < months.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                            child: values[i] <= 0
                                ? const SizedBox(width: 18)
                                : FractionallySizedBox(
                                    heightFactor: (values[i] / scale).clamp(0.04, 1.0),
                                    child: Container(
                                      width: 18,
                                      decoration: BoxDecoration(
                                        color: months[i].year == window.anchor.year && months[i].month == window.anchor.month
                                            ? primary
                                            : primary.withValues(alpha: 0.28),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat.MMM(locale).format(months[i]).replaceAll('.', ''),
                              style: TextStyle(fontSize: 11, color: FinancePalette.muted(isDark)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _niceMax(double value) {
    if (value <= 0) return 1;
    final power = math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
    final fraction = value / power;
    final nice = fraction <= 1 ? 1 : fraction <= 2 ? 2 : fraction <= 5 ? 5 : 10;
    return nice * power;
  }
}

class _CourseBreakdown extends StatelessWidget {
  final FinanceCatalog catalog;
  final FinanceWindow window;

  const _CourseBreakdown({required this.catalog, required this.window});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final amounts = <String, double>{};
    for (final entry in catalog.entries) {
      if (!window.includes(entry.payment) || entry.payment.status != PaymentStatus.paid) continue;
      final name = entry.courseName.isEmpty ? l10n.courseFallback : entry.courseName;
      amounts[name] = (amounts[name] ?? 0) + (entry.payment.paidAmount ?? entry.payment.amount);
    }
    if (amounts.isEmpty) {
      return FinanceStateMessage(
        icon: Icons.bar_chart_rounded,
        iconColor: primary,
        iconBackground: primary.withValues(alpha: 0.12),
        title: l10n.financeByCourse,
        description: l10n.financeNoCourseIncome,
      );
    }
    final maxValue = amounts.values.fold<double>(0, math.max);
    final rows = amounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return FinanceSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (final row in rows) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(row.key, style: TextStyle(fontWeight: FontWeight.w600, color: FinancePalette.ink(isDark))),
                  ),
                  Text(financeMoney(row.value), style: TextStyle(fontWeight: FontWeight.w700, color: FinancePalette.ink(isDark))),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: maxValue == 0 ? 0 : row.value / maxValue,
                  minHeight: 8,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  color: primary,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _Compliance extends StatelessWidget {
  final FinanceTotals totals;

  const _Compliance({required this.totals});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parts = [
      (l10n.financeCollected, totals.collected, FinancePalette.collected),
      (l10n.financeToCollect, totals.toCollect, FinancePalette.toCollect),
      (l10n.financeOverdue, totals.overdue, FinancePalette.overdue),
      (l10n.financeUpcoming, totals.upcoming, FinancePalette.upcoming),
    ];
    final total = parts.fold<double>(0, (sum, part) => sum + part.$2);

    return FinanceSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                height: 12,
                child: total <= 0
                    ? Container(color: FinancePalette.border(isDark))
                    : Row(
                        children: [
                          for (final part in parts)
                            if (part.$2 > 0)
                              Expanded(
                                flex: math.max(1, part.$2.round()),
                                child: Container(color: part.$3),
                              ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            for (final part in parts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: part.$3, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(part.$1, style: TextStyle(color: FinancePalette.ink(isDark)))),
                    Text(financeMoney(part.$2), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
