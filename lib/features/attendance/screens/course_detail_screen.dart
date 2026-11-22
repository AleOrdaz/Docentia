import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../app/widgets/app_snackbars.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../courses/screens/create_course_dialog.dart';
import '../../finance/providers/finance_catalog_provider.dart';
import '../../finance/screens/finance_expenses_screen.dart';
import '../../finance/widgets/finance_sheets.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../../students/screens/add_student_modal.dart';
import '../../students/screens/edit_student_modal.dart';
import '../../subscription/models/subscription_config.dart';
import '../../subscription/utils/subscription_gate.dart';

Color _courseDetailActionColor(BuildContext context) =>
    Theme.of(context).colorScheme.primary;
Color _courseDetailNeutralColor(BuildContext context) =>
    AppColors.textSecondary(context);

enum _StudentFilter { all, toCollect }

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
  _StudentFilter _studentFilter = _StudentFilter.all;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddStudentModal() async {
    final allowed = await ensureCanAddStudent(context, ref);
    if (!allowed || !mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (ctx) => AddStudentModal(
        courseId: widget.courseId,
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

  void _openStudent(String studentId) {
    ref.read(selectedStudentIdProvider.notifier).state = studentId;
    context.push('/student-detail/$studentId');
  }

  Future<void> _registerPayment(Student student, Course? course) async {
    final unpaid = (ref.read(financeCatalogProvider).value?.entries ?? const [])
        .where((entry) =>
            entry.payment.studentId == student.id &&
            entry.payment.status != PaymentStatus.paid)
        .toList();
    await showRegisterPaymentSheet(context, ref, unpaid);
  }

  VoidCallback? _quickConfirmCallback(
    Student student,
    List<Payment> studentPayments,
  ) {
    final confirmable = studentPayments
        .where((payment) =>
            payment.status == PaymentStatus.overdue ||
            payment.status == PaymentStatus.pending)
        .toList()
      ..sort((a, b) {
        final overdueFirst = (a.status == PaymentStatus.overdue ? 0 : 1)
            .compareTo(b.status == PaymentStatus.overdue ? 0 : 1);
        return overdueFirst != 0
            ? overdueFirst
            : a.dueDate.compareTo(b.dueDate);
      });
    if (confirmable.isEmpty) return null;
    final payment = confirmable.first;
    return () => _confirmStudentPayment(student, payment);
  }

  Future<void> _confirmStudentPayment(
    Student student,
    Payment payment,
  ) async {
    try {
      await ref
          .read(paymentsForCourseProvider(widget.courseId).notifier)
          .confirmPayment(payment.id, paidAmount: payment.amount);
      if (!mounted) return;
      final amount = formatCurrency(payment.amount).replaceFirst(
        RegExp(r'\.00$'),
        '',
      );
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context)!
            .paymentConfirmed(amount, student.fullName),
        kind: AppSnackKind.success,
      );
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context)!.errorWithDetail('$error'),
        kind: AppSnackKind.error,
      );
    }
  }

  void _editStudent(Student student) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditStudentModal(student: student),
    );
  }

  void _confirmDeactivate(Student student) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deactivateStudentTitle),
        content: Text(l10n.deactivateStudentBody(student.fullName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(studentsForCourseProvider(widget.courseId).notifier)
                  .deactivateStudent(student.id);
              if (!mounted) return;
              showAppSnackBar(
                context,
                message: l10n.studentDeactivated,
                kind: AppSnackKind.info,
              );
            },
            child: Text(l10n.confirmDeactivate),
          ),
        ],
      ),
    );
  }

  Future<void> _activateStudent(Student student) async {
    await ref
        .read(studentsForCourseProvider(widget.courseId).notifier)
        .activateStudent(student.id);
    if (!mounted) return;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    showAppSnackBar(
      context,
      message: isEnglish ? 'Student reactivated' : 'Alumno reactivado',
      kind: AppSnackKind.success,
    );
  }

  void _openStudentActions(Student student, Course? course) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: _StudentAvatar(
                    seed: student.id.isNotEmpty ? student.id : student.fullName,
                    imageUrl: student.avatarUrl,
                    semanticLabel: student.fullName,
                  ),
                  title: Text(
                    student.fullName,
                    style:
                        AppTextStyles.titleSmall.copyWith(color: textPrimary),
                  ),
                  subtitle: student.age > 0
                      ? Text(
                          l10n.yearsOld(student.age),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: textSecondary),
                        )
                      : null,
                ),
                const Divider(height: 8),
                ListTile(
                  leading: Icon(Icons.person_outline,
                      color: _courseDetailNeutralColor(context)),
                  title: Text(l10n.viewStudentProfile),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openStudent(student.id);
                  },
                ),
                if (student.active)
                  ListTile(
                    leading: Icon(Icons.payments_outlined,
                        color: _courseDetailNeutralColor(context)),
                    title: Text(l10n.financeRegisterPayment),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _registerPayment(student, course);
                    },
                  ),
                if (student.active &&
                    course != null &&
                    (course.type == CourseType.individual ||
                        course.billingFrequency != BillingFrequency.monthly))
                  ListTile(
                    leading: Icon(Icons.add_card_outlined,
                        color: _courseDetailNeutralColor(context)),
                    title: const Text('Registrar cobro manual'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      showManualChargeDialog(
                        context: context,
                        ref: ref,
                        studentId: student.id,
                        courseId: course.id,
                        suggestedAmount: course.cost,
                      );
                    },
                  ),
                if (student.active)
                  ListTile(
                    leading: Icon(Icons.event_available_outlined,
                        color: _courseDetailNeutralColor(context)),
                    title: Text(l10n.viewStudentAttendance),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openStudent(student.id);
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.edit_outlined,
                      color: _courseDetailNeutralColor(context)),
                  title: Text(l10n.editStudentInfo),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _editStudent(student);
                  },
                ),
                if (student.active)
                  ListTile(
                    leading: const Icon(Icons.delete_outline,
                        color: AppColors.iconError),
                    title: Text(
                      l10n.deleteStudentAction,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _confirmDeactivate(student);
                    },
                  )
                else
                  ListTile(
                    leading: Icon(Icons.person_add_alt_1,
                        color: _courseDetailNeutralColor(context)),
                    title: Text(
                      Localizations.localeOf(context).languageCode == 'en'
                          ? 'Reactivate student'
                          : 'Reactivar alumno',
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _activateStudent(student);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(selectedCourseProvider);
    final studentsAsync =
        ref.watch(studentsIncludingInactiveForCourseProvider(widget.courseId));
    final payments =
        ref.watch(paymentsForCourseProvider(widget.courseId)).value ?? [];
    final l10n = AppLocalizations.of(context)!;
    final courseName = course?.name ?? l10n.courseFallback;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseIconColors = getCourseIconColors(course?.iconKey);
    final courseAccent = courseIconColors.icon(isDark);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: appPageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: _courseDetailNeutralColor(context)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                size: 22, color: _courseDetailNeutralColor(context)),
            tooltip: l10n.courseOptions,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) async {
              if (value == 'edit') {
                _openEditCourseDialog(course);
              } else if (value == 'certificates') {
                final ok = await ensureProFeature(
                  context,
                  ref,
                  feature: ProFeature.certificates,
                );
                if (!ok || !mounted) return;
                ref.read(selectedCourseIdProvider.notifier).state =
                    widget.courseId;
                if (!context.mounted) return;
                context.push(
                  '/course-detail/${widget.courseId}/certificates',
                );
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
                value: 'certificates',
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium_outlined,
                        size: 20, color: _courseDetailNeutralColor(context)),
                    const SizedBox(width: 10),
                    Text(l10n.certificatesBtn),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 20, color: _courseDetailNeutralColor(context)),
                    const SizedBox(width: 10),
                    Text(l10n.editCourseTitle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.iconError),
                    const SizedBox(width: 10),
                    Text(l10n.deleteCourseBtn,
                        style: const TextStyle(color: Color(0xFFD32F2F))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, _) => Center(child: Text(l10n.errorWithDetail('$err'))),
        data: (students) {
          final activeStudents =
              students.where((student) => student.active).toList();
          final pendingStudents = activeStudents.where((student) {
            final studentPayments = payments
                .where((payment) => payment.studentId == student.id)
                .toList();
            return !_isPaymentCurrent(studentPayments);
          }).toList();
          final sourceStudents = switch (_studentFilter) {
            _StudentFilter.all => students,
            _StudentFilter.toCollect => pendingStudents,
          };
          final visible = sourceStudents
              .where((student) =>
                  query.isEmpty ||
                  student.fullName.toLowerCase().contains(query))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder(context)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.14 : 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: courseIconColors.background(isDark),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            getCourseIcon(course?.iconKey),
                            size: 26,
                            color: courseAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courseName,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (course != null) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _CourseMetadataChip(
                                      icon: course.type == CourseType.individual
                                          ? Icons.person_outline
                                          : Icons.groups_outlined,
                                      label: Localizations.localeOf(context)
                                                  .languageCode ==
                                              'en'
                                          ? (course.type ==
                                                  CourseType.individual
                                              ? 'Individual'
                                              : 'Group course')
                                          : (course.type ==
                                                  CourseType.individual
                                              ? 'Individual'
                                              : 'Curso grupal'),
                                    ),
                                    _CourseMetadataChip(
                                      icon: Icons.payments_outlined,
                                      label: _billingFrequencyLabel(
                                        context,
                                        course.billingFrequency,
                                      ),
                                      iconColor: isDark
                                          ? const Color(0xFF86EFAC)
                                          : AppColors.iconSuccess,
                                      foregroundColor: isDark
                                          ? const Color(0xFF86EFAC)
                                          : AppColors.iconSuccess,
                                      backgroundColor: isDark
                                          ? const Color(0xFF163A2A)
                                          : const Color(0xFFD8F3DC),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  course.getLocalizedHeaderSchedule(context),
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _AttendanceAction(
                title: Localizations.localeOf(context).languageCode == 'en'
                    ? 'Record attendance'
                    : 'Registrar asistencia',
                subtitle: Localizations.localeOf(context).languageCode == 'en'
                    ? 'Take attendance in class'
                    : 'Toma lista de asistencia en clases',
                onTap: () => context
                    .push('/course-detail/${widget.courseId}/attendance'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.financeExpenses,
                      subtitle:
                          Localizations.localeOf(context).languageCode == 'en'
                              ? 'Add an expense for this course'
                              : 'Añade un gasto de este curso',
                      iconColor: courseAccent,
                      onTap: () async {
                        final ok = await ensureProFeature(
                          context,
                          ref,
                          feature: ProFeature.expenses,
                        );
                        if (!ok || !context.mounted) return;
                        await showCourseExpenseSheet(
                          context,
                          courseId: widget.courseId,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.description_outlined,
                      label: l10n.courseReportBtn,
                      subtitle:
                          Localizations.localeOf(context).languageCode == 'en'
                              ? 'Attendance and progress'
                              : 'Asistencia y avances',
                      iconColor: courseAccent,
                      onTap: () {
                        ref.read(selectedCourseIdProvider.notifier).state =
                            widget.courseId;
                        context
                            .push('/course-detail/${widget.courseId}/report');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.groups_outlined, color: courseAccent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'en'
                          ? 'Students'
                          : 'Alumnos',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: textPrimary),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _openAddStudentModal,
                    icon: const Icon(Icons.person_add_alt_1, size: 17),
                    label: Text(l10n.addStudentShort),
                    style: FilledButton.styleFrom(
                      backgroundColor: _courseDetailActionColor(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: const StadiumBorder(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.searchStudentsHint,
                  hintStyle:
                      AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceLow(context),
                  prefixIcon: Icon(Icons.search,
                      color: _courseDetailNeutralColor(context)),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.cancel,
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.close,
                            color: _courseDetailNeutralColor(context),
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    icon: Icons.checklist_outlined,
                    label: '${l10n.filterAll} (${students.length})',
                    selected: _studentFilter == _StudentFilter.all,
                    onTap: () => setState(
                      () => _studentFilter = _StudentFilter.all,
                    ),
                  ),
                  _FilterChip(
                    icon: Icons.account_balance_wallet_outlined,
                    label:
                        '${l10n.financeToCollect} (${pendingStudents.length})',
                    selected: _studentFilter == _StudentFilter.toCollect,
                    onTap: () => setState(
                      () => _studentFilter = _StudentFilter.toCollect,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (students.isEmpty && _studentFilter == _StudentFilter.all)
                const _EmptyStudents()
              else if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    query.isNotEmpty
                        ? l10n.noStudentsSearch
                        : switch (_studentFilter) {
                            _StudentFilter.all =>
                              Localizations.localeOf(context).languageCode ==
                                      'en'
                                  ? 'No students'
                                  : 'No hay alumnos',
                            _StudentFilter.toCollect => l10n.allStudentsCurrent,
                          },
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                  ),
                )
              else
                for (final student in visible) ...[
                  _StudentTile(
                    student: student,
                    payments: payments
                        .where((payment) => payment.studentId == student.id)
                        .toList(),
                    onConfirmPayment: student.active
                        ? _quickConfirmCallback(
                            student,
                            payments
                                .where((payment) =>
                                    payment.studentId == student.id)
                                .toList(),
                          )
                        : null,
                    onTap: () => _openStudent(student.id),
                    onMenu: () => _openStudentActions(student, course),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          );
        },
      ),
    );
  }

  String _billingFrequencyLabel(
    BuildContext context,
    BillingFrequency frequency,
  ) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return switch (frequency) {
      BillingFrequency.perClass => isEnglish ? 'Daily billing' : 'Cobro diario',
      BillingFrequency.weekly => isEnglish ? 'Weekly billing' : 'Cobro semanal',
      BillingFrequency.biweekly =>
        isEnglish ? 'Biweekly billing' : 'Cobro quincenal',
      BillingFrequency.monthly =>
        isEnglish ? 'Monthly billing' : 'Cobro mensual',
    };
  }

  bool _isPaymentCurrent(List<Payment> payments) {
    if (payments.isEmpty) return true;
    return payments.every((payment) =>
        payment.status == PaymentStatus.paid ||
        payment.status == PaymentStatus.upcoming);
  }
}

class _CourseMetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const _CourseMetadataChip({
    required this.icon,
    required this.label,
    this.iconColor,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceLow(context),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? _courseDetailNeutralColor(context),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: foregroundColor ?? AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceAction extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AttendanceAction({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = _courseDetailActionColor(context);
    return Material(
      color: primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withValues(alpha: 0.12);
          }
          return Colors.transparent;
        }),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primary),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = _courseDetailActionColor(context);
    return Material(
      color: AppColors.cardBg(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return primary.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textSecondary = AppColors.textSecondary(context);
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? primary : AppColors.cardBorder(context),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? primary : textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? primary : textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  final List<Payment> payments;
  final VoidCallback? onConfirmPayment;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  const _StudentTile({
    required this.student,
    required this.payments,
    required this.onConfirmPayment,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final style = _badgeStyle(
      l10n,
      payments,
      Theme.of(context).brightness == Brightness.dark,
      student.active,
    );

    return Material(
      color: AppColors.cardBg(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        onLongPress: onMenu,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder(context)),
          ),
          child: Row(
            children: [
              _StudentAvatar(
                seed: student.id.isNotEmpty ? student.id : student.fullName,
                imageUrl: student.avatarUrl,
                semanticLabel: student.fullName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style:
                          AppTextStyles.titleSmall.copyWith(color: textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (student.age > 0)
                          Text(
                            l10n.yearsOld(student.age),
                            style: AppTextStyles.bodySmall
                                .copyWith(color: textSecondary),
                          ),
                        if (style != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  style.icon,
                                  size: style.icon == Icons.circle ? 7 : 13,
                                  color: style.iconColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    style.label,
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: style.foreground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onConfirmPayment != null)
                IconButton(
                  tooltip: Localizations.localeOf(context).languageCode == 'en'
                      ? 'Confirm oldest payment'
                      : 'Confirmar pago más antiguo',
                  visualDensity: VisualDensity.compact,
                  onPressed: onConfirmPayment,
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: _courseDetailActionColor(context),
                    size: 20,
                  ),
                ),
              InkWell(
                onTap: onMenu,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.more_vert,
                      size: 18, color: _courseDetailNeutralColor(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _BadgeStyle? _badgeStyle(
    AppLocalizations l10n,
    List<Payment> payments,
    bool isDark,
    bool isActive,
  ) {
    if (!isActive) {
      final isEnglish = l10n.localeName == 'en';
      final neutral =
          isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
      return _BadgeStyle(
        label: isEnglish ? 'Inactive' : 'Inactivo',
        icon: Icons.person_off_outlined,
        iconColor: neutral,
        background: isDark ? const Color(0xFF263244) : const Color(0xFFEFF2F6),
        foreground: neutral,
      );
    }
    if (payments.isEmpty) return null;
    final overduePayments = payments
        .where((payment) => payment.status == PaymentStatus.overdue)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (overduePayments.isNotEmpty) {
      final overdue = overduePayments.first;
      final dueDate = DateTime.tryParse(overdue.dueDate);
      final lateDays = dueDate == null
          ? null
          : DateUtils.dateOnly(DateTime.now())
              .difference(DateUtils.dateOnly(dueDate))
              .inDays;
      final overdueTotal = overduePayments.fold<double>(
        0,
        (total, payment) => total + payment.amount,
      );
      final amount = formatCurrency(overdueTotal).replaceFirst(
        RegExp(r'\.00$'),
        '',
      );
      final isEnglish = l10n.localeName == 'en';
      final lateLabel = lateDays == null || lateDays <= 0
          ? l10n.financeOverdue
          : isEnglish
              ? 'Overdue $lateDays ${lateDays == 1 ? 'day' : 'days'}'
              : 'Vencido hace $lateDays ${lateDays == 1 ? 'día' : 'días'}';
      return _BadgeStyle(
        label: '$lateLabel · $amount',
        icon: Icons.circle,
        iconColor: isDark ? const Color(0xFFD99A9A) : const Color(0xFFB56B6B),
        background: isDark ? const Color(0xFF30252A) : const Color(0xFFFFF3F1),
        foreground: isDark ? const Color(0xFFE1B5B5) : const Color(0xFF895454),
      );
    }
    final pendingPayments = payments
        .where((payment) => payment.status == PaymentStatus.pending)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (pendingPayments.isNotEmpty) {
      final pendingTotal = pendingPayments.fold<double>(
        0,
        (total, payment) => total + payment.amount,
      );
      final formattedTotal = formatCurrency(pendingTotal).replaceFirst(
        RegExp(r'\.00$'),
        '',
      );
      return _BadgeStyle(
        label: '${l10n.pendingStatus} · $formattedTotal',
        icon: Icons.schedule,
        iconColor: AppColors.iconWarning,
        background: isDark ? const Color(0xFF452205) : const Color(0xFFFFF4DE),
        foreground: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
      );
    }
    if (payments.any((payment) => payment.status == PaymentStatus.upcoming)) {
      return _BadgeStyle(
        label: l10n.upcomingStatus,
        icon: Icons.event_outlined,
        iconColor: AppColors.iconDefault,
        background: isDark ? const Color(0xFF3B1D5A) : const Color(0xFFF3EDFD),
        foreground: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8),
      );
    }
    return _BadgeStyle(
      label: l10n.paymentOnTime,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.iconSuccess,
      background: isDark ? const Color(0xFF064E3B) : const Color(0xFFD8F3DC),
      foreground: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF00796B),
    );
  }
}

class _BadgeStyle {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color foreground;

  const _BadgeStyle({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.foreground,
  });
}

class _StudentAvatar extends StatelessWidget {
  final String seed;
  final String? imageUrl;
  final String semanticLabel;

  const _StudentAvatar({
    required this.seed,
    this.imageUrl,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      seed: seed,
      imageUrl: imageUrl,
      size: 44,
      semanticLabel: semanticLabel,
    );
  }
}

class _EmptyStudents extends StatelessWidget {
  const _EmptyStudents();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textSecondary = AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder(context)),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color:
                    _courseDetailNeutralColor(context).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.groups_outlined,
                  size: 32, color: _courseDetailNeutralColor(context)),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.emptyStudentsTitle,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.emptyStudentsDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
