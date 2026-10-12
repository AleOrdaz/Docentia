import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../courses/providers/courses_provider.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  final String courseId;

  const AttendanceHistoryScreen({
    super.key,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final course = ref.watch(selectedCourseProvider);
    final sessionsAsync = ref.watch(courseSessionsProvider(courseId));

    final courseName = course?.name ?? 'Curso';

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0B132B) : const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registro de Asistencia',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              courseName,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_edu,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sin clases registradas aún',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando guardes la asistencia de una clase, su fecha, horario y detalle de alumnos presentes y faltas se conservarán aquí.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final session = sessions[index];
              return _buildSessionCard(context, session, primaryColor);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error al cargar historial: $err'),
        ),
      ),
    );
  }

  Widget _buildSessionCard(
      BuildContext context,
      ClassAttendanceSession session,
      Color primaryColor,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presentStudents = session.presentStudents;
    final absentStudents = session.absentStudents;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF22304A) : const Color(0xFFEEF2F9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          title: Text(
            session.formattedDate,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    session.formattedTimeRange,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Conteo de Presentes y Faltas
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 13,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Presentes: ${session.presentCount}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 13,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Faltas: ${session.absentCount}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 20),

            // SECCIÓN: Presentes
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Presentes — ${session.presentCount}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (presentStudents.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 8),
                child: Text(
                  'Ningún alumno presente registrado',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: presentStudents.length,
                itemBuilder: (ctx, sIndex) {
                  final s = presentStudents[sIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.studentName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 14),

            // SECCIÓN: Faltas
            Row(
              children: [
                const Icon(
                  Icons.cancel,
                  size: 16,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                Text(
                  'Faltas — ${session.absentCount}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (absentStudents.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 22, bottom: 4),
                child: Text(
                  'Sin inasistencias en esta clase',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: absentStudents.length,
                itemBuilder: (ctx, aIndex) {
                  final s = absentStudents[aIndex];
                  final isExcused = s.status == AttendanceStatus.excused ||
                      (s.note != null && s.note!.isNotEmpty);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.studentName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF00174D),
                            ),
                          ),
                        ),
                        if (isExcused)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.note ?? 'Justificada',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
