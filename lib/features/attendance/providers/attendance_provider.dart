import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return LocalAttendanceRepository();
});

class AttendanceDateParam {
  final String courseId;
  final String date;

  const AttendanceDateParam({required this.courseId, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AttendanceDateParam &&
              runtimeType == other.runtimeType &&
              courseId == other.courseId &&
              date == other.date;

  @override
  int get hashCode => courseId.hashCode ^ date.hashCode;
}

class AttendanceNotifier extends StateNotifier<AsyncValue<List<Attendance>>> {
  final AttendanceRepository _repository;
  final AttendanceDateParam _param;
  final Ref? _ref;

  AttendanceNotifier(this._repository, this._param, [this._ref])
      : super(const AsyncValue.loading()) {
    loadAttendance();
  }

  /// Validación estricta a nivel de lógica de negocio:
  /// Comprueba si la fecha indicada corresponde a un día de clase para este curso.
  bool isDateClassDay(String dateStr) {
    if (_ref == null) return true;
    try {
      final coursesAsync = _ref!.read(coursesProvider);
      final courses = coursesAsync.value ?? [];
      final course = courses.where((c) => c.id == _param.courseId).firstOrNull;
      if (course == null) return true;

      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          final date = DateTime(y, m, d);
          return course.isClassDay(date);
        }
      }
      return course.isClassDay();
    } catch (_) {
      return true;
    }
  }

  Future<void> loadAttendance() async {
    try {
      final records = await _repository.getAttendanceForDate(
        _param.courseId,
        _param.date,
      );
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setStudentStatus(String studentId, AttendanceStatus status, {String? note}) {
    // REGLA DE NEGOCIO ESTRICTA:
    // Si la fecha actual/parámetro NO corresponde a un día de clase del curso,
    // bloquear y no permitir ninguna modificación de asistencia.
    if (!isDateClassDay(_param.date)) {
      return;
    }

    final currentList = state.value ?? [];
    final existingIndex = currentList.indexWhere((a) => a.studentId == studentId);

    List<Attendance> updatedList;
    if (existingIndex != -1) {
      updatedList = List<Attendance>.from(currentList);
      updatedList[existingIndex] = updatedList[existingIndex].copyWith(
        status: status,
        note: note,
      );
    } else {
      updatedList = [
        ...currentList,
        Attendance(
          id: 'att-$studentId-${_param.date}',
          studentId: studentId,
          courseId: _param.courseId,
          date: _param.date,
          status: status,
          note: note,
        ),
      ];
    }

    state = AsyncValue.data(updatedList);
  }

  Future<void> persistAttendance() async {
    // REGLA DE NEGOCIO: No permitir persistir registros si no es día de clase
    if (!isDateClassDay(_param.date)) {
      return;
    }
    final records = state.value ?? [];
    await _repository.saveBatchAttendance(records);
  }
}

final attendanceForDateProvider = StateNotifierProvider.family<
    AttendanceNotifier, AsyncValue<List<Attendance>>, AttendanceDateParam>(
      (ref, param) {
    final repo = ref.watch(attendanceRepositoryProvider);
    return AttendanceNotifier(repo, param, ref);
  },
);

class StudentStatsParam {
  final String studentId;
  final String courseId;

  const StudentStatsParam({required this.studentId, required this.courseId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is StudentStatsParam &&
              runtimeType == other.runtimeType &&
              studentId == other.studentId &&
              courseId == other.courseId;

  @override
  int get hashCode => studentId.hashCode ^ courseId.hashCode;
}

final studentStatsProvider =
FutureProvider.family<StudentAttendanceStats, StudentStatsParam>(
      (ref, param) async {
    final repo = ref.watch(attendanceRepositoryProvider);
    return repo.getStudentStats(param.studentId, param.courseId);
  },
);

// --- Notifier y Provider para el historial de sesiones de un curso ---

class CourseSessionsNotifier
    extends StateNotifier<AsyncValue<List<ClassAttendanceSession>>> {
  final AttendanceRepository _repository;
  final String _courseId;

  CourseSessionsNotifier(this._repository, this._courseId)
      : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      final sessions = await _repository.getSessionsForCourse(_courseId);
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveSession(ClassAttendanceSession session) async {
    await _repository.saveClassSession(session);
    final sessions = await _repository.getSessionsForCourse(_courseId);
    state = AsyncValue.data(sessions);
  }
}

final courseSessionsProvider = StateNotifierProvider.family<
    CourseSessionsNotifier, AsyncValue<List<ClassAttendanceSession>>, String>(
      (ref, courseId) {
    final repo = ref.watch(attendanceRepositoryProvider);
    return CourseSessionsNotifier(repo, courseId);
  },
);
