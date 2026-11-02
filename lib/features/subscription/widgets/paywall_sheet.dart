import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../app/widgets/app_snackbars.dart';
import '../../../core/utils/legal_links.dart';
import '../../../l10n/app_localizations.dart';
import '../models/subscription_config.dart';
import '../providers/subscription_provider.dart';

Future<void> showPaywallSheet(
  BuildContext context, {
  required ProFeature feature,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaywallSheet(feature: feature),
  );
}

class PaywallSheet extends ConsumerStatefulWidget {
  final ProFeature feature;

  const PaywallSheet({super.key, required this.feature});

  @override
  ConsumerState<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends ConsumerState<PaywallSheet> {
  BillingPeriod _period = BillingPeriod.yearly;
  bool _busy = false;

  String _headline(AppLocalizations l10n) {
    switch (widget.feature) {
      case ProFeature.courseLimit:
        return l10n.paywallReasonCourses(SubscriptionConfig.freeMaxCourses);
      case ProFeature.studentLimit:
        return l10n.paywallReasonStudents(SubscriptionConfig.freeMaxStudents);
      case ProFeature.certificates:
        return l10n.paywallReasonCertificates;
      case ProFeature.courseReportPdf:
        return l10n.paywallReasonCoursePdf;
      case ProFeature.financeReports:
        return l10n.paywallReasonFinanceReports;
      case ProFeature.expenses:
        return l10n.paywallReasonExpenses;
      case ProFeature.reminders:
        return l10n.paywallReasonReminders;
      case ProFeature.notifyParents:
        return l10n.paywallReasonNotifyParents;
    }
  }

  String _priceLabel(BillingPeriod period, AppLocalizations l10n) {
    final store = ref.read(storeProductsProvider).valueOrNull?[period];
    if (store != null) {
      return period == BillingPeriod.yearly
          ? '${store.price}/${l10n.paywallYearlyTitle.toLowerCase()}'
          : '${store.price}/${l10n.paywallMonthlyTitle.toLowerCase()}';
    }
    return period == BillingPeriod.yearly
        ? SubscriptionConfig.yearlyLabel()
        : SubscriptionConfig.monthlyLabel();
  }

  Future<void> _handlePurchaseResult(PurchaseResult result) async {
    final l10n = AppLocalizations.of(context)!;
    switch (result.outcome) {
      case PurchaseOutcome.success:
        if (!mounted) return;
        Navigator.of(context).pop();
        showAppSnackBar(
          context,
          message: l10n.paywallActivatedPro,
          kind: AppSnackKind.success,
        );
      case PurchaseOutcome.canceled:
        break;
      case PurchaseOutcome.pending:
        showAppSnackBar(
          context,
          message: l10n.paywallPurchasePending,
          kind: AppSnackKind.info,
        );
      case PurchaseOutcome.storeUnavailable:
        showAppSnackBar(
          context,
          message: l10n.paywallStoreUnavailable,
          kind: AppSnackKind.warning,
        );
      case PurchaseOutcome.productMissing:
        showAppSnackBar(
          context,
          message: l10n.paywallProductMissing,
          kind: AppSnackKind.warning,
        );
      case PurchaseOutcome.error:
        showAppSnackBar(
          context,
          message: result.message ?? l10n.paywallPurchaseError,
          kind: AppSnackKind.error,
        );
    }
  }

  Future<void> _activate() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final result =
          await ref.read(subscriptionProvider.notifier).purchasePro(_period);
      if (!mounted) return;
      await _handlePurchaseResult(result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startTrial() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      // La oferta de 14 días se configura en App Store / Play; aquí abrimos la compra.
      final result = await ref
          .read(subscriptionProvider.notifier)
          .startTrialPurchase(period: _period);
      if (!mounted) return;
      await _handlePurchaseResult(result);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final result =
          await ref.read(subscriptionProvider.notifier).restorePurchases();
      if (!mounted) return;
      if (result.isSuccess && ref.read(subscriptionProvider).isPro) {
        Navigator.of(context).pop();
        showAppSnackBar(
          context,
          message: l10n.paywallActivatedPro,
          kind: AppSnackKind.success,
        );
      } else if (result.outcome == PurchaseOutcome.storeUnavailable) {
        showAppSnackBar(
          context,
          message: l10n.paywallStoreUnavailable,
          kind: AppSnackKind.warning,
        );
      } else {
        showAppSnackBar(
          context,
          message: l10n.paywallRestoreEmpty,
          kind: AppSnackKind.info,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final sheetBg = isDark ? const Color(0xFF151D2E) : Colors.white;
    ref.watch(storeProductsProvider);
    final yearlyPrice = _priceLabel(BillingPeriod.yearly, l10n);
    final monthlyPrice = _priceLabel(BillingPeriod.monthly, l10n);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paywallTitle,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.paywallSubtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _headline(l10n),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _Benefit(text: l10n.paywallBenefitUnlimited),
                _Benefit(text: l10n.paywallBenefitCertificates),
                _Benefit(text: l10n.paywallBenefitFinance),
                _Benefit(text: l10n.paywallBenefitPdfs),
                const SizedBox(height: 18),
                Text(
                  l10n.paywallChoosePlan,
                  style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 10),
                _PlanOption(
                  selected: _period == BillingPeriod.yearly,
                  title: l10n.paywallYearlyTitle,
                  price: yearlyPrice,
                  badge: l10n.paywallBestValue,
                  footnote: l10n.paywallYearlyFootnote(
                    SubscriptionConfig.yearlySavingsMxn(),
                  ),
                  onTap: () => setState(() => _period = BillingPeriod.yearly),
                ),
                const SizedBox(height: 10),
                _PlanOption(
                  selected: _period == BillingPeriod.monthly,
                  title: l10n.paywallMonthlyTitle,
                  price: monthlyPrice,
                  footnote: l10n.paywallMonthlyFootnote,
                  onTap: () => setState(() => _period = BillingPeriod.monthly),
                ),
                const SizedBox(height: 18),
                AppPrimaryButton(
                  label: _busy
                      ? l10n.loading
                      : l10n.paywallContinuePro(
                          _period == BillingPeriod.yearly
                              ? yearlyPrice
                              : monthlyPrice,
                        ),
                  onPressed: _busy ? null : _activate,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _busy ? null : _startTrial,
                  child: Text(
                    l10n.paywallStartTrial(SubscriptionConfig.trialDays),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : _restore,
                  child: Text(
                    l10n.paywallRestorePurchases,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.paywallAutoRenewDisclosure,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: openTermsOfUse,
                      child: Text(
                        l10n.paywallLegalTerms,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Text(
                      '  ·  ',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: openPrivacyPolicy,
                      child: Text(
                        l10n.paywallLegalPrivacy,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.paywallBillingNote,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final String text;

  const _Benefit({required this.text});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String? badge;
  final String footnote;
  final VoidCallback onTap;

  const _PlanOption({
    required this.selected,
    required this.title,
    required this.price,
    this.badge,
    required this.footnote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? primary
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: selected ? 2 : 1,
          ),
          color: selected
              ? primary.withValues(alpha: isDark ? 0.16 : 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? primary : textSecondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    footnote,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
