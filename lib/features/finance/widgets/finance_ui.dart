import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../payments/models/payment_model.dart';
import '../logic/finance_fees.dart';
import '../providers/finance_catalog_provider.dart';

class FinancePalette {
  static Color page(bool isDark) => isDark ? const Color(0xFF0B132B) : const Color(0xFFF4F7FB);
  static Color card(bool isDark) => isDark ? const Color(0xFF151D2E) : Colors.white;
  static Color border(bool isDark) => isDark ? const Color(0xFF22304A) : const Color(0xFFE7EEF6);
  static Color ink(bool isDark) => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1B2A4A);
  static Color muted(bool isDark) => isDark ? const Color(0xFF94A3B8) : const Color(0xFF7C8AA0);

  static const collected = Color(0xFF16A34A);
  static const toCollect = Color(0xFFE08A00);
  static const overdue = Color(0xFFE11D48);
  static const upcoming = Color(0xFF2563EB);

  static Color collectedBg(bool isDark) => isDark ? const Color(0xFF123524) : const Color(0xFFE8F8EF);
  static Color toCollectBg(bool isDark) => isDark ? const Color(0xFF3A2C12) : const Color(0xFFFFF4E0);
  static Color overdueBg(bool isDark) => isDark ? const Color(0xFF3F1D24) : const Color(0xFFFFE8EE);
  static Color upcomingBg(bool isDark) => isDark ? const Color(0xFF162848) : const Color(0xFFE8F0FF);
}

String financeMoney(double amount) => formatCurrency(amount);

String financeFeeCount(AppLocalizations l10n, int count) {
  final word = count == 1 ? l10n.financeFeeSingular : l10n.financeFeePlural;
  return '$count $word';
}

String financeDay(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat('d MMM y', locale).format(date).replaceAll('.', '');
}

String financeDayTime(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat('d MMM y · h:mm a', locale).format(date).replaceAll('.', '');
}

String financeMonthName(BuildContext context, int year, int month) {
  final locale = Localizations.localeOf(context).toString();
  return Payment.formatPeriodName(year, month, locale);
}

String financeWindowLabel(BuildContext context, FinanceWindow window, {bool thisMonth = false}) {
  final l10n = AppLocalizations.of(context)!;
  if (window.isCurrentMonth() && thisMonth) return l10n.financeThisMonth;
  if (!window.isRange) return financeMonthName(context, window.year!, window.month!);
  final start = financeDay(context, window.rangeStart!);
  final end = financeDay(context, window.rangeEnd!);
  return '$start – $end';
}

String financeStatusLabel(AppLocalizations l10n, PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return l10n.paidStatus;
    case PaymentStatus.pending:
      return l10n.pendingStatus;
    case PaymentStatus.overdue:
      return l10n.financeOverdue;
    case PaymentStatus.upcoming:
      return l10n.financeUpcomingBadge;
  }
}

(Color background, Color foreground) financeStatusColors(PaymentStatus status, bool isDark) {
  switch (status) {
    case PaymentStatus.paid:
      return (FinancePalette.collectedBg(isDark), FinancePalette.collected);
    case PaymentStatus.pending:
      return (FinancePalette.toCollectBg(isDark), FinancePalette.toCollect);
    case PaymentStatus.overdue:
      return (FinancePalette.overdueBg(isDark), FinancePalette.overdue);
    case PaymentStatus.upcoming:
      return (FinancePalette.upcomingBg(isDark), FinancePalette.upcoming);
  }
}

class FinanceAvatar extends StatelessWidget {
  final String initials;
  final String seed;
  final double size;

  const FinanceAvatar({
    super.key,
    required this.initials,
    required this.seed,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palettes = isDark
        ? const [
            (Color(0xFF2E2450), Color(0xFFC4B5FD)),
            (Color(0xFF1A2C4E), Color(0xFF93C5FD)),
            (Color(0xFF3A2A16), Color(0xFFFDBA74)),
            (Color(0xFF123528), Color(0xFF6EE7B7)),
            (Color(0xFF3B1D32), Color(0xFFF9A8D4)),
            (Color(0xFF123836), Color(0xFF5EEAD4)),
          ]
        : const [
            (Color(0xFFEDE9FE), Color(0xFF7C3AED)),
            (Color(0xFFDBEAFE), Color(0xFF2563EB)),
            (Color(0xFFFFEDD5), Color(0xFFC2410C)),
            (Color(0xFFD1FAE5), Color(0xFF047857)),
            (Color(0xFFFCE7F3), Color(0xFFBE185D)),
            (Color(0xFFCCFBF1), Color(0xFF0F766E)),
          ];
    final pair = palettes[seed.hashCode.abs() % palettes.length];
    final label = initials.isEmpty ? '?' : initials;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: pair.$1, shape: BoxShape.circle),
      child: Text(
        label,
        style: TextStyle(
          color: pair.$2,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class FinanceStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const FinanceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = financeStatusColors(status, isDark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        financeStatusLabel(l10n, status),
        style: TextStyle(
          color: colors.$2,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class FinancePaymentTile extends StatelessWidget {
  final FeeEntry entry;
  final VoidCallback onTap;

  const FinancePaymentTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final due = DateTime.tryParse(entry.payment.dueDate);
    final locale = Localizations.localeOf(context).toString();
    final month = DateFormat.MMMM(locale).format(
      DateTime(entry.payment.periodYear, entry.payment.periodMonth.clamp(1, 12)),
    );
    final monthLabel = month.isEmpty ? '' : '${month[0].toUpperCase()}${month.substring(1)}';
    final course = entry.courseName.isEmpty ? l10n.courseFallback : entry.courseName;
    final student = entry.studentName.isEmpty ? l10n.studentFallback : entry.studentName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              FinanceAvatar(initials: entry.initials, seed: entry.payment.studentId),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FinancePalette.ink(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$course · $monthLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                    ),
                    if (due != null)
                      Text(
                        financeDay(context, due),
                        style: TextStyle(fontSize: 12, color: FinancePalette.muted(isDark)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    financeMoney(entry.payment.amount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: FinancePalette.ink(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FinanceStatusBadge(status: entry.payment.status),
                ],
              ),
              Icon(Icons.chevron_right, size: 18, color: FinancePalette.muted(isDark)),
            ],
          ),
        ),
      ),
    );
  }
}

class FinanceSectionCard extends StatelessWidget {
  final Widget child;

  const FinanceSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: FinancePalette.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FinancePalette.border(isDark)),
      ),
      child: child,
    );
  }
}

class FinanceStateMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FinanceStateMessage({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return FinanceSectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: FinancePalette.ink(isDark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.35, color: FinancePalette.muted(isDark)),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
