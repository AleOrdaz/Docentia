import 'package:flutter_test/flutter_test.dart';
import 'package:docentia/features/attendance/models/attendance_model.dart';
import 'package:docentia/features/attendance/repositories/attendance_repository.dart';

class MockAttendanceRepository implements AttendanceRepository {
  final List<Attendance> _attendance = [];
  final List<ClassAttendanceSession> _sessions = [];

  @override
  Future<List<Attendance>> getAttendanceForDate(String courseId, String date) async {
    return _attendance.where((a) => a.courseId == courseId && a.date == date).toList();
  }

  @override
  Future<void> saveAttendance(Attendance attendance) async {
    final index = _attendance.indexWhere((a) =>
    a.studentId == attendance.studentId &&
        a.courseId == attendance.courseId &&
        a.date == attendance.date);
    if (index != -1) {
      _attendance[index] = attendance;
    } else {
      _attendance.add(attendance);
    }
  }

  @override
  Future<void> saveBatchAttendance(List<Attendance> records) async {
    for (final r in records) {
      await saveAttendance(r);
    }
  }

  @override
  Future<StudentAttendanceStats> getStudentStats(String studentId, String courseId) async {
    final list = _attendance
        .where((a) => a.studentId == studentId && a.courseId == courseId)
        .toList();
    if (list.isEmpty) {
      return const StudentAttendanceStats(
        totalClasses: 0,
        presents: 0,
        absences: 0,
        excused: 0,
        percentage: 0,
      );
    }
    final presents = list.where((a) => a.status == AttendanceStatus.present).length;
    final absences = list.where((a) => a.status == AttendanceStatus.absent).length;
    final excused = list.where((a) => a.status == AttendanceStatus.excused).length;
    return StudentAttendanceStats(
      totalClasses: list.length,
      presents: presents,
      absences: absences,
      excused: excused,
      percentage: ((presents / list.length) * 100).round(),
    );
  }

  @override
  Future<List<ClassAttendanceSession>> getSessionsForCourse(String courseId) async {
    return _sessions.where((s) => s.courseId == courseId).toList();
  }

  @override
  Future<ClassAttendanceSession?> getSessionForDate(String courseId, String date) async {
    try {
      return _sessions.firstWhere((s) => s.courseId == courseId && s.date == date);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveClassSession(ClassAttendanceSession session) async {
    final index = _sessions.indexWhere(
            (s) => s.courseId == session.courseId && s.date == session.date);
    if (index != -1) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
  }
}

void main() {
  group('Attendance Calculation and Session Tests', () {
    test('MockAttendanceRepository calculates dynamic stats properly', () async {
      final repo = MockAttendanceRepository();
      for (int i = 0; i < 10; i++) {
        await repo.saveAttendance(
          Attendance(
            id: 'att-$i',
            studentId: 'student-1',
            courseId: 'course-1',
            date: '2026-10-0$i',
            status: i < 9 ? AttendanceStatus.present : AttendanceStatus.absent,
          ),
        );
      }

      final stats = await repo.getStudentStats('student-1', 'course-1');

      expect(stats.totalClasses, 10);
      expect(stats.presents, 9);
      expect(stats.percentage, 90);
    });

    test('Updating attendance does not create duplicate record for same date', () async {
      final repo = MockAttendanceRepository();
      const testDate = '2026-10-07';

      await repo.saveAttendance(
        const Attendance(
          id: 'test-1',
          studentId: 'student-test',
          courseId: 'course-1',
          date: testDate,
          status: AttendanceStatus.present,
        ),
      );

      var records = await repo.getAttendanceForDate('course-1', testDate);
      final countBefore = records.where((r) => r.studentId == 'student-test').length;
      expect(countBefore, 1);

      // Now update to absent
      await repo.saveAttendance(
        const Attendance(
          id: 'test-1-updated',
          studentId: 'student-test',
          courseId: 'course-1',
          date: testDate,
          status: AttendanceStatus.absent,
        ),
      );

      records = await repo.getAttendanceForDate('course-1', testDate);
      final countAfter = records.where((r) => r.studentId == 'student-test').length;
      expect(countAfter, 1);
      expect(
        records.firstWhere((r) => r.studentId == 'student-test').status,
        AttendanceStatus.absent,
      );
    });

    test('Saving ClassAttendanceSession stores date, time and students list', () async {
      final repo = MockAttendanceRepository();
      final session = ClassAttendanceSession(
        id: 'session-1',
        courseId: 'course-1',
        date: '2026-10-07',
        startTime: '5:00 PM',
        endTime: '6:30 PM',
        students: const [
          StudentAttendanceItem(
            studentId: 's-1',
            studentName: 'Juan Pérez',
            status: AttendanceStatus.present,
          ),
          StudentAttendanceItem(
            studentId: 's-2',
            studentName: 'Carlos Hernández',
            status: AttendanceStatus.absent,
          ),
        ],
        createdAt: DateTime(2026, 10, 7),
      );

      await repo.saveClassSession(session);
      final sessions = await repo.getSessionsForCourse('course-1');
      expect(sessions.length, 1);
      expect(sessions.first.presentCount, 1);
      expect(sessions.first.absentCount, 1);
      expect(sessions.first.presentStudents.first.studentName, 'Juan Pérez');
      expect(sessions.first.absentStudents.first.studentName, 'Carlos Hernández');
    });
  });
}
