import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../courses/screens/create_course_dialog.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../../students/screens/add_student_modal.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _filterPendingOnly = false;

  void _openAddStudentModal(String courseName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddStudentModal(
        courseId: widget.courseId,
        courseName: courseName,
      ),
    );
  }

  void _openEditCourseDialog(Course? course) {
    if (course == null) return;
    showModalBottomSheet<Course>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateCourseDialog(courseToEdit: course),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(selectedCourseProvider);
    final studentsAsync = ref.watch(studentsForCourseProvider(widget.courseId));
    final payments = ref.watch(paymentsForCourseProvider(widget.courseId)).value ?? [];

    final l10n = AppLocalizations.of(context)!;
    final courseName = course?.name ?? l10n.courseFallback;
    final courseSchedule = course != null
        ? course.getLocalizedSchedule(context)
        : '';
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColors = getCourseIconColors(course?.iconKey);
    final surfaceMid = AppColors.surfaceMid(context);
    final textSecondary = AppColors.textSecondary(context);
    final textPrimary = AppColors.textPrimary(context);

    final now = DateTime.now();
    final isClassDay = course?.isClassDay(now) ?? true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColors.background(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                getCourseIcon(course?.iconKey),
                size: 20,
                color: iconColors.icon(isDark),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                courseName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 22, color: textPrimary),
            tooltip: l10n.courseOptions,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _openEditCourseDialog(course);
              } else if (value == 'delete' && course != null) {
                showDeleteCourseConfirmation(
                  context: context,
                  ref: ref,
                  course: course,
                  closeParent: true,
                );
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textPrimary(ctx),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.editCourseTitle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.deleteCourseBtn,
                      style: const TextStyle(color: Color(0xFFD32F2F)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          final pendingStudents = students.where((student) {
            final studentPayments =
                payments.where((payment) => payment.studentId == student.id).toList();
            return !_isPaymentCurrent(studentPayments);
          }).toList();
          final displayedStudents = _filterPendingOnly ? pendingStudents : students;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (courseSchedule.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: surfaceMid,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          courseSchedule,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                const SizedBox(height: 12),

                // Indicación cuando hoy no es día de clase
                if (!isClassDay)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.notClassDayBanner,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!isClassDay) const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () => _openAddStudentModal(courseName),
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: Text(
                            l10n.addStudentShort,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                            '/course-detail/${widget.courseId}/attendance',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(
                              color: primaryColor.withValues(alpha: 0.4),
                            ),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          icon: const Icon(Icons.history_edu, size: 18),
                          label: Text(
                            l10n.attendanceAction,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(selectedCourseIdProvider.notifier).state =
                          widget.courseId;
                      context.push(
                        '/course-detail/${widget.courseId}/certificates',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.4),
                      ),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                    label: Text(
                      l10n.certificatesBtn,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Encabezado de Lista de Alumnos + Filtros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.studentListTitle,
                      style: AppTextStyles.titleMedium.copyWith(color: textPrimary),
                    ),
                    Row(
                      children: [
                        FilterChip(
                          selected: !_filterPendingOnly,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: !_filterPendingOnly
                                ? AppColors.onPrimary
                                : textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          label: Text('${l10n.filterAll} (${students.length})'),
                          onSelected: (val) => setState(() => _filterPendingOnly = false),
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          selected: _filterPendingOnly,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: _filterPendingOnly
                                ? AppColors.onPrimary
                                : textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          label: Text('${l10n.filterPending} (${pendingStudents.length})'),
                          onSelected: (val) => setState(() => _filterPendingOnly = true),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Lista de alumnos
                if (displayedStudents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        _filterPendingOnly
                            ? l10n.allStudentsCurrent
                            : l10n.noStudentsInCourse,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.outlineAdaptive(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final student = displayedStudents[index];
                      final studentPayments = payments
                          .where((payment) => payment.studentId == student.id)
                          .toList();

                      return _buildStudentPaymentTile(
                        context,
                        student: student,
                        payments: studentPayments,
                        l10n: l10n,
                        onTap: () => context.push('/student-detail/${student.id}'),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(child: Text(l10n.errorWithDetail('$err'))),
      ),
    );
  }

  bool _isPaymentCurrent(List<Payment> payments) {
    if (payments.isEmpty) return false;
    return payments.every((payment) =>
        payment.status == PaymentStatus.paid ||
        payment.status == PaymentStatus.upcoming);
  }

  String _paymentLabel(AppLocalizations l10n, List<Payment> payments) {
    if (payments.isEmpty) return l10n.noFeeStatus;
    if (payments.any((payment) => payment.status == PaymentStatus.overdue)) {
      return l10n.overdueStatus;
    }
    if (payments.any((payment) => payment.status == PaymentStatus.pending)) {
      return l10n.pendingStatus;
    }
    if (payments.any((payment) => payment.status == PaymentStatus.upcoming)) {
      return l10n.upcomingStatus;
    }
    return l10n.paymentUpToDate;
  }

  Widget _buildStudentPaymentTile(
    BuildContext context, {
    required Student student,
    required List<Payment> payments,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final label = _paymentLabel(l10n, payments);
    final isCurrent = _isPaymentCurrent(payments);
    final isOverdue = payments.any((payment) => payment.status == PaymentStatus.overdue);
    final isPending = payments.any((payment) => payment.status == PaymentStatus.pending);

    final Color badgeBg;
    final Color badgeFg;
    final IconData badgeIcon;
    if (payments.isEmpty) {
      badgeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      badgeFg = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      badgeIcon = Icons.remove_circle_outline;
    } else if (isOverdue) {
      badgeBg = isDark ? const Color(0xFF3B171A) : const Color(0xFFFDE8E8);
      badgeFg = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFBA1A1A);
      badgeIcon = Icons.cancel_rounded;
    } else if (isPending) {
      badgeBg = isDark ? const Color(0xFF452205) : const Color(0xFFFFF4DE);
      badgeFg = isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
      badgeIcon = Icons.schedule;
    } else if (isCurrent && payments.any((payment) => payment.status == PaymentStatus.upcoming)) {
      badgeBg = isDark ? const Color(0xFF3B1D5A) : const Color(0xFFF3EDFD);
      badgeFg = isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8);
      badgeIcon = Icons.event_outlined;
    } else {
      badgeBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD8F3DC);
      badgeFg = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF00796B);
      badgeIcon = Icons.check_circle_rounded;
    }

    return Material(
      color: isDark ? const Color(0xFF151D2E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: isDark ? 0.22 : 0.12,
                      ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  student.initials,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (student.age > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.yearsOld(student.age),
                        style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeFg),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: badgeFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
