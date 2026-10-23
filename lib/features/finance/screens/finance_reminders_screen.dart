import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../payments/models/payment_model.dart';
import '../providers/finance_catalog_provider.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/finance_ui.dart';

class FinanceRemindersScreen extends ConsumerWidget {
  const FinanceRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Text(l10n.financeReminders, style: TextStyle(fontWeight: FontWeight.w800, color: primary)),
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
          final items = data.entries.where((entry) {
            if (!window.includes(entry.payment)) return false;
            return entry.payment.status != PaymentStatus.paid;
          }).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              Text(
                l10n.financeReminderHint,
                style: TextStyle(color: FinancePalette.muted(isDark), height: 1.35),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                FinanceStateMessage(
                  icon: Icons.notifications_none,
                  iconColor: primary,
                  iconBackground: primary.withValues(alpha: 0.12),
                  title: l10n.financeReminders,
                  description: l10n.financeNoReminders,
                )
              else
                FinanceSectionCard(
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: FinancePalette.border(isDark)),
                        Row(
                          children: [
                            Expanded(
                              child: FinancePaymentTile(
                                entry: items[i],
                                onTap: () => notifyTutor(context, items[i]),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.financeNotifyParents,
                              onPressed: () => notifyTutor(context, items[i]),
                              icon: Icon(Icons.mail_outline, color: primary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
