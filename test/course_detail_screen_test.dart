import 'package:docentia/features/attendance/screens/course_detail_screen.dart';
import 'package:docentia/features/courses/models/course_model.dart';
import 'package:docentia/features/courses/providers/courses_provider.dart';
import 'package:docentia/features/courses/repositories/courses_repository.dart';
import 'package:docentia/features/payments/models/payment_model.dart';
import 'package:docentia/features/payments/providers/payments_provider.dart';
import 'package:docentia/features/payments/repositories/payments_repository.dart';
import 'package:docentia/features/students/models/student_model.dart';
import 'package:docentia/features/students/providers/students_provider.dart';
import 'package:docentia/features/students/repositories/students_repository.dart';
import 'package:docentia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el detalle del curso muestra encabezado, acciones y lista', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Arte'), findsOneWidget);
    expect(find.text('Agregar alumno'), findsWidgets);
    expect(find.text('Asistencia'), findsOneWidget);
    expect(find.text('Certificados'), findsOneWidget);
    expect(find.text('Reporte'), findsOneWidget);
    expect(find.text('Lista de alumnos'), findsOneWidget);
    expect(find.text('Rosa Jaramillo'), findsOneWidget);
    expect(find.text('Próxima clase'), findsOneWidget);
    expect(find.text('Cantidad de alumnos'), findsOneWidget);
    expect(find.text('1 alumno'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sin alumnos muestra el estado vacío', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCourseIdProvider.overrideWith((ref) => 'c1'),
          coursesProvider.overrideWith((ref) => CoursesNotifier(_Courses([_course()]))),
          studentsRepositoryProvider.overrideWithValue(_StudentsRepo(const [])),
          paymentsRepositoryProvider.overrideWithValue(_PaymentsRepo(const [])),
          allActiveStudentsProvider.overrideWith((ref) async => []),
          allPaymentsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: CourseDetailScreen(courseId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay alumnos'), findsOneWidget);
    expect(find.text('Agrega alumnos para comenzar a gestionar este curso.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app() {
  return ProviderScope(
    overrides: [
      selectedCourseIdProvider.overrideWith((ref) => 'c1'),
      coursesProvider.overrideWith((ref) => CoursesNotifier(_Courses([_course()]))),
      studentsRepositoryProvider.overrideWithValue(_StudentsRepo([_student()])),
      paymentsRepositoryProvider.overrideWithValue(_PaymentsRepo([_upcoming()])),
      allActiveStudentsProvider.overrideWith((ref) async => [_student()]),
      allPaymentsProvider.overrideWith((ref) async => [_upcoming()]),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: CourseDetailScreen(courseId: 'c1'),
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
    startTime: '17:00',
    endTime: '18:30',
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
    age: 16,
    tutorName: 'Ana',
    tutorPhone: '5551234',
    tutorEmail: 'ana@docentia.app',
    active: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

Payment _upcoming() {
  final now = DateTime.now();
  return Payment(
    id: 'p1',
    studentId: 's1',
    courseId: 'c1',
    periodMonth: now.month,
    periodYear: now.year,
    amount: 200,
    dueDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-28',
    status: PaymentStatus.upcoming,
  );
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
