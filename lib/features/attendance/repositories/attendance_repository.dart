import '../../../core/services/storage_service.dart';
import '../models/attendance_model.dart';

class StudentAttendanceStats {
  final int totalClasses;
  final int presents;
  final int absences;
  final int excused;
  final int percentage;

  const StudentAttendanceStats({
    required this.totalClasses,
    required this.presents,
    required this.absences,
    required this.excused,
    required this.percentage,
  });
}

abstract class AttendanceRepository {
  Future<List<Attendance>> getAttendanceForDate(String courseId, String date);
  Future<void> saveAttendance(Attendance attendance);
  Future<void> saveBatchAttendance(List<Attendance> records);
  Future<StudentAttendanceStats> getStudentStats(String studentId, String courseId);

  // Sesiones de historial completo de clases
  Future<List<ClassAttendanceSession>> getSessionsForCourse(String courseId);
  Future<ClassAttendanceSession?> getSessionForDate(String courseId, String date);
  Future<void> saveClassSession(ClassAttendanceSession session);
}

class LocalAttendanceRepository implements AttendanceRepository {
  List<Attendance>? _cached;
  List<ClassAttendanceSession>? _cachedSessions;

  Future<List<Attendance>> _all() async {
    if (_cached != null) return _cached!;
    _cached = await StorageService.getAttendance();
    return _cached!;
  }

  Future<List<ClassAttendanceSession>> _allSessions() async {
    if (_cachedSessions != null) return _cachedSessions!;
    _cachedSessions = await StorageService.getAttendanceSessions();
    return _cachedSessions!;
  }

  @override
  Future<List<Attendance>> getAttendanceForDate(String courseId, String date) async {
    final list = await _all();
    return list
        .where((a) => a.courseId == courseId && a.date == date)
        .toList();
  }

  @override
  Future<void> saveAttendance(Attendance attendance) async {
    final list = (await _all()).toList();
    final index = list.indexWhere(
          (a) =>
      a.studentId == attendance.studentId &&
          a.courseId == attendance.courseId &&
          a.date == attendance.date,
    );

    if (index != -1) {
      list[index] = attendance;
    } else {
      list.add(attendance);
    }
    _cached = list;
    await StorageService.saveAttendance(list);
  }

  @override
  Future<void> saveBatchAttendance(List<Attendance> records) async {
    for (final record in records) {
      await saveAttendance(record);
    }
  }

  @override
  Future<StudentAttendanceStats> getStudentStats(String studentId, String courseId) async {
    final list = await _all();
    final studentRecords = list
        .where((a) => a.studentId == studentId && a.courseId == courseId)
        .toList();

    if (studentRecords.isEmpty) {
      return const StudentAttendanceStats(
        totalClasses: 0,
        presents: 0,
        absences: 0,
        excused: 0,
        percentage: 0,
      );
    }

    final total = studentRecords.length;
    final presents = studentRecords.where((a) => a.status == AttendanceStatus.present).length;
    final absences = studentRecords.where((a) => a.status == AttendanceStatus.absent).length;
    final excused = studentRecords
        .where((a) => a.status == AttendanceStatus.excused || (a.status == AttendanceStatus.absent && a.note != null))
        .length;

    final pct = total > 0 ? ((presents / total) * 100).round() : 0;

    return StudentAttendanceStats(
      totalClasses: total,
      presents: presents,
      absences: absences,
      excused: excused,
      percentage: pct,
    );
  }

  // --- Historial de Sesiones de Clase ---

  @override
  Future<List<ClassAttendanceSession>> getSessionsForCourse(String courseId) async {
    final list = await _allSessions();
    final filtered = list.where((s) => s.courseId == courseId).toList();
    // Ordenar de la más reciente a la más antigua
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Future<ClassAttendanceSession?> getSessionForDate(String courseId, String date) async {
    final list = await _allSessions();
    try {
      return list.firstWhere((s) => s.courseId == courseId && s.date == date);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveClassSession(ClassAttendanceSession session) async {
    final list = (await _allSessions()).toList();
    final index = list.indexWhere(
          (s) => s.courseId == session.courseId && s.date == session.date,
    );

    if (index != -1) {
      // Actualizar registro existente sin duplicar
      list[index] = session;
    } else {
      // Insertar nuevo registro
      list.insert(0, session);
    }

    // Reordenar por fecha descendente
    list.sort((a, b) => b.date.compareTo(a.date));
    _cachedSessions = list;
    await StorageService.saveAttendanceSessions(list);

    // Sincronizar también con los registros individuales de asistencia para estadísticas de los alumnos
    final individualRecords = session.students.map((studentItem) {
      return Attendance(
        id: 'att-${studentItem.studentId}-${session.date}',
        studentId: studentItem.studentId,
        courseId: session.courseId,
        date: session.date,
        status: studentItem.status,
        note: studentItem.note,
      );
    }).toList();

    await saveBatchAttendance(individualRecords);
  }
}
