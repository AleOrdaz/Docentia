import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../courses/providers/courses_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../providers/students_provider.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  void _openWhatsApp(String phone, String studentName, String tutorName) async {
    final l10n = AppLocalizations.of(context)!;
    if (phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noTutorPhone)),
      );
      return;
    }

    final message = l10n.whatsappProgressMessage(tutorName, studentName);

    final success = await WhatsAppService.openWhatsApp(phone: phone, message: message);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappOpenError)),
      );
    }
  }

  void _confirmDeactivate(BuildContext context, String studentName) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deactivateStudentTitle),
        content: Text(
          l10n.deactivateStudentBody(studentName),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final course = ref.read(selectedCourseProvider);
              final courseId = course?.id ?? 'course-1';

              await ref
                  .read(studentsForCourseProvider(courseId).notifier)
                  .deactivateStudent(widget.studentId);

              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.studentDeactivated),
                  ),
                );
              }
            },
            child: Text(l10n.confirmDeactivate),
          ),
        ],
      ),
    );
  }

  void _showGenerateFeeDialog({
    required BuildContext context,
    required String studentId,
    required String courseId,
    required double courseCost,
    required dynamic courseSchedule,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;
    DueDateOption selectedOption = DueDateOption.endOfMonth;

    final locale = Localizations.localeOf(context).toString();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final calculatedDueDate = Payment.calculateDueDate(selectedYear, selectedMonth, selectedOption);
            final parts = calculatedDueDate.split('-');
            final formattedDueDate = '${parts[2]}/${parts[1]}/${parts[0]}';

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.add_card_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(l10n.newMonthlyFee),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.feeConfigHelp,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),

                    // Selector de Periodo: Mes y Año
                    Text(l10n.monthAndYear, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedMonth,
                                isExpanded: true,
                                items: List.generate(12, (i) {
                                  return DropdownMenuItem<int>(
                                    value: i + 1,
                                    child: Text(
                                      Payment.formatPeriodName(selectedYear, i + 1, locale).split(' ').first,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  );
                                }),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedMonth = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedYear,
                                isExpanded: true,
                                items: [now.year, now.year + 1].map((yr) {
                                  return DropdownMenuItem<int>(
                                    value: yr,
                                    child: Text('$yr', style: AppTextStyles.bodyMedium),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() => selectedYear = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Selector de Vencimiento: Inicio de mes vs Fin de mes
                    Text(l10n.dueDateField, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<DueDateOption>(
                            value: DueDateOption.startOfMonth,
                            groupValue: selectedOption,
                            title: Text(l10n.monthStart, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text(l10n.monthStartDay1, style: AppTextStyles.bodySmall),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedOption = val);
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<DueDateOption>(
                            value: DueDateOption.endOfMonth,
                            groupValue: selectedOption,
                            title: Text(l10n.monthEnd, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            subtitle: Text(l10n.monthEndLastDay, style: AppTextStyles.bodySmall),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedOption = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Resumen informativo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceContainer),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.calculatedDate, style: AppTextStyles.bodySmall),
                              Text(formattedDueDate, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.amountToCharge, style: AppTextStyles.bodySmall),
                              Text(
                                formatCurrency(courseCost),
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final result = await ref
                        .read(paymentsForCourseProvider(courseId).notifier)
                        .generateFeeForStudent(
                      studentId: studentId,
                      cost: courseCost,
                      year: selectedYear,
                      month: selectedMonth,
                      dueOption: selectedOption,
                    );

                    if (!context.mounted) return;

                    final periodName = Payment.formatPeriodName(selectedYear, selectedMonth, locale);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              result.success ? Icons.check_circle : Icons.warning_amber_rounded,
                              color: result.success ? AppColors.secondaryFixed : Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.success
                                    ? l10n.feeCreated(periodName)
                                    : l10n.feeAlreadyExists,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.inverseSurface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    );
                  },
                  child: Text(l10n.createFee),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDueDateDialog({
    required BuildContext context,
    required Payment payment,
    required String courseId,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final periodName = Payment.formatPeriodName(payment.periodYear, payment.periodMonth, locale);
    DueDateOption selectedOption = payment.dueOption;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final calculatedDueDate = Payment.calculateDueDate(
              payment.periodYear,
              payment.periodMonth,
              selectedOption,
            );
            final parts = calculatedDueDate.split('-');
            final formattedDueDate = '${parts[2]}/${parts[1]}/${parts[0]}';

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.edit_calendar_outlined, size: 22),
                  const SizedBox(width: 8),
                  Text(l10n.modifyDueDate),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.changeDueOption(periodName),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<DueDateOption>(
                          value: DueDateOption.startOfMonth,
                          groupValue: selectedOption,
                          title: Text(l10n.monthStartDay1Short, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedOption = val);
                          },
                        ),
                        const Divider(height: 1),
                        RadioListTile<DueDateOption>(
                          value: DueDateOption.endOfMonth,
                          groupValue: selectedOption,
                          title: Text(l10n.monthEndLastDayShort, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedOption = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.resultingDueDate(formattedDueDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref
                        .read(paymentsForCourseProvider(courseId).notifier)
                        .updatePaymentDueDate(payment.id, selectedOption);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.dueDateUpdated(formattedDueDate)),
                          backgroundColor: AppColors.inverseSurface,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                      );
                    }
                  },
                  child: Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showConfirmPaymentDialog({
    required BuildContext context,
    required Payment payment,
    required String studentName,
    required String courseName,
    required String courseId,
  }) {
    final now = DateTime.now();
    final todayFormatted = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final periodName = Payment.formatPeriodName(payment.periodYear, payment.periodMonth, locale);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.secondary, size: 24),
            const SizedBox(width: 8),
            Text(l10n.confirmPayment),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reviewPaymentData, style: AppTextStyles.bodySmall),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPaymentSummaryRow(l10n.studentColon, studentName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(l10n.courseColon, courseName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(l10n.monthlyFeeColon, periodName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(l10n.paymentDateColon, todayFormatted),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.amountToPay, style: AppTextStyles.titleSmall),
                      Text(
                        formatCurrency(payment.amount),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(paymentsForCourseProvider(courseId).notifier)
                  .confirmPayment(payment.id, paidAmount: payment.amount, paidDate: now);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.paymentConfirmed(formatCurrency(payment.amount), studentName),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.inverseSurface,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: Text(l10n.confirmPayment),
          ),
        ],
      ),
    );
  }

  String _paymentStatusLabel(AppLocalizations l10n, PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return l10n.paidStatus;
      case PaymentStatus.pending:
        return l10n.pendingStatus;
      case PaymentStatus.upcoming:
        return l10n.upcomingStatus;
      case PaymentStatus.overdue:
        return l10n.overdueStatus;
    }
  }

  Widget _buildPaymentSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurface),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final course = ref.watch(selectedCourseProvider);
    final courseId = course?.id ?? 'course-1';
    final primaryColor = Theme.of(context).colorScheme.primary;

    final studentsAsync = ref.watch(studentsForCourseProvider(courseId));
    final student = studentsAsync.value
        ?.where((s) => s.id == widget.studentId)
        .firstOrNull;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.studentDetailTitle)),
        body: Center(child: Text(l10n.studentNotFound)),
      );
    }

    final statsAsync = ref.watch(
      studentStatsProvider(StudentStatsParam(studentId: student.id, courseId: courseId)),
    );

    final paymentsAsync = ref.watch(
      studentPaymentsProvider((studentId: student.id, courseId: courseId)),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.studentDetailTitle, style: AppTextStyles.titleMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Tarjeta de identidad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Row(
                children: [
                  if (student.avatarUrl != null && student.avatarUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        student.avatarUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitials(student.initials, primaryColor),
                      ),
                    )
                  else
                    _buildInitials(student.initials, primaryColor),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(l10n.yearsOld(student.age), style: AppTextStyles.bodySmall),
                            const SizedBox(width: 6),
                            Text('•', style: AppTextStyles.bodySmall),
                            const SizedBox(width: 6),
                            Text(
                              course?.name ?? l10n.courseFallback,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: student.active
                                ? AppColors.secondaryFixed.withValues(alpha: 0.3)
                                : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            student.active ? l10n.regularStudent : l10n.deactivatedStudent,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: student.active ? AppColors.secondary : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Botones de acción (WhatsApp + Baja)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(
                      student.tutorPhone,
                      student.fullName,
                      student.tutorName,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.chat, size: 18),
                    label: Text(l10n.whatsappTutor, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _confirmDeactivate(context, student.fullName),
                  icon: const Icon(Icons.person_remove, color: AppColors.error),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estadísticas dinámicas de asistencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.how_to_reg, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.studentAttendance, style: AppTextStyles.titleSmall),
                        ],
                      ),
                      Text(l10n.realtimeRecord, style: AppTextStyles.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),

                  statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatBox(l10n.classesLabel, stats.totalClasses.toString())),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox(l10n.attendancesLabel, stats.presents.toString(), color: AppColors.secondary)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox(l10n.absencesLabel, stats.absences.toString(), color: AppColors.error)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox(l10n.percentageLabel, '${stats.percentage}%', color: primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: (stats.percentage / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(l10n.metricsError),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Datos del Tutor
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.family_restroom, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(l10n.tutorDataTitle, style: AppTextStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTutorField(l10n.nameLabel, student.tutorName),
                  _buildTutorField(l10n.mobilePhone, student.tutorPhone),
                  _buildTutorField(l10n.emailLabel, student.tutorEmail),
                  if (student.secondaryPhone != null && student.secondaryPhone!.isNotEmpty)
                    _buildTutorField(l10n.secondaryPhone, student.secondaryPhone!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cuotas y Mensualidades con acción clara de Confirmar Pago
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments_outlined, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(l10n.monthlyFeesTitle, style: AppTextStyles.titleSmall),
                        ],
                      ),
                      if (course != null)
                        InkWell(
                          onTap: () {
                            _showGenerateFeeDialog(
                              context: context,
                              studentId: student.id,
                              courseId: courseId,
                              courseCost: course.cost,
                              courseSchedule: course.paymentSchedule,
                            );
                          },
                          child: Text(
                            '+ Nueva Cuota',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  paymentsAsync.when(
                    data: (payments) {
                      if (payments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(
                                l10n.noFeesYet,
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              if (course != null)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _showGenerateFeeDialog(
                                      context: context,
                                      studentId: student.id,
                                      courseId: courseId,
                                      courseCost: course.cost,
                                      courseSchedule: course.paymentSchedule,
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(l10n.generateMonthly),
                                ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: payments.map((p) {
                          final isPaid = p.status == PaymentStatus.paid;
                          final isUpcoming = p.status == PaymentStatus.upcoming;
                          final isOverdue = p.status == PaymentStatus.overdue;

                          Color badgeBg;
                          Color badgeFg;
                          if (isPaid) {
                            badgeBg = AppColors.secondaryFixed;
                            badgeFg = AppColors.onSecondaryContainer;
                          } else if (isUpcoming) {
                            badgeBg = AppColors.warningContainer;
                            badgeFg = AppColors.onWarningContainer;
                          } else if (isOverdue) {
                            badgeBg = AppColors.errorContainer;
                            badgeFg = AppColors.onErrorContainer;
                          } else {
                            badgeBg = AppColors.surfaceContainer;
                            badgeFg = AppColors.onSurfaceVariant;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isUpcoming
                                    ? AppColors.warning.withValues(alpha: 0.5)
                                    : isOverdue
                                    ? AppColors.error.withValues(alpha: 0.4)
                                    : Colors.transparent,
                                width: isUpcoming || isOverdue ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Payment.formatPeriodName(p.periodYear, p.periodMonth, locale),
                                          style: AppTextStyles.titleSmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(l10n.dueOn(p.dueDate), style: AppTextStyles.bodySmall),
                                            if (!isPaid) ...[
                                              const SizedBox(width: 6),
                                              InkWell(
                                                onTap: () {
                                                  _showEditDueDateDialog(
                                                    context: context,
                                                    payment: p,
                                                    courseId: courseId,
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(4),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.edit_calendar_outlined, size: 13, color: primaryColor),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        p.dueOption == DueDateOption.startOfMonth
                                                            ? l10n.startShort
                                                            : l10n.monthEnd,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: primaryColor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        _paymentStatusLabel(l10n, p.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: badgeFg,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatCurrency(p.amount),
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isPaid ? AppColors.secondary : AppColors.onSurface,
                                      ),
                                    ),
                                    if (!isPaid)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          _showConfirmPaymentDialog(
                                            context: context,
                                            payment: p,
                                            studentName: student.fullName,
                                            courseName: course?.name ?? l10n.courseFallback,
                                            courseId: courseId,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: Text(l10n.confirmPaymentShort),
                                      )
                                    else
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: AppColors.secondary, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.paidStatus,
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text(l10n.paymentsLoadError),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials(String initials, Color primaryColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: primaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color ?? AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
