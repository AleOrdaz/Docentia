import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_form_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/providers/courses_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class TakeAttendanceScreen extends ConsumerStatefulWidget {
  final String courseId;

  const TakeAttendanceScreen({
    super.key,
    required this.courseId,
  });

  @override
  ConsumerState<TakeAttendanceScreen> createState() =>
      _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends ConsumerState<TakeAttendanceScreen> {
  int _index = 0;
  bool _saving = false;

  String get _todayDateStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  AttendanceDateParam get _param => AttendanceDateParam(
        courseId: widget.courseId,
        date: _todayDateStr,
      );

  Future<void> _markStudent(Student student, AttendanceStatus status) async {
    if (_saving) return;
    setState(() => _saving = true);

    HapticFeedback.mediumImpact();
    final notifier = ref.read(attendanceForDateProvider(_param).notifier);
    notifier.setStudentStatus(student.id, status);
    await notifier.persistAttendance();

    final students =
        ref.read(studentsForCourseProvider(widget.courseId)).value ?? [];
    final records = ref.read(attendanceForDateProvider(_param)).value ?? [];
    final allMarked = students.isNotEmpty &&
        students.every(
          (item) => records.any((record) => record.studentId == item.id),
        );
    if (allMarked) {
      await _saveSession();
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      _index = 0;
    });
  }

  Future<void> _saveSession() async {
    final course = ref.read(selectedCourseProvider);
    final students =
        ref.read(studentsForCourseProvider(widget.courseId)).value ?? [];
    final attendanceList =
        ref.read(attendanceForDateProvider(_param)).value ?? [];

    final studentItems = students.map((student) {
      final record =
          attendanceList.where((a) => a.studentId == student.id).firstOrNull;
      return StudentAttendanceItem(
        studentId: student.id,
        studentName: student.fullName,
        status: record?.status ?? AttendanceStatus.present,
        note: record?.note,
      );
    }).toList();

    final session = ClassAttendanceSession(
      id: 'session-${widget.courseId}-$_todayDateStr',
      courseId: widget.courseId,
      date: _todayDateStr,
      startTime: course?.startTime ?? '17:00',
      endTime: course?.endTime ?? '18:30',
      students: studentItems,
      createdAt: DateTime.now(),
    );

    await ref
        .read(courseSessionsProvider(widget.courseId).notifier)
        .saveSession(session);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final course = ref.watch(selectedCourseProvider);
    final studentsAsync = ref.watch(studentsForCourseProvider(widget.courseId));
    final attendanceAsync = ref.watch(attendanceForDateProvider(_param));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isClassDay = course?.isClassDay() ?? true;

    return Scaffold(
      backgroundColor: appPageBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        title: Text(
          l10n.attendanceLog,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.errorWithDetail('$err'))),
        data: (students) {
          if (students.isEmpty) {
            return _MessageState(
              icon: Icons.group_outlined,
              title: l10n.noStudentsInCourse,
              subtitle: l10n.noStudentsForAttendance,
            );
          }

          if (!isClassDay) {
            return _MessageState(
              icon: Icons.event_busy_outlined,
              title: l10n.notClassDayBanner,
            );
          }

          if (attendanceAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = attendanceAsync.value ?? [];
          final unmarked = students
              .where((student) =>
                  !records.any((record) => record.studentId == student.id))
              .toList();

          if (unmarked.isEmpty) {
            return _DailySummary(
              students: students,
              records: records,
              saving: _saving,
              onStatusChanged: _markStudent,
            );
          }

          final safeIndex = _index.clamp(0, unmarked.length - 1);
          final student = unmarked[safeIndex];

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                Text(
                  course?.name ?? l10n.courseFallback,
                  style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.attendanceStudentOf(
                    students.length - unmarked.length + 1,
                    students.length,
                  ),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: (students.length - unmarked.length) / students.length,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEEF2F6),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _AttendanceSwipeCard(
                    key: ValueKey('roll-${student.id}'),
                    student: student,
                    enabled: !_saving,
                    onSwipeRight: () =>
                        _markStudent(student, AttendanceStatus.present),
                    onSwipeLeft: () =>
                        _markStudent(student, AttendanceStatus.absent),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HintChip(
                        icon: Icons.arrow_back_rounded,
                        label: l10n.absentStatus,
                        color: const Color(0xFFBA1A1A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HintChip(
                        icon: Icons.arrow_forward_rounded,
                        label: l10n.presentStatus,
                        color: const Color(0xFF00796B),
                        iconOnRight: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.swipeMarkHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailySummary extends StatelessWidget {
  final List<Student> students;
  final List<Attendance> records;
  final bool saving;
  final Future<void> Function(Student student, AttendanceStatus status)
      onStatusChanged;

  const _DailySummary({
    required this.students,
    required this.records,
    required this.saving,
    required this.onStatusChanged,
  });

  AttendanceStatus? _statusFor(String studentId) {
    return records
        .where((record) => record.studentId == studentId)
        .firstOrNull
        ?.status;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textPrimary = AppColors.textPrimary(context);
    final presentCount = records
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    final lateCount =
        records.where((record) => record.status == AttendanceStatus.late).length;
    final absentCount = records
        .where((record) =>
            record.status == AttendanceStatus.absent ||
            record.status == AttendanceStatus.excused)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Text(
          l10n.attendanceDaySummary,
          style: AppTextStyles.titleLarge.copyWith(color: textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryStat(
                label: l10n.presentsLabel,
                count: presentCount,
                color: const Color(0xFF00796B),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryStat(
                label: l10n.latesLabel,
                count: lateCount,
                color: const Color(0xFFB45309),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryStat(
                label: l10n.absencesLabel,
                count: absentCount,
                color: const Color(0xFFBA1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...students.map((student) {
          final status = _statusFor(student.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SummaryStudentCard(
              student: student,
              status: status,
              enabled: !saving,
              onChanged: (next) => onStatusChanged(student, next),
            ),
          );
        }),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStudentCard extends StatelessWidget {
  final Student student;
  final AttendanceStatus? status;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onChanged;

  const _SummaryStudentCard({
    required this.student,
    required this.status,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = AppColors.textPrimary(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  student.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  student.fullName,
                  style: AppTextStyles.titleSmall.copyWith(color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatusButton(
                  label: l10n.presentStatus,
                  selected: status == AttendanceStatus.present,
                  color: const Color(0xFF00796B),
                  onTap: enabled
                      ? () => onChanged(AttendanceStatus.present)
                      : null,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatusButton(
                  label: l10n.lateStatus,
                  selected: status == AttendanceStatus.late,
                  color: const Color(0xFFB45309),
                  onTap: enabled ? () => onChanged(AttendanceStatus.late) : null,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _StatusButton(
                  label: l10n.absentStatus,
                  selected: status == AttendanceStatus.absent ||
                      status == AttendanceStatus.excused,
                  color: const Color(0xFFBA1A1A),
                  onTap: enabled
                      ? () => onChanged(AttendanceStatus.absent)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? color
          : (isDark ? const Color(0xFF0F172A) : color.withValues(alpha: 0.08)),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceSwipeCard extends StatefulWidget {
  final Student student;
  final bool enabled;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;

  const _AttendanceSwipeCard({
    super.key,
    required this.student,
    required this.enabled,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  @override
  State<_AttendanceSwipeCard> createState() => _AttendanceSwipeCardState();
}

class _AttendanceSwipeCardState extends State<_AttendanceSwipeCard> {
  double _offset = 0;

  static const _threshold = 90.0;

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    setState(() => _offset += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    if (_offset > _threshold) {
      widget.onSwipeRight();
    } else if (_offset < -_threshold) {
      widget.onSwipeLeft();
    }
    setState(() => _offset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final presentProgress = (_offset / _threshold).clamp(0.0, 1.0);
    final absentProgress = (-_offset / _threshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: 0.35 + (absentProgress * 0.65),
                    child: _SwipeBackdrop(
                      alignment: Alignment.centerLeft,
                      color: const Color(0xFFFDE8E8),
                      icon: Icons.cancel_rounded,
                      iconColor: const Color(0xFFBA1A1A),
                      label: l10n.absentStatus,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Opacity(
                    opacity: 0.35 + (presentProgress * 0.65),
                    child: _SwipeBackdrop(
                      alignment: Alignment.centerRight,
                      color: const Color(0xFFD8F3DC),
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF00796B),
                      label: l10n.presentStatus,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(_offset, 0),
            child: _StudentRollCard(student: widget.student),
          ),
        ],
      ),
    );
  }
}

class _StudentRollCard extends StatelessWidget {
  final Student student;

  const _StudentRollCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : const Color.fromRGBO(0, 35, 111, 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              student.initials,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              student.fullName,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (student.age > 0) ...[
            const SizedBox(height: 8),
            Text(
              l10n.yearsOld(student.age),
              style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwipeBackdrop extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String label;

  const _SwipeBackdrop({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 42),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool iconOnRight;

  const _HintChip({
    required this.icon,
    required this.label,
    required this.color,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconOnRight ? children.reversed.toList() : children,
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  const _MessageState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textPrimary = AppColors.textPrimary(context);
    final textSecondary = AppColors.textSecondary(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor ?? primaryColor),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(color: textPrimary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
