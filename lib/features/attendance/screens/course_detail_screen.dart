import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../courses/screens/create_course_dialog.dart';
import '../../finance/providers/finance_catalog_provider.dart';
import '../../finance/widgets/finance_sheets.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../../students/screens/add_student_modal.dart';
import '../../students/screens/edit_student_modal.dart';

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
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddStudentModal(String courseName) {
    showModalBottomSheet<void>(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.studentDeactivated)),
              );
            },
            child: Text(l10n.confirmDeactivate),
          ),
        ],
      ),
    );
  }

  void _openStudentActions(Student student, Course? course) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final primary = Theme.of(context).colorScheme.primary;

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
                  leading: _StudentAvatar(initials: student.initials),
                  title: Text(
                    student.fullName,
                    style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                  ),
                  subtitle: student.age > 0
                      ? Text(
                          l10n.yearsOld(student.age),
                          style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                        )
                      : null,
                ),
                const Divider(height: 8),
                ListTile(
                  leading: Icon(Icons.person_outline, color: primary),
                  title: Text(l10n.viewStudentProfile),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openStudent(student.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payments_outlined, color: primary),
                  title: Text(l10n.financeRegisterPayment),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _registerPayment(student, course);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.event_available_outlined, color: primary),
                  title: Text(l10n.viewStudentAttendance),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openStudent(student.id);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: primary),
                  title: Text(l10n.editStudentInfo),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _editStudent(student);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text(
                    l10n.deleteStudentAction,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDeactivate(student);
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
    final studentsAsync = ref.watch(studentsForCourseProvider(widget.courseId));
    final payments = ref.watch(paymentsForCourseProvider(widget.courseId)).value ?? [];
    final l10n = AppLocalizations.of(context)!;
    final courseName = course?.name ?? l10n.courseFallback;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final iconColors = getCourseIconColors(course?.iconKey);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchController.text.trim().toLowerCase();

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
              context.go('/home');
            }
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 22, color: textPrimary),
            tooltip: l10n.courseOptions,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary(ctx)),
                    const SizedBox(width: 10),
                    Text(l10n.editCourseTitle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 20, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 10),
                    Text(l10n.deleteCourseBtn, style: const TextStyle(color: Color(0xFFD32F2F))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, _) => Center(child: Text(l10n.errorWithDetail('$err'))),
        data: (students) {
          final pendingStudents = students.where((student) {
            final studentPayments =
                payments.where((payment) => payment.studentId == student.id).toList();
            return !_isPaymentCurrent(studentPayments);
          }).toList();
          final visible = (_filterPendingOnly ? pendingStudents : students)
              .where((student) => query.isEmpty || student.fullName.toLowerCase().contains(query))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: iconColors.background(isDark),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      getCourseIcon(course?.iconKey),
                      size: 26,
                      color: iconColors.icon(isDark),
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
                          const SizedBox(height: 2),
                          Text(
                            course.getLocalizedHeaderSchedule(context),
                            style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.groups_outlined,
                        title: l10n.courseStudentCountLabel,
                        subtitle: l10n.courseStudentCount(students.length),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.calendar_today_outlined,
                        title: l10n.courseNextClass,
                        subtitle: _nextClassLabel(context, course),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: l10n.addStudentShort,
                icon: Icons.person_add_alt_1,
                onPressed: () => _openAddStudentModal(courseName),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.event_available_outlined,
                      label: l10n.attendanceAction,
                      onTap: () => context.push('/course-detail/${widget.courseId}/attendance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.workspace_premium_outlined,
                      label: l10n.certificatesBtn,
                      onTap: () {
                        ref.read(selectedCourseIdProvider.notifier).state = widget.courseId;
                        context.push('/course-detail/${widget.courseId}/certificates');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.description_outlined,
                      label: l10n.courseReportBtn,
                      onTap: () {
                        ref.read(selectedCourseIdProvider.notifier).state = widget.courseId;
                        context.push('/course-detail/${widget.courseId}/report');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.studentListTitle,
                      style: AppTextStyles.titleMedium.copyWith(color: textPrimary),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.searchStudentsHint,
                    onPressed: () {
                      setState(() {
                        _searching = !_searching;
                        if (!_searching) _searchController.clear();
                      });
                    },
                    icon: Icon(
                      _searching ? Icons.close : Icons.search,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              if (_searching) ...[
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.searchStudentsHint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceLow(context),
                    prefixIcon: Icon(Icons.search, color: textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: '${l10n.filterAll} (${students.length})',
                    selected: !_filterPendingOnly,
                    onTap: () => setState(() => _filterPendingOnly = false),
                  ),
                  _FilterChip(
                    label: '${l10n.filterPending} (${pendingStudents.length})',
                    selected: _filterPendingOnly,
                    onTap: () => setState(() => _filterPendingOnly = true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (students.isEmpty)
                _EmptyStudents(onAdd: () => _openAddStudentModal(courseName))
              else if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    query.isNotEmpty ? l10n.noStudentsSearch : l10n.allStudentsCurrent,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                  ),
                )
              else
                for (final student in visible) ...[
                  _StudentTile(
                    student: student,
                    payments: payments.where((payment) => payment.studentId == student.id).toList(),
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

  String? _nextClassLabel(BuildContext context, Course? course) {
    final next = course?.nextClassDate();
    if (next == null) return null;
    final locale = Localizations.localeOf(context).toString();
    final raw = DateFormat('EEE, d MMM', locale).format(next).replaceAll('.', '');
    if (raw.isEmpty) return raw;
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  bool _isPaymentCurrent(List<Payment> payments) {
    if (payments.isEmpty) return true;
    return payments.every((payment) =>
        payment.status == PaymentStatus.paid ||
        payment.status == PaymentStatus.upcoming);
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: AppColors.cardBg(context),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder(context)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
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

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final textSecondary = AppColors.textSecondary(context);
    return Material(
      color: selected ? primary : Colors.transparent,
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Student student;
  final List<Payment> payments;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  const _StudentTile({
    required this.student,
    required this.payments,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final style = _badgeStyle(l10n, payments, Theme.of(context).brightness == Brightness.dark);

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
              _StudentAvatar(initials: student.initials),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (student.age > 0)
                          Text(
                            l10n.yearsOld(student.age),
                            style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                          ),
                        if (student.age > 0 && style != null) const SizedBox(width: 8),
                        if (style != null)
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: style.background,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(style.icon, size: 13, color: style.foreground),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        style.label,
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
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onMenu,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.more_vert, size: 18, color: textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _BadgeStyle? _badgeStyle(AppLocalizations l10n, List<Payment> payments, bool isDark) {
    if (payments.isEmpty) return null;
    if (payments.any((payment) => payment.status == PaymentStatus.overdue)) {
      return _BadgeStyle(
        label: l10n.financeOverdue,
        icon: Icons.cancel_rounded,
        background: isDark ? const Color(0xFF3B171A) : const Color(0xFFFDE8E8),
        foreground: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFBA1A1A),
      );
    }
    if (payments.any((payment) => payment.status == PaymentStatus.pending)) {
      return _BadgeStyle(
        label: l10n.pendingStatus,
        icon: Icons.schedule,
        background: isDark ? const Color(0xFF452205) : const Color(0xFFFFF4DE),
        foreground: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
      );
    }
    if (payments.any((payment) => payment.status == PaymentStatus.upcoming)) {
      return _BadgeStyle(
        label: l10n.upcomingStatus,
        icon: Icons.event_outlined,
        background: isDark ? const Color(0xFF3B1D5A) : const Color(0xFFF3EDFD),
        foreground: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8),
      );
    }
    return _BadgeStyle(
      label: l10n.paymentOnTime,
      icon: Icons.check_circle_rounded,
      background: isDark ? const Color(0xFF064E3B) : const Color(0xFFD8F3DC),
      foreground: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF00796B),
    );
  }
}

class _BadgeStyle {
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  const _BadgeStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });
}

class _StudentAvatar extends StatelessWidget {
  final String initials;

  const _StudentAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CircleAvatar(
      radius: 22,
      backgroundColor: primary,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _EmptyStudents extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyStudents({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    final textSecondary = AppColors.textSecondary(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups_outlined, size: 32, color: primary),
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
          const SizedBox(height: 16),
          AppPrimaryButton(
            label: l10n.addStudentShort,
            icon: Icons.person_add_alt_1,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
