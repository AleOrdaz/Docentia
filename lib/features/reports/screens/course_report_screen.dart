import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/utils/teacher_name.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../finance/providers/finance_catalog_provider.dart';
import '../../finance/providers/finance_provider.dart';
import '../../finance/widgets/finance_sheets.dart';
import '../../finance/widgets/finance_ui.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/providers/students_provider.dart';
import '../../subscription/models/subscription_config.dart';
import '../../subscription/utils/subscription_gate.dart';
import '../logic/report_builders.dart';
import '../services/report_pdf_service.dart';

class CourseReportScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseReportScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseReportScreen> createState() => _CourseReportScreenState();
}

class _CourseReportScreenState extends ConsumerState<CourseReportScreen> {
  bool _exporting = false;

  Future<void> _export(CourseReportData data) async {
    if (_exporting) return;
    final allowed = await ensureProFeature(
      context,
      ref,
      feature: ProFeature.courseReportPdf,
    );
    if (!allowed || !mounted) return;

    setState(() => _exporting = true);
    final l10n = AppLocalizations.of(context)!;
    final window = ref.read(financeWindowProvider);
    final teacherName = ref.read(authProvider).teacher?.name ?? kFallbackTeacherName;
    final locale = Localizations.localeOf(context).toString();
    try {
      final bytes = await ReportPdfService().buildCoursePdf(
        data: data,
        l10n: l10n,
        periodLabel: financeWindowLabel(context, window, thisMonth: true),
        teacherName: teacherName,
        generatedOn: l10n.reportGeneratedOn(DateFormat.yMMMd(locale).format(DateTime.now())),
      );
      if (!mounted) return;
      await ReportPdfService().share(
        bytes: bytes,
        filename: reportFilename(data.courseName, window),
        l10n: l10n,
        onMessage: (message) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetail('$error'))),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final course = ref.watch(selectedCourseProvider);
    final studentsAsync = ref.watch(studentsForCourseProvider(widget.courseId));
    final sessionsAsync = ref.watch(courseSessionsProvider(widget.courseId));
    final paymentsAsync = ref.watch(paymentsForCourseProvider(widget.courseId));
    final expenses = ref.watch(expensesProvider);
    final catalog = ref.watch(financeCatalogProvider);
    final window = ref.watch(financeWindowProvider);
    final textPrimary = AppColors.textPrimary(context);

    return Scaffold(
      backgroundColor: appPageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/course-detail/${widget.courseId}');
            }
          },
        ),
        title: Text(
          l10n.courseReportTitle,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          catalog.maybeWhen(
            data: (data) => TextButton(
              onPressed: () => showFinancePeriodPicker(context, ref, data.payments),
              child: Text(
                financeWindowLabel(context, window, thisMonth: true),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) => Center(child: Text(l10n.errorWithDetail('$error'))),
        data: (students) {
          if (course == null) {
            return Center(child: Text(l10n.courseFallback));
          }
          return sessionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (error, _) => Center(child: Text(l10n.errorWithDetail('$error'))),
            data: (sessions) {
              final data = buildCourseReport(
                course: course,
                students: students,
                sessions: sessions,
                payments: paymentsAsync.value ?? const [],
                expenses: expenses,
                window: window,
              );
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final primary = Theme.of(context).colorScheme.primary;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        _ReportHero(
                          course: course,
                          courseName: data.courseName,
                          schedule: data.schedule,
                          periodLabel: financeWindowLabel(
                            context,
                            window,
                            thisMonth: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _MetricGrid(
                          items: [
                            _MetricSpec(
                              label: l10n.courseDetailsStudents,
                              value: '${data.studentCount}',
                              icon: Icons.groups_rounded,
                              color: primary,
                              background: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                            ),
                            _MetricSpec(
                              label: l10n.courseDetailsExpectedIncome,
                              value: formatCurrency(data.expectedIncome),
                              icon: Icons.payments_outlined,
                              color: FinancePalette.upcoming,
                              background: FinancePalette.upcomingBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.courseDetailsWeeklyHours,
                              value: data.weeklyHours <= 0
                                  ? '—'
                                  : l10n.courseDetailsHoursValue(
                                      data.weeklyHours.toStringAsFixed(
                                        data.weeklyHours ==
                                                data.weeklyHours.roundToDouble()
                                            ? 0
                                            : 1,
                                      ),
                                    ),
                              icon: Icons.schedule_rounded,
                              color: isDark
                                  ? const Color(0xFF5EEAD4)
                                  : AppColors.secondary,
                              background: isDark
                                  ? const Color(0xFF13403A)
                                  : AppColors.secondaryContainer
                                      .withValues(alpha: 0.55),
                            ),
                            _MetricSpec(
                              label: l10n.courseDetailsAttendance,
                              value: data.attendancePercent == null
                                  ? l10n.courseDetailsNoAttendanceYet
                                  : l10n.courseDetailsAttendanceValue(
                                      data.attendancePercent!
                                          .toStringAsFixed(0),
                                    ),
                              icon: Icons.fact_check_outlined,
                              color: FinancePalette.collected,
                              background: FinancePalette.collectedBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.courseDetailsPendingPayments,
                              value: '${data.pendingPaymentStudents}',
                              icon: Icons.hourglass_top_rounded,
                              color: FinancePalette.toCollect,
                              background: FinancePalette.toCollectBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.classesLabel,
                              value: '${data.sessionCount}',
                              icon: Icons.menu_book_rounded,
                              color: primary,
                              background: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                            ),
                            _MetricSpec(
                              label: l10n.attendancesLabel,
                              value: '${data.presents}',
                              icon: Icons.check_circle_outline_rounded,
                              color: FinancePalette.collected,
                              background: FinancePalette.collectedBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.lateStatus,
                              value: '${data.lates}',
                              icon: Icons.schedule_send_rounded,
                              color: FinancePalette.toCollect,
                              background: FinancePalette.toCollectBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.absencesLabel,
                              value: '${data.absences}',
                              icon: Icons.cancel_outlined,
                              color: FinancePalette.overdue,
                              background: FinancePalette.overdueBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.reportMonthlyCost,
                              value: formatCurrency(data.cost),
                              icon: Icons.sell_outlined,
                              color: FinancePalette.ink(isDark),
                              background: AppColors.surfaceLow(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _MetricGrid(
                          items: [
                            _MetricSpec(
                              label: l10n.financeCollected,
                              value: formatCurrency(data.collected),
                              icon: Icons.trending_up_rounded,
                              color: FinancePalette.collected,
                              background: FinancePalette.collectedBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.financeToCollect,
                              value: formatCurrency(data.toCollect),
                              icon: Icons.account_balance_wallet_outlined,
                              color: FinancePalette.toCollect,
                              background: FinancePalette.toCollectBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.financeOverdue,
                              value: formatCurrency(data.overdue),
                              icon: Icons.warning_amber_rounded,
                              color: FinancePalette.overdue,
                              background: FinancePalette.overdueBg(isDark),
                            ),
                            _MetricSpec(
                              label: l10n.financeRealProfit,
                              value: formatCurrency(data.profit),
                              icon: Icons.savings_outlined,
                              color: FinancePalette.upcoming,
                              background: FinancePalette.upcomingBg(isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _SuggestionCard(
                          title: l10n.courseDetailsSuggestionTitle,
                          body: data.deactivationSuggestions.isEmpty
                              ? l10n.courseDetailsSuggestionNone
                              : l10n.courseDetailsSuggestionBody(
                                  data.deactivationSuggestions.join(', '),
                                ),
                          hasAlert: data.deactivationSuggestions.isNotEmpty,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.studentListTitle,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (data.students.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              l10n.noStudentsInCourse,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          )
                        else
                          for (final row in data.students) ...[
                            _StudentReportTile(row: row),
                            const SizedBox(height: 8),
                          ],
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: AppPrimaryButton(
                        label: l10n.financeExportPdf,
                        icon: Icons.picture_as_pdf_outlined,
                        loading: _exporting,
                        onPressed: () => _export(data),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MetricSpec {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MetricSpec({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _ReportHero extends StatelessWidget {
  final Course course;
  final String courseName;
  final String schedule;
  final String periodLabel;

  const _ReportHero({
    required this.course,
    required this.courseName,
    required this.schedule,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final navy = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D);
    final iconColors = getCourseIconColors(course.iconKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Color.lerp(const Color(0xFF151D2E), primary, 0.22)!,
                  const Color(0xFF151D2E),
                ]
              : [
                  primary.withValues(alpha: 0.22),
                  primary.withValues(alpha: 0.07),
                ],
        ),
        border: Border.all(
          color: isDark
              ? primary.withValues(alpha: 0.28)
              : primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColors.background(isDark),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              getCourseIcon(course.iconKey),
              color: iconColors.icon(isDark),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: navy,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : primary.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    periodLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_MetricSpec> items;

  const _MetricGrid({required this.items});

  static const double _cardHeight = 112;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: _cardHeight,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: FinancePalette.card(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: FinancePalette.border(isDark)),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF00236F).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 17, color: item.color),
              ),
              const Spacer(),
              Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: FinancePalette.muted(isDark),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  item.value,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String title;
  final String body;
  final bool hasAlert;

  const _SuggestionCard({
    required this.title,
    required this.body,
    required this.hasAlert,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = hasAlert
        ? FinancePalette.toCollectBg(isDark)
        : (isDark
            ? FinancePalette.upcomingBg(isDark)
            : AppColors.surfaceLow(context));
    final border = hasAlert
        ? (isDark
            ? const Color(0xFFFBBF24).withValues(alpha: 0.35)
            : const Color(0xFFFED7AA))
        : FinancePalette.border(isDark);
    final titleColor = hasAlert
        ? (isDark ? const Color(0xFFFDE68A) : AppColors.onWarningContainer)
        : FinancePalette.ink(isDark);
    final bodyColor = hasAlert
        ? (isDark ? const Color(0xFFFEF3C7) : const Color(0xFF9A3412))
        : FinancePalette.muted(isDark);
    final iconColor = hasAlert ? FinancePalette.toCollect : FinancePalette.upcoming;
    final iconBg = hasAlert
        ? (isDark
            ? const Color(0xFF3A2C12)
            : const Color(0xFFFFE8C7))
        : (isDark
            ? const Color(0xFF162848)
            : const Color(0xFFDCE9FF));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAlert
                  ? Icons.lightbulb_outline_rounded
                  : Icons.verified_outlined,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: bodyColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentReportTile extends StatelessWidget {
  final CourseStudentReportRow row;

  const _StudentReportTile({required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final status = row.paymentStatus;
    final initials = row.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: FinancePalette.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FinancePalette.border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: FinancePalette.ink(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.attendancesLabel} ${row.presents} · ${l10n.lateStatus} ${row.lates} · ${l10n.absencesLabel} ${row.absences}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: FinancePalette.muted(isDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (status == null)
            Text(
              l10n.noFeeStatus,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: FinancePalette.muted(isDark),
              ),
            )
          else if (status == PaymentStatus.paid)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: FinancePalette.collectedBg(isDark),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                l10n.paymentUpToDate,
                style: const TextStyle(
                  color: FinancePalette.collected,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            FinanceStatusBadge(status: status),
        ],
      ),
    );
  }
}
