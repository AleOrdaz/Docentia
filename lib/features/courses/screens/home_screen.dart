import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/teacher_avatar.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/providers/students_provider.dart';
import '../models/course_model.dart';
import '../providers/courses_provider.dart';
import '../widgets/course_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final teacher = ref.watch(authProvider).teacher;
    final coursesAsync = ref.watch(coursesProvider);
    final allStudentsAsync = ref.watch(allActiveStudentsProvider);

    final teacherFirstName =
        teacher?.name.trim().split(' ').first ?? 'Antonio';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBody: true,
      backgroundColor:
      isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE),
      // 1.1 AppBar / Encabezado
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
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => context.push('/profile'),
              borderRadius: BorderRadius.circular(100),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TeacherAvatar(
                    radius: 18,
                    photoUrl: teacher?.photoUrl,
                    name: teacher?.name,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF5F6368),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: coursesAsync.when(
        data: (courses) {
          final activeCourses = courses.where((c) => c.active).toList();
          final now = DateTime.now();
          final todayCourses = activeCourses.where((c) => c.isClassDay(now)).toList();
          final totalStudentsCount = allStudentsAsync.value?.length ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF151D2E)
                        : const Color(0xFFE3EDFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF22304A)
                          : const Color(0xFFD6E2FB),
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
                                  color: isDark
                                      ? const Color(0xFFF8FAFC)
                                      : const Color(0xFF00174D),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n?.summarySubtitle ??
                                    'Aquí tienes el resumen de tus cursos.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF5F6368),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 15,
                                    color: isDark
                                        ? const Color(0xFFE2E8F0)
                                        : const Color(0xFF00174D),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      '${activeCourses.length} ${activeCourses.length == 1
                                          ? (l10n?.activeCourseSingular ?? 'curso activo')
                                          : (l10n?.activeCoursePlural ?? 'cursos activos')}  ·  $totalStudentsCount ${totalStudentsCount == 1
                                          ? (l10n?.studentSingular ?? 'alumno')
                                          : (l10n?.studentPlural ?? 'alumnos')}',
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
                ),
                const SizedBox(height: 18),

                _buildPendingPaymentsCard(
                  context: context,
                  ref: ref,
                  courses: courses,
                  l10n: l10n,
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Text(
                      l10n?.todaysCoursesTitle ?? 'Cursos de hoy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF00174D),
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (todayCourses.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark
                              ? primaryColor.withValues(alpha: 0.2)
                              : const Color(0xFFE3EDFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${todayCourses.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // 5. Lista de cursos de hoy o Estados agradables según contexto
                if (activeCourses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151D2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF22304A)
                            : const Color(0xFFEEF2F9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : const Color.fromRGBO(0, 0, 0, 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? primaryColor.withValues(alpha: 0.2)
                                : const Color(0xFFE8EFFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.noCoursesYet ?? 'Aún no tienes cursos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF00174D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n?.noCoursesYetDesc ?? 'Crea tu primer curso para comenzar a inscribir alumnos y llevar el control.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (todayCourses.isEmpty)
                // Mensaje agradable cuando no hay clases programadas para hoy
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151D2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF22304A)
                            : const Color(0xFFEEF2F9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : const Color.fromRGBO(0, 35, 111, 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? primaryColor.withValues(alpha: 0.2)
                                : const Color(0xFFE8EFFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.event_available_outlined,
                            size: 34,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n?.noCoursesTodayTitle ?? 'Hoy no tienes clases programadas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF00174D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n?.noCoursesTodayDesc ?? 'Es tiempo de un respiro. Un buen momento para organizar tus próximos cursos o revisar tus avances del mes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF5F6368),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, index) {
                      final course = todayCourses[index];
                      return CourseSummaryCard(
                        course: course,
                        onTap: () async {
                          ref.read(selectedCourseIdProvider.notifier).state =
                              course.id;
                          await context.push('/course-detail/${course.id}');
                          ref.read(studentsRevisionProvider.notifier).state++;
                          ref.invalidate(allActiveStudentsProvider);
                          ref.invalidate(coursesProvider);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 28),
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

  Widget _buildPendingPaymentsCard({
    required BuildContext context,
    required WidgetRef ref,
    required List<Course> courses,
    required AppLocalizations? l10n,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var pendingCount = 0;
    for (final course in courses) {
      final payments =
          ref.watch(paymentsForCourseProvider(course.id)).value ?? [];
      pendingCount +=
          payments.where((p) => p.status != PaymentStatus.paid).length;
    }

    final label = pendingCount == 1
        ? (l10n?.pendingPaymentSingular ?? 'pago pendiente')
        : (l10n?.pendingPaymentPlural ?? 'pagos pendientes');
    final cardColor =
        isDark ? const Color(0xFF3A3318) : const Color(0xFFFFF4C8);
    final borderColor =
        isDark ? const Color(0xFF5C4E22) : const Color(0xFFF3E4A2);
    final iconColor =
        isDark ? const Color(0xFFF6DE7A) : const Color(0xFFC9A227);
    final iconBg =
        isDark ? const Color(0xFF4E431C) : const Color(0xFFFFE89A);

    return InkWell(
      onTap: () => context.go('/finance'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color.fromRGBO(0, 35, 111, 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.payments_outlined,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$pendingCount $label',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF00174D),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF5F6368),
            ),
          ],
        ),
      ),
    );
  }

}
