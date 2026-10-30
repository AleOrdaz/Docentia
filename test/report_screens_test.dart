import 'package:docentia/features/attendance/models/attendance_model.dart';
import 'package:docentia/features/attendance/providers/attendance_provider.dart';
import 'package:docentia/features/attendance/repositories/attendance_repository.dart';
import 'package:docentia/features/courses/models/course_model.dart';
import 'package:docentia/features/courses/providers/courses_provider.dart';
import 'package:docentia/features/courses/repositories/courses_repository.dart';
import 'package:docentia/features/finance/screens/finance_reports_screen.dart';
import 'package:docentia/features/payments/models/payment_model.dart';
import 'package:docentia/features/payments/providers/payments_provider.dart';
import 'package:docentia/features/payments/repositories/payments_repository.dart';
import 'package:docentia/features/reports/screens/course_report_screen.dart';
import 'package:docentia/features/students/models/student_model.dart';
import 'package:docentia/features/students/providers/students_provider.dart';
import 'package:docentia/features/students/repositories/students_repository.dart';
import 'package:docentia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();

  testWidgets('Finanzas muestra el botón para exportar el PDF', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_financeApp(now));
    await tester.pumpAndSettle();

    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Exportar PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el reporte del curso lista alumnos y asistencia del periodo', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_courseApp(now));
    await tester.pumpAndSettle();

    expect(find.text('Reporte del curso'), findsOneWidget);
    expect(find.text('Arte'), findsWidgets);
    expect(find.text('Rosa Jaramillo'), findsOneWidget);
    expect(find.textContaining('Asistencias 1'), findsOneWidget);
    expect(find.textContaining('Retardo 0'), findsOneWidget);
    expect(find.text('Exportar PDF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _financeApp(DateTime now) {
  return ProviderScope(
    overrides: [
      coursesProvider.overrideWith((ref) => CoursesNotifier(_Courses([_course()]))),
      allActiveStudentsProvider.overrideWith((ref) async => [_student()]),
      allPaymentsProvider.overrideWith((ref) async => [_paid(now)]),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: FinanceReportsScreen(),
    ),
  );
}

Widget _courseApp(DateTime now) {
  final month = now.month.toString().padLeft(2, '0');
  final date = '${now.year}-$month-06';
  return ProviderScope(
    overrides: [
      selectedCourseIdProvider.overrideWith((ref) => 'c1'),
      coursesProvider.overrideWith((ref) => CoursesNotifier(_Courses([_course()]))),
      studentsRepositoryProvider.overrideWithValue(_StudentsRepo([_student()])),
      paymentsRepositoryProvider.overrideWithValue(_PaymentsRepo([_paid(now)])),
      allActiveStudentsProvider.overrideWith((ref) async => [_student()]),
      allPaymentsProvider.overrideWith((ref) async => [_paid(now)]),
      attendanceRepositoryProvider.overrideWithValue(
        _AttendanceRepo([
          ClassAttendanceSession(
            id: 's1',
            courseId: 'c1',
            date: date,
            startTime: '17:00',
            endTime: '18:30',
            students: const [
              StudentAttendanceItem(
                studentId: 's1',
                studentName: 'Rosa Jaramillo',
                status: AttendanceStatus.present,
              ),
            ],
            createdAt: now,
          ),
        ]),
      ),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: CourseReportScreen(courseId: 'c1'),
    ),
  );
}

Course _course() {
  return Course(
    id: 'c1',
    teacherId: 't1',
    name: 'Arte',
    schedule: 'Mar y Jue',
    classDays: const [2, 4],
    startTime: '5:00 PM',
    endTime: '6:30 PM',
    duration: '32 sesiones',
    currentSession: 1,
    totalSessions: 32,
    cost: 200,
    capacity: 12,
    paymentSchedule: PaymentSchedule.endOfMonth,
    iconKey: 'art',
    active: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

Student _student() {
  return Student(
    id: 's1',
    courseId: 'c1',
    name: 'Rosa',
    lastName: 'Jaramillo',
    age: 10,
    tutorName: 'Ana',
    tutorPhone: '5551234',
    tutorEmail: 'ana@docentia.app',
    active: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

Payment _paid(DateTime now) {
  return Payment(
    id: 'p1',
    studentId: 's1',
    courseId: 'c1',
    periodMonth: now.month,
    periodYear: now.year,
    amount: 200,
    dueDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-15',
    status: PaymentStatus.paid,
    paidAmount: 200,
  );
}

class _StudentsRepo implements StudentsRepository {
  final List<Student> students;
  _StudentsRepo(this.students);
  @override
  Future<void> addStudent(Student student) async {}
  @override
  Future<void> deactivateStudent(String id) async {}
  @override
  Future<List<Student>> getAllStudents() async => students;
  @override
  Future<Student?> getStudentById(String id) async =>
      students.where((s) => s.id == id).firstOrNull;
  @override
  Future<List<Student>> getStudentsByCourse(String courseId) async =>
      students.where((s) => s.courseId == courseId).toList();
  @override
  Future<void> updateStudent(Student student) async {}
}

class _PaymentsRepo implements PaymentsRepository {
  final List<Payment> payments;
  _PaymentsRepo(this.payments);
  @override
  Future<void> addPayment(Payment payment) async {}
  @override
  Future<void> confirmPayment(String paymentId, {double? paidAmount, DateTime? paidDate}) async {}
  @override
  Future<List<Payment>> getAllPayments() async => payments;
  @override
  Future<List<Payment>> getPaymentsByCourse(String courseId) async =>
      payments.where((p) => p.courseId == courseId).toList();
  @override
  Future<List<Payment>> getPaymentsByStudent(String studentId, String courseId) async =>
      payments.where((p) => p.studentId == studentId && p.courseId == courseId).toList();
  @override
  Future<bool> hasFeeForPeriod({
    required String studentId,
    required String courseId,
    required int year,
    required int month,
  }) async => false;
  @override
  Future<bool> hasProratedFeeForPeriod({
    required String studentId,
    required String courseId,
    required int year,
    required int month,
  }) async => false;
  @override
  Future<void> updatePaymentDueDate(String paymentId, DueDateOption option) async {}
}

class _AttendanceRepo implements AttendanceRepository {
  final List<ClassAttendanceSession> sessions;
  _AttendanceRepo(this.sessions);

  @override
  Future<List<Attendance>> getAttendanceForDate(String courseId, String date) async => [];
  @override
  Future<ClassAttendanceSession?> getSessionForDate(String courseId, String date) async => null;
  @override
  Future<List<ClassAttendanceSession>> getSessionsForCourse(String courseId) async => sessions;
  @override
  Future<StudentAttendanceStats> getStudentStats(String studentId, String courseId) async {
    return const StudentAttendanceStats(totalClasses: 0, presents: 0, absences: 0, excused: 0, percentage: 0);
  }
  @override
  Future<void> saveAttendance(Attendance attendance) async {}
  @override
  Future<void> saveBatchAttendance(List<Attendance> records) async {}
  @override
  Future<void> saveClassSession(ClassAttendanceSession session) async {}
}

class _Courses implements CoursesRepository {
  final List<Course> courses;
  _Courses(this.courses);
  @override
  Future<void> deleteCourse(String id) async {}
  @override
  Future<Course?> getCourseById(String id) async => null;
  @override
  Future<List<Course>> getCourses() async => courses;
  @override
  Future<void> saveCourse(Course course) async {}
  @override
  Future<void> updateCourse(Course course) async {}
}
