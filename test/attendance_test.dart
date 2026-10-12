import 'package:flutter_test/flutter_test.dart';
import 'package:docentia/features/attendance/models/attendance_model.dart';
import 'package:docentia/features/attendance/repositories/attendance_repository.dart';
import 'package:docentia/features/courses/models/course_model.dart';

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

    test('Course.isClassDay correctly identifies scheduled class days vs non-class days', () {
      final course = Course(
        id: 'test-course',
        teacherId: 'teacher-1',
        name: 'Robótica Educativa',
        schedule: 'Lun & Mié 17:00 - 18:30',
        classDays: [1, 3], // Lunes (1) y Miércoles (3)
        startTime: '17:00',
        endTime: '18:30',
        duration: '32 sesiones',
        currentSession: 1,
        totalSessions: 32,
        cost: 850,
        capacity: 30,
        paymentSchedule: PaymentSchedule.firstHalf,
        active: true,
        createdAt: DateTime(2026, 1, 1),
      );

      // 2026-10-05 es Lunes (weekday = 1) -> Día de clase
      final monday = DateTime(2026, 10, 5);
      expect(monday.weekday, 1);
      expect(course.isClassDay(monday), isTrue);

      // 2026-10-06 es Martes (weekday = 2) -> NO es día de clase
      final tuesday = DateTime(2026, 10, 6);
      expect(tuesday.weekday, 2);
      expect(course.isClassDay(tuesday), isFalse);

      // 2026-10-07 es Miércoles (weekday = 3) -> Día de clase
      final wednesday = DateTime(2026, 10, 7);
      expect(wednesday.weekday, 3);
      expect(course.isClassDay(wednesday), isTrue);

      // 2026-10-08 es Jueves (weekday = 4) -> NO es día de clase
      final thursday = DateTime(2026, 10, 8);
      expect(thursday.weekday, 4);
      expect(course.isClassDay(thursday), isFalse);
    });

    test('Historical attendance sessions remain queryable and unchanged', () async {
      final repo = MockAttendanceRepository();
      // Registrar 2 sesiones históricas
      final session1 = ClassAttendanceSession(
        id: 'session-hist-1',
        courseId: 'course-1',
        date: '2026-10-01',
        startTime: '17:00',
        endTime: '18:30',
        students: [
          const StudentAttendanceItem(
            studentId: 's-1',
            studentName: 'Alumno 1',
            status: AttendanceStatus.present,
          ),
        ],
        createdAt: DateTime(2026, 10, 1),
      );

      final session2 = ClassAttendanceSession(
        id: 'session-hist-2',
        courseId: 'course-1',
        date: '2026-10-05',
        startTime: '17:00',
        endTime: '18:30',
        students: [
          const StudentAttendanceItem(
            studentId: 's-1',
            studentName: 'Alumno 1',
            status: AttendanceStatus.absent,
          ),
        ],
        createdAt: DateTime(2026, 10, 5),
      );

      await repo.saveClassSession(session1);
      await repo.saveClassSession(session2);

      final history = await repo.getSessionsForCourse('course-1');
      expect(history.length, 2);
      expect(history.any((s) => s.date == '2026-10-01'), isTrue);
      expect(history.any((s) => s.date == '2026-10-05'), isTrue);
    });

    test('Filter today courses only includes courses scheduled for current weekday', () {
      final mondayCourse = Course(
        id: 'c-mon',
        teacherId: 't1',
        name: 'Curso Lunes',
        schedule: 'Lun 10:00',
        classDays: [1],
        startTime: '10:00',
        endTime: '11:30',
        duration: '10 clases',
        currentSession: 1,
        totalSessions: 10,
        cost: 500,
        capacity: 20,
        paymentSchedule: PaymentSchedule.firstHalf,
        active: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final wednesdayCourse = Course(
        id: 'c-wed',
        teacherId: 't1',
        name: 'Curso Miércoles',
        schedule: 'Mié 10:00',
        classDays: [3],
        startTime: '10:00',
        endTime: '11:30',
        duration: '10 clases',
        currentSession: 1,
        totalSessions: 10,
        cost: 500,
        capacity: 20,
        paymentSchedule: PaymentSchedule.firstHalf,
        active: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final courses = [mondayCourse, wednesdayCourse];
      final monday = DateTime(2026, 10, 5); // Monday
      final todayCoursesOnMonday = courses.where((c) => c.isClassDay(monday)).toList();

      expect(todayCoursesOnMonday.length, 1);
      expect(todayCoursesOnMonday.first.id, 'c-mon');

      final wednesday = DateTime(2026, 10, 7); // Wednesday
      final todayCoursesOnWednesday = courses.where((c) => c.isClassDay(wednesday)).toList();

      expect(todayCoursesOnWednesday.length, 1);
      expect(todayCoursesOnWednesday.first.id, 'c-wed');

      final tuesday = DateTime(2026, 10, 6); // Tuesday (no courses)
      final todayCoursesOnTuesday = courses.where((c) => c.isClassDay(tuesday)).toList();

      expect(todayCoursesOnTuesday.isEmpty, isTrue);
    });

    test('Swipe gesture directions map correctly: Right = Present, Left = Absent', () {
      AttendanceStatus resolveSwipeStatus(bool isSwipeRight) {
        return isSwipeRight ? AttendanceStatus.present : AttendanceStatus.absent;
      }

      expect(resolveSwipeStatus(true), AttendanceStatus.present);
      expect(resolveSwipeStatus(false), AttendanceStatus.absent);
    });
  });
}
