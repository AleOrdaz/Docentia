import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_bottom_nav_bar.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../models/course_icon_helper.dart';
import '../models/course_model.dart';
import '../providers/courses_provider.dart';
import 'create_course_dialog.dart';
import '../../students/providers/students_provider.dart';

class CoursesListScreen extends ConsumerWidget {
  const CoursesListScreen({super.key});

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
    final coursesAsync = ref.watch(coursesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      backgroundColor:
      isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.myCourses,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _openCreateCourseDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                l10n.newCourseBtn,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: coursesAsync.when(
        data: (courses) {
          final activeCourses = courses.where((c) => c.active).toList();

          if (activeCourses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? primaryColor.withValues(alpha: 0.2)
                            : const Color(0xFFE8EFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school_outlined,
                          size: 48, color: primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noCoursesYet,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF00174D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noCoursesManageDesc,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF5F6368),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _openCreateCourseDialog(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.newCourseBtn),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: activeCourses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (ctx, index) {
              final course = activeCourses[index];
              return _buildCourseCard(context, ref, course, primaryColor);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(l10n.errorWithDetail('$err'))),
      ),
    );
  }

  Widget _buildCourseCard(
      BuildContext context, WidgetRef ref, Course course, Color primaryColor) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentsAsync = ref.watch(studentsForCourseProvider(course.id));
    final studentsCount = studentsAsync.value?.length ?? 0;
    final fillPct = course.capacity > 0
        ? ((studentsCount / course.capacity) * 100).round()
        : 0;

    final iconData = getCourseIcon(course.iconKey);

    return InkWell(
      onTap: () {
        ref.read(selectedCourseIdProvider.notifier).state = course.id;
        context.push('/course-detail/${course.id}');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  : const Color.fromRGBO(0, 35, 111, 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Icono personalizado, CURSO, Nombre, Horario + Opciones & Chevron
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
                        l10n.navCourses.toUpperCase(),
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
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
                          Icon(Icons.calendar_today_outlined,
                              size: 13,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF757682)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              course.formattedSchedule,
                              style: TextStyle(
                                fontSize: 12,
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
                      icon: Icon(Icons.more_horiz,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF9EA3AE),
                          size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                              Text(l10n.editCourseTitle),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF00174D),
                        size: 20),
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
                  '$studentsCount ${l10n.ofTotal(course.capacity)} ${l10n.studentPlural} ${l10n.enrolledWord}',
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
                          '${formatCurrency(course.cost)} / ${l10n.perMonth}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFF8FAFC)
                                : const Color(0xFF00174D),
                          ),
                        ),
                        Text(
                          l10n.courseFee,
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
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.duePrefix}: ${course.paymentSchedule.getLocalizedName(context)}',
                        style: TextStyle(
                          fontSize: 11,
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
}
