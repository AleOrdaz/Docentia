import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../finance/providers/finance_provider.dart';
import '../../students/providers/students_provider.dart';
import '../models/course_icon_helper.dart';
import '../models/course_model.dart';
import '../providers/courses_provider.dart';
import 'create_course_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openCreateCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CreateCourseDialog(),
    );
  }

  void _openEditCourseDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (ctx) => CreateCourseDialog(courseToEdit: course),
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final teacher = ref.watch(authProvider).teacher;
    final coursesAsync = ref.watch(coursesProvider);
    final financeSummary = ref.watch(financeSummaryProvider);
    final allStudentsAsync = ref.watch(allActiveStudentsProvider);

    final teacherFirstName =
        teacher?.name.trim().split(' ').first ?? 'Antonio';
    final teacherPhotoUrl = teacher?.photoUrl ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAq9Pvt1-c4_DUZSEdXdpOvNpYKqM7LG2oVztITe-6wiQKFFoh4-H4sQdDlNWqA_9Id0qaAvcj3Npis5rwFXKgrKhHc3QkdI4L6n4p-kcXLZI-bQWLPtS_UbwgMQDxNMsAnF1QJ6LBspB_FqcsoUhlyRstSkoQN7kUtQcOQ6P1Lu4w5NPnMshS0eicJ185YYRhVTjrhbQqGstpKPgo6AubEJakMHGGmjJpMMel095xfBra2EdOFYNav';

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
            // Logo de la aplicación (birrete estilizado)
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Docentia',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
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
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(teacherPhotoUrl),
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: coursesAsync.when(
        data: (courses) {
          final activeCourses = courses.where((c) => c.active).toList();
          final now = DateTime.now();
          final todayCourses = activeCourses.where((c) => c.isClassDay(now)).toList();
          final totalStudentsCount = allStudentsAsync.value?.length ?? 0;
          final totalMonthlyIncome = financeSummary.totalIncome;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Encabezado del profesor y banner ilustrativo (sin saludo dinámico de hora)
                Stack(
                  children: [
                    // Fondo curvo decorativo con ilustración estilizada en el lado derecho
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      width: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0x00E8F0FE), Color(0xFFE3EDFF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildDecorativeIllustration(),
                          ),
                        ),
                      ),
                    ),

                    // Nombre del profesor y resumen general
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherFirstName,
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
                            l10n?.summarySubtitle ?? 'Aquí tienes el resumen de tus cursos.',
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
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF5F6368),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${activeCourses.length} ${activeCourses.length == 1
                                    ? (l10n?.activeCourseSingular ?? 'curso activo')
                                    : (l10n?.activeCoursePlural ?? 'cursos activos')}  ·  $totalStudentsCount ${totalStudentsCount == 1
                                    ? (l10n?.studentSingular ?? 'alumno')
                                    : (l10n?.studentPlural ?? 'alumnos')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF5F6368),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3. Resumen general (3 tarjetas horizontales compactas)
                Row(
                  children: [
                    // Tarjeta 1: Cursos activos
                    Expanded(
                      child: _buildSummaryCard(
                        context: context,
                        icon: Icons.school_rounded,
                        iconBgColor: const Color(0xFFE3EDFF),
                        iconColor: const Color(0xFF00236F),
                        value: '${activeCourses.length}',
                        label: l10n?.summaryCardActiveCourses ?? 'Cursos activos',
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tarjeta 2: Alumnos
                    Expanded(
                      child: _buildSummaryCard(
                        context: context,
                        icon: Icons.group_rounded,
                        iconBgColor: const Color(0xFFD8F3DC),
                        iconColor: const Color(0xFF00796B),
                        value: '$totalStudentsCount',
                        label: l10n?.summaryCardStudents ?? 'Alumnos',
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tarjeta 3: Ingresos del mes
                    Expanded(
                      child: _buildSummaryCard(
                        context: context,
                        icon: Icons.bar_chart_rounded,
                        iconBgColor: const Color(0xFFFFF4DE),
                        iconColor: const Color(0xFFD97706),
                        value: formatCurrency(totalMonthlyIncome),
                        label: l10n?.summaryCardIncome ?? 'Ingresos del mes',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. Sección "Cursos de hoy" + Botón "+ Nuevo curso"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                              color: const Color(0xFFE3EDFF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${todayCourses.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00236F),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: () => _openCreateCourseDialog(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00236F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        l10n?.newCourseBtn ?? 'Nuevo curso',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEEF2F9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.02),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8EFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            size: 40,
                            color: Color(0xFF00236F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.noCoursesYet ?? 'Aún no tienes cursos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00174D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n?.noCoursesYetDesc ?? 'Crea tu primer curso para comenzar a inscribir alumnos y llevar el control.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () => _openCreateCourseDialog(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00236F),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(l10n?.create ?? 'Crear curso'),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEEF2F9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 35, 111, 0.03),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8EFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_available_outlined,
                            size: 34,
                            color: Color(0xFF00236F),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n?.noCoursesTodayTitle ?? 'Hoy no tienes clases programadas',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00174D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n?.noCoursesTodayDesc ?? 'Es tiempo de un respiro. Un buen momento para organizar tus próximos cursos o revisar tus avances del mes.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5F6368),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => context.push('/finance'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00236F),
                                side: const BorderSide(color: Color(0xFFCBD9F5)),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                              ),
                              icon: const Icon(Icons.bar_chart_outlined, size: 16),
                              label: Text(
                                l10n?.navFinance ?? 'Revisar avances del mes',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => context.push('/courses'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFE3EDFF),
                                foregroundColor: const Color(0xFF00236F),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                              ),
                              icon: const Icon(Icons.school_outlined, size: 16),
                              label: Text(
                                '${l10n?.viewAllCourses ?? "Ver todos los cursos"} (${activeCourses.length})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayCourses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (ctx, index) {
                          final course = todayCourses[index];
                          return _buildCourseCard(context, ref, course, l10n);
                        },
                      ),
                      if (activeCourses.length > todayCourses.length) ...[
                        const SizedBox(height: 14),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => context.push('/courses'),
                            icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF00236F)),
                            label: Text(
                              '${l10n?.viewAllCourses ?? "Ver todos los cursos"} (${activeCourses.length})',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00236F),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

  // Tarjeta de resumen (Cursos activos, Alumnos, Ingresos)
  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color.fromRGBO(0, 35, 111, 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.25) : iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF757682),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de curso idéntica a la referencia visual
  Widget _buildCourseCard(
      BuildContext context, WidgetRef ref, Course course, AppLocalizations? l10n) {
    final studentsAsync = ref.watch(studentsForCourseProvider(course.id));
    final studentsCount = studentsAsync.value?.length ?? 0;
    final fillPct = course.capacity > 0
        ? ((studentsCount / course.capacity) * 100).round() : 0;

    final iconData = getCourseIcon(course.iconKey);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () async {
        ref.read(selectedCourseIdProvider.notifier).state = course.id;
        await context.push('/course-detail/${course.id}');
        // Al regresar al Home desde Detalle de Curso, asegurar actualización inmediata
        ref.read(studentsRevisionProvider.notifier).state++;
        ref.invalidate(allActiveStudentsProvider);
        ref.invalidate(coursesProvider);
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151D2E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color.fromRGBO(0, 35, 111, 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Icono personalizado en caja celeste + CURSO + Nombre + Horario + Opciones ⋮ y chevron >
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del curso en squircle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2E4E)
                        : const Color(0xFFE3EDFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    iconData,
                    size: 28,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 14),

                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.navCourses.toUpperCase() ?? 'CURSO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF757682),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        course.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF00174D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF757682),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              course.getLocalizedSchedule(context),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF5F6368),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botón menú ⋮ y chevron >
                Column(
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        color: isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF9EA3AE),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _openEditCourseDialog(context, course);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n?.editCourseTitle ?? 'Editar curso'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF00174D),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Barra de progreso y capacidad
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$studentsCount ${l10n?.ofTotal(course.capacity) ?? "de ${course.capacity}"} ${l10n?.studentPlural ?? "alumnos"} ${l10n?.enrolledWord ?? "inscritos"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF43474E),
                  ),
                ),
                Text(
                  '$fillPct%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00897B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: course.capacity > 0
                    ? (studentsCount / course.capacity).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 6,
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEEF2F6),
                valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
              ),
            ),
            const SizedBox(height: 14),

            // Línea inferior: Cuota del curso + Periodo de vencimiento
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Costo
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF452205)
                            : const Color(0xFFFFF4DE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.monetization_on_outlined,
                        size: 16,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatCurrency(course.cost)} / ${l10n?.perMonth ?? "mes"}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF00174D),
                          ),
                        ),
                        Text(
                          l10n?.courseFee ?? 'Cuota del curso',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF757682),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Vencimiento
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B1D5A)
                        : const Color(0xFFF3EDFD),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 13,
                        color: isDark
                            ? const Color(0xFFD8B4FE)
                            : const Color(0xFF6B21A8),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${l10n?.duePrefix ?? "Vence"}: ${course.paymentSchedule.getLocalizedName(context)}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFD8B4FE)
                              : const Color(0xFF6B21A8),
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
    );
  }

  // Ilustración decorativa para el banner (libros + portalápices estilizados)
  Widget _buildDecorativeIllustration() {
    return SizedBox(
      width: 100,
      height: 90,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Libros apilados
          Positioned(
            bottom: 6,
            right: 32,
            child: Container(
              width: 58,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF4A68FF),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 22,
            right: 36,
            child: Container(
              width: 52,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF81A2FF),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          // Portalápices
          Positioned(
            bottom: 6,
            right: 4,
            child: Container(
              width: 26,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD6E2FB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Lápiz azul
                  Positioned(
                    top: -16,
                    left: 5,
                    child: Container(
                      width: 5,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Lápiz amarillo
                  Positioned(
                    top: -12,
                    right: 6,
                    child: Container(
                      width: 5,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}