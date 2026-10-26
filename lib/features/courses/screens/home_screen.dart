import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../attendance/models/calendar_event_model.dart';
import '../../attendance/providers/calendar_events_provider.dart';
import '../../attendance/screens/create_event_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/providers/students_provider.dart';
import '../../students/screens/add_student_modal.dart';
import '../models/course_icon_helper.dart';
import '../models/course_model.dart';
import '../providers/courses_provider.dart';
import 'create_course_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final teacher = ref.watch(authProvider).teacher;
    final coursesAsync = ref.watch(coursesProvider);
    final allStudentsAsync = ref.watch(allActiveStudentsProvider);
    final events = ref.watch(calendarEventsProvider).value ?? const <CalendarEvent>[];
    final payments = ref.watch(allPaymentsProvider).value ?? const <Payment>[];

    final teacherFirstName =
        teacher?.name.trim().split(' ').first ?? 'Antonio';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navy = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBody: true,
      backgroundColor:
          isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Docentia',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: navy,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: coursesAsync.when(
        data: (courses) {
          final activeCourses = courses.where((c) => c.active).toList();
          final totalStudentsCount = allStudentsAsync.value?.length ?? 0;
          final now = DateTime.now();
          final todayCourses =
              activeCourses.where((c) => c.isClassDay(now)).toList();
          final todayKey = _dateKey(now);
          final todayEvents =
              events.where((event) => event.date == todayKey).toList();
          final dueFees = _upcomingFees(
            payments,
            courses,
            now,
            Localizations.localeOf(context).toString(),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GreetingCard(
                  teacherFirstName: teacherFirstName,
                  activeCourses: activeCourses.length,
                  totalStudents: totalStudentsCount,
                  l10n: l10n,
                  isDark: isDark,
                  navy: navy,
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: l10n?.homeShortcutsTitle ?? 'Accesos rápidos',
                  action: l10n?.edit ?? 'Editar',
                  navy: navy,
                ),
                const SizedBox(height: 12),
                _ShortcutsGrid(
                  isDark: isDark,
                  navy: navy,
                  l10n: l10n,
                  onNewCourse: () => _openCreateCourse(context),
                  onAddStudent: () =>
                      _openAddStudent(context, ref, activeCourses, l10n),
                  onNewEvent: () => showCreateEventSheet(context),
                  onRecordExpense: () => context.push('/finance/expenses'),
                ),
                const SizedBox(height: 26),
                _SectionHeader(
                  title: l10n?.homeActivityTitle ?? 'Tu actividad de hoy',
                  action: l10n?.homeSeeAll ?? 'Ver todo',
                  navy: navy,
                  onAction: () => context.go('/calendar'),
                ),
                const SizedBox(height: 12),
                _TodayActivityList(
                  courses: todayCourses,
                  events: todayEvents,
                  fees: dueFees,
                  l10n: l10n,
                  isDark: isDark,
                  navy: navy,
                  onOpenCourse: (course) {
                    ref.read(selectedCourseIdProvider.notifier).state = course.id;
                    context.push('/course-detail/${course.id}');
                  },
                  onOpenEvent: () => context.go('/calendar'),
                  onOpenFee: (payment) =>
                      context.push('/finance/payment/${payment.id}'),
                ),
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
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _openCreateCourse(BuildContext context) {
    showModalBottomSheet<Course>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CreateCourseDialog(),
    );
  }

  Future<void> _openAddStudent(
    BuildContext context,
    WidgetRef ref,
    List<Course> courses,
    AppLocalizations? l10n,
  ) async {
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.createCourseFirst ??
                'Crea un curso para agregar alumnos',
          ),
        ),
      );
      _openCreateCourse(context);
      return;
    }

    Course? course = courses.length == 1 ? courses.first : null;
    course ??= await showModalBottomSheet<Course>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.6,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151D2E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n?.selectCourseTitle ?? 'Selecciona un curso',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF00174D),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (ctx, index) {
                        final item = courses[index];
                        return ListTile(
                          title: Text(item.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(ctx).pop(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (course == null || !context.mounted) return;
    final selectedCourse = course;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddStudentModal(
        courseId: selectedCourse.id,
        courseName: selectedCourse.name,
      ),
    );
    ref.invalidate(allActiveStudentsProvider);
  }
}

class _GreetingCard extends StatelessWidget {
  final String teacherFirstName;
  final int activeCourses;
  final int totalStudents;
  final AppLocalizations? l10n;
  final bool isDark;
  final Color navy;
  final Color primaryColor;

  const _GreetingCard({
    required this.teacherFirstName,
    required this.activeCourses,
    required this.totalStudents,
    required this.l10n,
    required this.isDark,
    required this.navy,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: isDark ? 0.18 : 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.32 : 0.24),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -12,
            bottom: -12,
            width: 200,
            child: Image.asset(
              'assets/images/home_greeting.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 120, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.homeGreeting(teacherFirstName) ??
                      'Hola, $teacherFirstName',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: navy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.summarySubtitle ??
                      'Aquí tienes el resumen de tus cursos.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF5F6368),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.school_outlined, size: 15, color: navy),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '$activeCourses ${activeCourses == 1 ? (l10n?.activeCourseSingular ?? 'curso activo') : (l10n?.activeCoursePlural ?? 'cursos activos')}  ·  $totalStudents ${totalStudents == 1 ? (l10n?.studentSingular ?? 'alumno') : (l10n?.studentPlural ?? 'alumnos')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF00174D),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final Color navy;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.navy,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: navy,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              disabledForegroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _ShortcutsGrid extends StatelessWidget {
  final bool isDark;
  final Color navy;
  final AppLocalizations? l10n;
  final VoidCallback onNewCourse;
  final VoidCallback onAddStudent;
  final VoidCallback onNewEvent;
  final VoidCallback onRecordExpense;

  const _ShortcutsGrid({
    required this.isDark,
    required this.navy,
    required this.l10n,
    required this.onNewCourse,
    required this.onAddStudent,
    required this.onNewEvent,
    required this.onRecordExpense,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _ShortcutSpec(
        icon: Icons.add,
        label: l10n?.newCourseBtn ?? 'Nuevo curso',
        background: isDark ? const Color(0xFF1E2E4E) : const Color(0xFFEEF3FF),
        foreground: isDark ? const Color(0xFF1E2E4E) : const Color(0xFF2563EB),
        onTap: onNewCourse,
      ),
      _ShortcutSpec(
        icon: Icons.person_add_alt_1_outlined,
        label: l10n?.addStudentShort ?? 'Agregar alumno',
        background: isDark ? const Color(0xFF13403A) : const Color(0xFFE6FAF6),
        foreground: isDark ? const Color(0xFF13403A) : const Color(0xFF0D9488),
        onTap: onAddStudent,
      ),
      _ShortcutSpec(
        icon: Icons.event_available_outlined,
        label: l10n?.newEventShortcut ?? 'Nuevo evento',
        background: isDark ? const Color(0xFF2E1B4E) : const Color(0xFFF3EEFF),
        foreground: isDark ? const Color(0xFF2E1B4E) : const Color(0xFF7C3AED),
        onTap: onNewEvent,
      ),
      _ShortcutSpec(
        icon: Icons.receipt_long_outlined,
        label: l10n?.recordExpenseShortcut ?? 'Registrar gasto',
        background: isDark ? const Color(0xFF4C1D24) : const Color(0xFFFFF1F2),
        foreground: isDark ? const Color(0xFF4C1D24) : const Color(0xFFE11D48),
        onTap: onRecordExpense,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _ShortcutChip(spec: items[0], navy: navy)),
            const SizedBox(width: 10),
            Expanded(child: _ShortcutChip(spec: items[1], navy: navy)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _ShortcutChip(spec: items[2], navy: navy)),
            const SizedBox(width: 10),
            Expanded(child: _ShortcutChip(spec: items[3], navy: navy)),
          ],
        ),
      ],
    );
  }
}

class _ShortcutSpec {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _ShortcutSpec({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
}

class _ShortcutChip extends StatelessWidget {
  final _ShortcutSpec spec;
  final Color navy;

  const _ShortcutChip({required this.spec, required this.navy});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: spec.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: spec.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: Icon(spec.icon, size: 16, color: spec.foreground),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  spec.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: navy.withValues(alpha: 0.45)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayActivityList extends StatelessWidget {
  final List<Course> courses;
  final List<CalendarEvent> events;
  final List<_FeeActivity> fees;
  final AppLocalizations? l10n;
  final bool isDark;
  final Color navy;
  final ValueChanged<Course> onOpenCourse;
  final VoidCallback onOpenEvent;
  final ValueChanged<Payment> onOpenFee;

  const _TodayActivityList({
    required this.courses,
    required this.events,
    required this.fees,
    required this.l10n,
    required this.isDark,
    required this.navy,
    required this.onOpenCourse,
    required this.onOpenEvent,
    required this.onOpenFee,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      for (final course in courses)
        _ActivityRow(
          icon: getCourseIcon(course.iconKey),
          iconBackground: getCourseIconColors(course.iconKey).background(isDark),
          iconColor: getCourseIconColors(course.iconKey).icon(isDark),
          title: course.name,
          subtitle: _formatTimeRange(context, course.startTime, course.endTime),
          navy: navy,
          isDark: isDark,
          onTap: () => onOpenCourse(course),
        ),
      for (final event in events)
        _ActivityRow(
          icon: Icons.event_available_outlined,
          iconBackground:
              isDark ? const Color(0xFF2E1B4E) : const Color(0xFFF3EEFF),
          iconColor: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF7C3AED),
          title: event.title,
          subtitle: [
            _formatTimeRange(context, event.startTime, event.endTime ?? ''),
            if (event.location != null && event.location!.trim().isNotEmpty)
              event.location!.trim(),
          ].where((part) => part.isNotEmpty).join('  ·  '),
          navy: navy,
          isDark: isDark,
          onTap: onOpenEvent,
        ),
      for (final fee in fees)
        _ActivityRow(
          icon: Icons.payments_outlined,
          iconBackground:
              isDark ? const Color(0xFF13403A) : const Color(0xFFE6FAF6),
          iconColor: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0D9488),
          title: l10n?.feeDueSoonTitle ?? 'Cuota por vencer',
          subtitle: [
            fee.courseName,
            l10n?.dueOnDate(fee.dueLabel) ?? 'Vence el ${fee.dueLabel}',
          ].where((part) => part.isNotEmpty).join(' · '),
          badge: l10n?.pendingStatus ?? 'Pendiente',
          navy: navy,
          isDark: isDark,
          onTap: () => onOpenFee(fee.payment),
        ),
    ];

    if (rows.isEmpty) {
      return _ActivityRow(
        icon: Icons.event_available_outlined,
        iconBackground:
            isDark ? const Color(0xFF1E2E4E) : const Color(0xFFEEF3FF),
        iconColor: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
        title: l10n?.homeNoActivityTitle ?? 'Nada por hoy',
        subtitle: l10n?.homeNoActivityDesc ??
            'Cuando tengas clases, eventos o cuotas, aparecerán aquí.',
        navy: navy,
        isDark: isDark,
        showChevron: false,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          rows[i],
        ],
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final Color navy;
  final bool isDark;
  final VoidCallback? onTap;
  final bool showChevron;

  const _ActivityRow({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.navy,
    required this.isDark,
    this.badge,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Material(
      color: isDark ? const Color(0xFF151D2E) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: navy,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3F2E0A)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: navy.withValues(alpha: 0.35),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeActivity {
  final Payment payment;
  final String courseName;
  final String dueLabel;

  const _FeeActivity({
    required this.payment,
    required this.courseName,
    required this.dueLabel,
  });
}

String _dateKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? _parseDate(String raw) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw.trim());
  if (match == null) return DateTime.tryParse(raw);
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

TimeOfDay? _parseTime(String raw) {
  final clean = raw.trim().toUpperCase();
  if (clean.isEmpty) return null;
  final isPM = clean.contains('PM');
  final isAM = clean.contains('AM');
  final digits = clean.replaceAll(RegExp(r'[^0-9:]'), '');
  final parts = digits.split(':');
  if (parts.length < 2) return null;
  var hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (isPM && hour < 12) hour += 12;
  if (isAM && hour == 12) hour = 0;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTimeRange(BuildContext context, String start, String end) {
  final locale = Localizations.localeOf(context).toString();
  final startTime = _parseTime(start);
  final endTime = _parseTime(end);
  if (startTime == null) {
    return [start, end].where((part) => part.trim().isNotEmpty).join(' – ');
  }
  final formatter = DateFormat.jm(locale);
  final startLabel = formatter.format(
    DateTime(2000, 1, 1, startTime.hour, startTime.minute),
  );
  if (endTime == null) return startLabel;
  final endLabel = formatter.format(
    DateTime(2000, 1, 1, endTime.hour, endTime.minute),
  );
  return '$startLabel – $endLabel';
}

List<_FeeActivity> _upcomingFees(
  List<Payment> payments,
  List<Course> courses,
  DateTime now,
  String locale,
) {
  final today = DateTime(now.year, now.month, now.day);
  final limit = today.add(const Duration(days: 7));
  final coursesById = {for (final course in courses) course.id: course};
  final seenCourses = <String>{};
  final items = <_FeeActivity>[];

  final unpaid = payments
      .where((payment) => payment.status != PaymentStatus.paid)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  for (final payment in unpaid) {
    final due = _parseDate(payment.dueDate);
    if (due == null || due.isAfter(limit)) continue;
    if (!seenCourses.add(payment.courseId)) continue;
    items.add(
      _FeeActivity(
        payment: payment,
        courseName: coursesById[payment.courseId]?.name ?? '',
        dueLabel: DateFormat('d MMM y', locale).format(due),
      ),
    );
    if (items.length == 2) break;
  }
  return items;
}
