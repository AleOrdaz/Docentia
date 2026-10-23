import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../payments/models/payment_model.dart';
import '../logic/finance_fees.dart';
import '../providers/finance_catalog_provider.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/finance_ui.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  const PaymentListScreen({super.key});

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catalog = ref.watch(financeCatalogProvider);
    final window = ref.watch(financeWindowProvider);
    final query = ref.watch(financeListQueryProvider);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: FinancePalette.page(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primary,
        title: Text(
          l10n.navFinance,
          style: TextStyle(fontWeight: FontWeight.w800, color: primary),
        ),
        actions: [
          catalog.maybeWhen(
            data: (data) => _PeriodButton(
              label: financeWindowLabel(context, window),
              onTap: () => showFinancePeriodPicker(context, ref, data.payments),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: _ListSkeleton()),
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
          final searched = data.entries.where((entry) {
            if (!window.includes(entry.payment)) return false;
            if (query.courseId != null && entry.payment.courseId != query.courseId) return false;
            if (query.studentId != null && entry.payment.studentId != query.studentId) return false;
            return _matchesSearch(entry, _search.text);
          }).toList();
          final visible = searched.where((entry) => query.matches(entry.payment)).toList();
          int count(PaymentStatus status) =>
              searched.where((entry) => entry.payment.status == status).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.financeSearchHint,
                          hintStyle: TextStyle(color: FinancePalette.muted(isDark), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: FinancePalette.muted(isDark)),
                          filled: true,
                          fillColor: FinancePalette.card(isDark),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: FinancePalette.border(isDark)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: FinancePalette.border(isDark)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: FinancePalette.card(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: FinancePalette.border(isDark)),
                      ),
                      child: IconButton(
                        tooltip: l10n.financeFilters,
                        onPressed: () => showFinanceFilters(context, ref, data),
                        icon: Icon(
                          Icons.tune,
                          color: query.isDefault ? FinancePalette.muted(isDark) : primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _StatusChip(
                      label: '${l10n.filterAll} (${searched.length})',
                      selected: query.status == FinanceListStatus.all,
                      onTap: () => _setStatus(FinanceListStatus.all),
                    ),
                    _StatusChip(
                      label: '${l10n.financeFilterPending} (${count(PaymentStatus.pending)})',
                      selected: query.status == FinanceListStatus.pending,
                      onTap: () => _setStatus(FinanceListStatus.pending),
                    ),
                    _StatusChip(
                      label: '${l10n.financeFilterOverdue} (${count(PaymentStatus.overdue)})',
                      selected: query.status == FinanceListStatus.overdue,
                      onTap: () => _setStatus(FinanceListStatus.overdue),
                    ),
                    _StatusChip(
                      label: '${l10n.financeFilterPaid} (${count(PaymentStatus.paid)})',
                      selected: query.status == FinanceListStatus.paid,
                      onTap: () => _setStatus(FinanceListStatus.paid),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: FinanceStateMessage(
                          icon: Icons.search_off_outlined,
                          iconColor: primary,
                          iconBackground: primary.withValues(alpha: 0.12),
                          title: l10n.financeNoResultsTitle,
                          description: l10n.financeNoResultsDesc,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final entry = visible[index];
                          return FinanceSectionCard(
                            child: FinancePaymentTile(
                              entry: entry,
                              onTap: () => context.push('/finance/payment/${entry.payment.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _setStatus(FinanceListStatus status) {
    final current = ref.read(financeListQueryProvider);
    ref.read(financeListQueryProvider.notifier).state = FinanceListQuery(
      courseId: current.courseId,
      studentId: current.studentId,
      status: status,
    );
  }

  bool _matchesSearch(FeeEntry entry, String raw) {
    final query = _fold(raw.trim());
    if (query.isEmpty) return true;
    return _fold(entry.studentName).contains(query) || _fold(entry.courseName).contains(query);
  }
}

String _fold(String value) {
  const from = 'áéíóúüñ';
  const to = 'aeiouun';
  final buffer = StringBuffer();
  for (final char in value.toLowerCase().split('')) {
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected
            ? primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? primary : FinancePalette.muted(isDark),
              ),
            ),
          ),
        ),
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 13)),
          Icon(Icons.keyboard_arrow_down, color: primary, size: 18),
        ],
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
