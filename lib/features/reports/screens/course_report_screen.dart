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
import '../../courses/providers/courses_provider.dart';
import '../../finance/providers/finance_catalog_provider.dart';
import '../../finance/providers/finance_provider.dart';
import '../../finance/widgets/finance_sheets.dart';
import '../../finance/widgets/finance_ui.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/providers/students_provider.dart';
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
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        Text(
                          data.courseName,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.schedule,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _MetricGrid(
                          items: [
                            (l10n.studentListTitle, '${data.studentCount}'),
                            (l10n.classesLabel, '${data.sessionCount}'),
                            (l10n.attendancesLabel, '${data.presents}'),
                            (l10n.lateStatus, '${data.lates}'),
                            (l10n.absencesLabel, '${data.absences}'),
                            (l10n.reportMonthlyCost, formatCurrency(data.cost)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _MetricGrid(
                          items: [
                            (l10n.financeCollected, formatCurrency(data.collected)),
                            (l10n.financeToCollect, formatCurrency(data.toCollect)),
                            (l10n.financeOverdue, formatCurrency(data.overdue)),
                            (l10n.financeRealProfit, formatCurrency(data.profit)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.studentListTitle,
                          style: AppTextStyles.titleMedium.copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: 8),
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

class _MetricGrid extends StatelessWidget {
  final List<(String, String)> items;

  const _MetricGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            width: (MediaQuery.sizeOf(context).width - 40) / 2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151D2E) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
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
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final status = row.paymentStatus;
    final label = status == null
        ? l10n.noFeeStatus
        : status == PaymentStatus.paid
            ? l10n.paymentUpToDate
            : financeStatusLabel(l10n, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.name,
                  style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.attendancesLabel} ${row.presents} · ${l10n.lateStatus} ${row.lates} · ${l10n.absencesLabel} ${row.absences}',
            style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }
}
