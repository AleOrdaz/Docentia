import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/whatsapp_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../payments/services/fee_generation_service.dart';
import '../models/student_model.dart';
import '../providers/students_provider.dart';
import 'edit_emergency_contact_modal.dart';
import 'edit_student_modal.dart';
import 'edit_tutor_modal.dart';

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

  void _showGenerateFeeSheet({
    required BuildContext context,
    required String studentId,
    required String courseId,
    required double courseCost,
    required PaymentSchedule courseSchedule,
  }) {
    final l10n = AppLocalizations.of(context)!;
    DateTime returnDate = FeeCycle.dateOnly(DateTime.now());
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            final remaining = FeeCycle.remainingDays(courseSchedule, returnDate);
            final cycle = FeeCycle.cycleDays(courseSchedule, returnDate);
            final nextBilling = FeeCycle.nextBillingDate(courseSchedule, returnDate);
            final amount = FeeCycle.proratedAmount(
              monthlyCost: courseCost,
              schedule: courseSchedule,
              from: returnDate,
            );
            final canCreate = remaining > 0;
            final textPrimary = AppColors.textPrimary(sheetCtx);
            final textSecondary = AppColors.textSecondary(sheetCtx);

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLowest(sheetCtx),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariantAdaptive(sheetCtx),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.add_card_outlined, color: primaryColor, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.newMonthlyFee,
                            style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textSecondary),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    Text(
                      l10n.feeConfigHelp,
                      style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.returnDateLabel, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: sheetCtx,
                          initialDate: returnDate,
                          firstDate: DateTime(returnDate.year - 1),
                          lastDate: DateTime(returnDate.year + 1, 12, 31),
                        );
                        if (picked != null) {
                          setSheetState(() => returnDate = FeeCycle.dateOnly(picked));
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow(sheetCtx),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event, size: 20, color: primaryColor),
                            const SizedBox(width: 10),
                            Text(
                              FeeCycle.formatDisplayDate(returnDate),
                              style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow(sheetCtx),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder(sheetCtx)),
                      ),
                      child: canCreate
                          ? Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.nextChargeDate, style: AppTextStyles.bodySmall),
                                    Text(
                                      FeeCycle.formatDisplayDate(nextBilling),
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.remainingDaysCount(remaining), style: AppTextStyles.bodySmall),
                                    Text(
                                      l10n.proratedBreakdown(remaining, cycle),
                                      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.amountToCharge, style: AppTextStyles.bodySmall),
                                    Text(
                                      formatCurrency(amount),
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Text(
                              l10n.proratedOnBillingDay,
                              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: textPrimary,
                            backgroundColor: AppColors.surfaceMid(sheetCtx),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(l10n.cancel, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: AppColors.onPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: !canCreate
                              ? null
                              : () async {
                                  Navigator.of(ctx).pop();
                                  final result = await ref
                                      .read(paymentsForCourseProvider(courseId).notifier)
                                      .generateProratedFeeForStudent(
                                    studentId: studentId,
                                    cost: courseCost,
                                    schedule: courseSchedule,
                                    returnDate: returnDate,
                                  );

                                  if (!context.mounted) return;
                                  ref.read(paymentsRevisionProvider.notifier).state++;

                                  final message = result.success
                                      ? l10n.proratedFeeCreated(result.remainingDays)
                                      : result.message == 'alreadyExists'
                                          ? l10n.proratedAlreadyExists
                                          : l10n.proratedOnBillingDay;

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
                                          Expanded(child: Text(message)),
                                        ],
                                      ),
                                      backgroundColor: AppColors.inverseSurface,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                    ),
                                  );
                                },
                          child: Text(l10n.createProratedFee, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      color: AppColors.surfaceLow(dialogCtx),
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
    required double courseCost,
  }) {
    final now = DateTime.now();
    final todayFormatted = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final periodName = payment.isProrated
        ? payment.period
        : Payment.formatPeriodName(payment.periodYear, payment.periodMonth, locale);
    final concept = payment.isProrated ? l10n.proratedBadge : l10n.monthlyFeeConcept;
    final amountDue = payment.amount;

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
                color: AppColors.surfaceLow(ctx),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPaymentSummaryRow(ctx, l10n.studentColon, studentName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(ctx, l10n.courseColon, courseName),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(ctx, l10n.feeConceptLabel, concept),
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(ctx, l10n.periodLabel, periodName),
                  if (payment.isProrated) ...[
                    const SizedBox(height: 6),
                    _buildPaymentSummaryRow(ctx, l10n.courseMonthlyFee, formatCurrency(courseCost)),
                  ] else ...[
                    const SizedBox(height: 6),
                    _buildPaymentSummaryRow(ctx, l10n.monthlyFeeColon, formatCurrency(amountDue)),
                  ],
                  const SizedBox(height: 6),
                  _buildPaymentSummaryRow(ctx, l10n.paymentDateColon, todayFormatted),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.amountToPay, style: AppTextStyles.titleSmall),
                      Text(
                        formatCurrency(amountDue),
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
                  .confirmPayment(payment.id, paidAmount: amountDue, paidDate: now);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.paymentConfirmed(formatCurrency(amountDue), studentName),
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

  String _relationshipLabel(AppLocalizations l10n, TutorRelationship relationship) {
    switch (relationship) {
      case TutorRelationship.mother:
        return l10n.relationshipMother;
      case TutorRelationship.father:
        return l10n.relationshipFather;
      case TutorRelationship.tutor:
        return l10n.relationshipTutor;
    }
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

  Widget _buildPaymentSummaryRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
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
    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorder(context);
    final surfaceLow = AppColors.surfaceLow(context);
    final surfaceMid = AppColors.surfaceMid(context);
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

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
        title: Text(
          l10n.studentDetailTitle,
          style: AppTextStyles.titleMedium.copyWith(color: textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Tarjeta de identidad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              l10n.yearsOld(student.age),
                              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text('•', style: AppTextStyles.bodySmall.copyWith(color: textSecondary)),
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
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => EditStudentModal(student: student),
                      );
                    },
                    child: Text(
                      l10n.editTutorBtn,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
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
                    backgroundColor: surfaceLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estadísticas dinámicas de asistencia
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
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
                          Text(
                            l10n.studentAttendance,
                            style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                          ),
                        ],
                      ),
                      Text(
                        l10n.realtimeRecord,
                        style: AppTextStyles.labelSmall.copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  statsAsync.when(
                    data: (stats) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildStatBox(context, l10n.classesLabel, stats.totalClasses.toString())),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox(context, l10n.attendancesLabel, stats.presents.toString(), color: AppColors.secondary)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox(context, l10n.absencesLabel, stats.absences.toString(), color: AppColors.error)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatBox(context, l10n.percentageLabel, '${stats.percentage}%', color: primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: (stats.percentage / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: surfaceMid,
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.family_restroom, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tutorDataTitle,
                            style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EditTutorModal(student: student),
                          );
                        },
                        child: Text(
                          l10n.editTutorBtn,
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
                  _buildTutorField(context, l10n.relationshipLabel, _relationshipLabel(l10n, student.tutorRelationship)),
                  _buildTutorField(context, l10n.nameLabel, student.tutorName),
                  _buildTutorField(context, l10n.mobilePhone, student.tutorPhone),
                  _buildTutorField(context, l10n.emailLabel, student.tutorEmail),
                  if (student.secondaryPhone != null && student.secondaryPhone!.isNotEmpty)
                    _buildTutorField(context, l10n.secondaryPhone, student.secondaryPhone!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emergency_outlined, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.emergencyContactTitle,
                            style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EditEmergencyContactModal(student: student),
                          );
                        },
                        child: Text(
                          l10n.editTutorBtn,
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
                  if (student.emergencyName.isEmpty && student.emergencyPhone.isEmpty)
                    Text(
                      l10n.noEmergencyContact,
                      style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                    )
                  else ...[
                    _buildTutorField(context, l10n.nameLabel, student.emergencyName),
                    _buildTutorField(
                      context,
                      l10n.relationshipLabel,
                      _relationshipLabel(l10n, student.emergencyRelationship),
                    ),
                    _buildTutorField(context, l10n.mobilePhone, student.emergencyPhone),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cuotas y Mensualidades con acción clara de Confirmar Pago
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
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
                          Text(
                            l10n.monthlyFeesTitle,
                            style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                          ),
                        ],
                      ),
                      if (course != null)
                        InkWell(
                          onTap: () {
                            _showGenerateFeeSheet(
                              context: context,
                              studentId: student.id,
                              courseId: courseId,
                              courseCost: course.cost,
                              courseSchedule: course.paymentSchedule,
                            );
                          },
                          child: Text(
                            l10n.addProratedFee,
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
                                    _showGenerateFeeSheet(
                                      context: context,
                                      studentId: student.id,
                                      courseId: courseId,
                                      courseCost: course.cost,
                                      courseSchedule: course.paymentSchedule,
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(l10n.addProratedFee),
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
                          if (isUpcoming) {
                            badgeBg = AppColors.warningContainer;
                            badgeFg = AppColors.onWarningContainer;
                          } else if (isOverdue) {
                            badgeBg = AppColors.errorContainer;
                            badgeFg = AppColors.onErrorContainer;
                          } else {
                            badgeBg = surfaceMid;
                            badgeFg = textSecondary;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: surfaceLow,
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
                                        Row(
                                          children: [
                                            Text(
                                              p.isProrated
                                                  ? p.period
                                                  : Payment.formatPeriodName(p.periodYear, p.periodMonth, locale),
                                              style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                                            ),
                                            if (p.isProrated) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: Text(
                                                  l10n.proratedBadge,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              l10n.dueOn(p.dueDate),
                                              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                                            ),
                                            if (!isPaid && !p.isProrated) ...[
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
                                    if (!isPaid)
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
                                        color: isPaid ? AppColors.secondary : textPrimary,
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
                                            courseCost: course?.cost ?? p.amount,
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
                                          const SizedBox(width: 8),
                                          OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: primaryColor,
                                              side: BorderSide(color: primaryColor),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(l10n.sendFeeBtn),
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

  Widget _buildStatBox(BuildContext context, String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color ?? AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorField(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary(context)),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
