import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../payments/models/payment_model.dart';
import '../logic/finance_fees.dart';
import '../providers/finance_catalog_provider.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/finance_ui.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(financeCatalogProvider);
    final window = ref.watch(financeWindowProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: FinancePalette.page(isDark),
      body: SafeArea(
        bottom: false,
        child: catalog.when(
          loading: () => const _FinanceSkeleton(),
          error: (_, __) => _FinanceError(
            onRetry: () => reloadFinance(ref),
          ),
          data: (data) {
            return ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, AppBottomNavBar.reservedHeight(context)),
              children: [
                _FinanceHeader(
                  window: window,
                  onPickPeriod: () => showFinancePeriodPicker(context, ref, data.payments),
                ),
                const SizedBox(height: 16),
                if (data.payments.isEmpty)
                  FinanceStateMessage(
                    icon: Icons.person_outline,
                    iconColor: FinancePalette.muted(isDark),
                    iconBackground: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F7),
                    title: AppLocalizations.of(context)!.financeNoPaymentsTitle,
                    description: AppLocalizations.of(context)!.financeNoPaymentsDesc,
                  )
                else
                  _Dashboard(catalog: data, window: window),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  final FinanceCatalog catalog;
  final FinanceWindow window;

  const _Dashboard({required this.catalog, required this.window});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final totals = financeTotals(catalog.payments, window);
    final dues = upcomingDues(catalog.payments, window);
    final dueEntries = [
      for (final payment in dues)
        catalog.entries.firstWhere((entry) => entry.payment.id == payment.id),
    ];
    final unpaid = catalog.entries.where((entry) {
      if (!window.includes(entry.payment)) return false;
      return entry.payment.status != PaymentStatus.paid;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _MetricCard(
                  amount: financeMoney(totals.collected),
                  label: l10n.financeCollected,
                  color: FinancePalette.collected,
                  background: FinancePalette.collectedBg(isDark),
                  icon: Icons.account_balance_wallet_outlined,
                  footnote: totals.changePercent == null
                      ? null
                      : _ChangeFootnote(percent: totals.changePercent!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  amount: financeMoney(totals.toCollect),
                  label: l10n.financeToCollect,
                  color: FinancePalette.toCollect,
                  background: FinancePalette.toCollectBg(isDark),
                  icon: Icons.account_balance_wallet_outlined,
                  footnote: Text(
                    financeFeeCount(l10n, totals.toCollectCount),
                    style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _MetricCard(
                  amount: financeMoney(totals.overdue),
                  label: l10n.financeOverdue,
                  color: FinancePalette.overdue,
                  background: FinancePalette.overdueBg(isDark),
                  icon: Icons.payments_outlined,
                  footnote: Text(
                    financeFeeCount(l10n, totals.overdueCount),
                    style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricCard(
                  amount: financeMoney(totals.upcoming),
                  label: l10n.financeUpcoming,
                  color: FinancePalette.upcoming,
                  background: FinancePalette.upcomingBg(isDark),
                  icon: Icons.calendar_month_outlined,
                  footnote: Text(
                    financeFeeCount(l10n, totals.upcomingCount),
                    style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.financeQuickAccess,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: FinancePalette.ink(isDark),
          ),
        ),
        const SizedBox(height: 10),
        FinanceSectionCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _QuickAction(
                  icon: Icons.edit_note_outlined,
                  label: l10n.financeRegisterPayment,
                  onTap: () => showRegisterPaymentSheet(context, ref, unpaid),
                ),
                _QuickAction(
                  icon: Icons.notifications_none,
                  label: l10n.financeReminders,
                  onTap: () => context.push('/finance/reminders'),
                ),
                _QuickAction(
                  icon: Icons.bar_chart_rounded,
                  label: l10n.financeReports,
                  onTap: () => context.push('/finance/reports'),
                ),
                _QuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.financeExpenses,
                  onTap: () => context.push('/finance/expenses'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.financeUpcomingDues,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: FinancePalette.ink(isDark),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/finance/payments'),
              child: Text(
                l10n.financeSeeAll,
                style: TextStyle(color: primary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        FinanceSectionCard(
          child: dueEntries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    l10n.financeNoPeriodDues,
                    style: TextStyle(color: FinancePalette.muted(isDark)),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < dueEntries.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: FinancePalette.border(isDark)),
                      FinancePaymentTile(
                        entry: dueEntries[i],
                        onTap: () => context.push('/finance/payment/${dueEntries[i].payment.id}'),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _FinanceHeader extends StatelessWidget {
  final FinanceWindow window;
  final VoidCallback onPickPeriod;

  const _FinanceHeader({required this.window, required this.onPickPeriod});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.navFinance,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.financeScreenSubtitle,
                style: TextStyle(fontSize: 13, color: FinancePalette.muted(isDark)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _PeriodButton(label: financeWindowLabel(context, window), onTap: onPickPeriod),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PeriodButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String amount;
  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final Widget? footnote;

  const _MetricCard({
    required this.amount,
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FinanceSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                  ),
                  if (footnote != null) footnote!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeFootnote extends StatelessWidget {
  final int percent;

  const _ChangeFootnote({required this.percent});

  @override
  Widget build(BuildContext context) {
    final positive = percent >= 0;
    final color = positive ? FinancePalette.collected : FinancePalette.overdue;
    final prefix = positive ? '+' : '';
    return Row(
      children: [
        Icon(
          positive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: color,
        ),
        Text(
          '$prefix$percent%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: primary, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceError extends StatelessWidget {
  final VoidCallback onRetry;

  const _FinanceError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, AppBottomNavBar.reservedHeight(context)),
      children: [
        Text(
          l10n.navFinance,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        FinanceStateMessage(
          icon: Icons.error_outline,
          iconColor: FinancePalette.overdue,
          iconBackground: FinancePalette.overdueBg(Theme.of(context).brightness == Brightness.dark),
          title: l10n.financeLoadErrorTitle,
          description: l10n.financeLoadErrorDesc,
          actionLabel: l10n.financeRetry,
          onAction: onRetry,
        ),
      ],
    );
  }
}

class _FinanceSkeleton extends StatelessWidget {
  const _FinanceSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bone = isDark ? const Color(0xFF22304A) : const Color(0xFFE6EDF5);
    Widget block({double height = 72}) => Container(
          height: height,
          decoration: BoxDecoration(
            color: FinancePalette.card(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: bone),
          ),
        );
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, AppBottomNavBar.reservedHeight(context)),
      children: [
        Container(height: 28, width: 140, color: bone),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: block()), const SizedBox(width: 8), Expanded(child: block())]),
        const SizedBox(height: 8),
        Row(children: [Expanded(child: block()), const SizedBox(width: 8), Expanded(child: block())]),
        const SizedBox(height: 16),
        block(height: 88),
        const SizedBox(height: 16),
        block(height: 180),
      ],
    );
  }
}
