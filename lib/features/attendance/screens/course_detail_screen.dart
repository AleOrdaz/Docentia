import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../courses/models/course_icon_helper.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../courses/screens/create_course_dialog.dart';
import '../../students/providers/students_provider.dart';
import '../../students/screens/add_student_modal.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_stat_card.dart';
import '../widgets/student_attendance_tile.dart';

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

  String get _todayDateStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

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
    showDialog(
      context: context,
      builder: (ctx) => CreateCourseDialog(courseToEdit: course),
    );
  }

  Future<void> _saveAttendance() async {
    final course = ref.read(selectedCourseProvider);
    final now = DateTime.now();

    // Validación de negocio estricta: No permitir registrar si hoy no corresponde a clase
    if (course != null && !course.isClassDay(now)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No es posible registrar asistencia: Hoy no es día de clase para este curso.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final todayStr = _todayDateStr;
    final param = AttendanceDateParam(courseId: widget.courseId, date: todayStr);
    final studentsAsync = ref.read(studentsForCourseProvider(widget.courseId));
    final students = studentsAsync.value ?? [];
    final attendanceList = ref.read(attendanceForDateProvider(param)).value ?? [];

    // Guardar los nombres de los alumnos de forma permanente en la sesión histórica
    final List<StudentAttendanceItem> studentItems = students.map((student) {
      final record = attendanceList.where((a) => a.studentId == student.id).firstOrNull;
      final status = record?.status ?? AttendanceStatus.present;
      return StudentAttendanceItem(
        studentId: student.id,
        studentName: student.fullName,
        status: status,
        note: record?.note,
      );
    }).toList();

    final session = ClassAttendanceSession(
      id: 'session-${widget.courseId}-$todayStr',
      courseId: widget.courseId,
      date: todayStr,
      startTime: course?.startTime ?? '17:00',
      endTime: course?.endTime ?? '18:30',
      students: studentItems,
      createdAt: DateTime.now(),
    );

    // Guardar sesión en el repositorio de historial
    await ref.read(courseSessionsProvider(widget.courseId).notifier).saveSession(session);

    // Persistir registros individuales para estadísticas de alumnos
    await ref.read(attendanceForDateProvider(param).notifier).persistAttendance();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.secondaryFixed, size: 20),
              const SizedBox(width: 8),
              Text(
                'Asistencia guardada correctamente (${session.presentCount} presentes)',
              ),
            ],
          ),
          backgroundColor: AppColors.inverseSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(selectedCourseProvider);
    final studentsAsync = ref.watch(studentsForCourseProvider(widget.courseId));
    final attendanceParam = AttendanceDateParam(courseId: widget.courseId, date: _todayDateStr);
    final attendanceAsync = ref.watch(attendanceForDateProvider(attendanceParam));

    final courseName = course?.name ?? 'Curso';
    final courseSchedule = course?.formattedSchedule.isNotEmpty == true
        ? course!.formattedSchedule
        : (course?.schedule ?? '');
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                getCourseIcon(course?.iconKey),
                size: 20,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                courseName,
                style: AppTextStyles.titleMedium,
                overflow: TextOverflow.ellipsis,
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
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.2),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAq9Pvt1-c4_DUZSEdXdpOvNpYKqM7LG2oVztITe-6wiQKFFoh4-H4sQdDlNWqA_9Id0qaAvcj3Npis5rwFXKgrKhHc3QkdI4L6n4p-kcXLZI-bQWLPtS_UbwgMQDxNMsAnF1QJ6LBspB_FqcsoUhlyRstSkoQN7kUtQcOQ6P1Lu4w5NPnMshS0eicJ185YYRhVTjrhbQqGstpKPgo6AubEJakMHGGmjJpMMel095xfBra2EdOFYNav',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: studentsAsync.when(
        data: (students) {
          final todayRecords = attendanceAsync.value ?? [];

          final presentCount =
              todayRecords.where((a) => a.status == AttendanceStatus.present).length;
          final absentRecords =
          todayRecords.where((a) => a.status == AttendanceStatus.absent).toList();
          final absentCount = absentRecords.length;
          final excusedCount = absentRecords.where((a) => a.note != null).length;

          final displayedStudents = _filterPendingOnly
              ? students.where((s) => !todayRecords.any((a) => a.studentId == s.id)).toList()
              : students;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila de Horario y Menú de tres puntos (⋮)
                Row(
                  children: [
                    if (courseSchedule.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              courseSchedule,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // Menú de tres puntos para opciones del curso
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        tooltip: 'Opciones del curso',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openEditCourseDialog(course);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppColors.onSurface,
                                ),
                                SizedBox(width: 10),
                                Text('Editar curso'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Card de Sesión y Estadísticas
                AttendanceStatCard(
                  currentSession: course?.currentSession ?? 1,
                  totalSessions: course?.totalSessions ?? 32,
                  enrolled: students.length,
                  present: presentCount,
                  absent: absentCount,
                  excused: excusedCount,
                  capacity: course?.capacity ?? 30,
                ),
                const SizedBox(height: 16),

                // Botón Guardar Asistencia (condicionado al día de clase)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isClassDay ? _saveAttendance : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isClassDay ? primaryColor : AppColors.surfaceContainerHigh,
                      foregroundColor: isClassDay ? AppColors.onPrimary : AppColors.outline,
                      shape: const StadiumBorder(),
                    ),
                    icon: Icon(
                      isClassDay ? Icons.check : Icons.event_busy,
                      size: 20,
                    ),
                    label: Text(
                      'Guardar asistencia de hoy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isClassDay ? AppColors.onPrimary : AppColors.outline,
                      ),
                    ),
                  ),
                ),

                // Indicación clara cuando hoy no es día de clase
                if (!isClassDay)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Hoy no hay clase. La asistencia solo está disponible los días de clase.',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Botón Agregar Alumno
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _openAddStudentModal(courseName),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: primaryColor,
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.person_add, size: 20),
                    label: const Text(
                      '+ Agregar alumno',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Nuevo Botón: Registro de Asistencia (Historial completo de clases)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/course-detail/${widget.courseId}/history'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.history_edu, size: 20),
                    label: const Text(
                      'Registro de asistencia',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Encabezado de Lista de Alumnos + Filtros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lista de Alumnos', style: AppTextStyles.titleMedium),
                    Row(
                      children: [
                        FilterChip(
                          selected: !_filterPendingOnly,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: !_filterPendingOnly
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          label: Text('Todos (${students.length})'),
                          onSelected: (val) => setState(() => _filterPendingOnly = false),
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          selected: _filterPendingOnly,
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(
                            color: _filterPendingOnly
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                          label: Text('Sin registrar'),
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
                            ? 'Todos los alumnos tienen asistencia asignada hoy'
                            : 'Aún no hay alumnos inscritos en este curso',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.outline,
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
                      final record = todayRecords
                          .where((a) => a.studentId == student.id)
                          .firstOrNull;

                      final status = record?.status ?? AttendanceStatus.present;

                      return StudentAttendanceTile(
                        student: student,
                        name: student.fullName,
                        age: student.age,
                        status: status,
                        note: record?.note,
                        isEditable: isClassDay,
                        onStatusChanged: isClassDay
                            ? (newStatus) {
                          ref
                              .read(attendanceForDateProvider(attendanceParam).notifier)
                              .setStudentStatus(student.id, newStatus);
                        }
                            : null,
                        onNoteChanged: isClassDay
                            ? (newNote) {
                          ref
                              .read(attendanceForDateProvider(attendanceParam).notifier)
                              .setStudentStatus(student.id, status, note: newNote);
                        }
                            : null,
                        onTap: () {
                          context.push('/student-detail/${student.id}');
                        },
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
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
