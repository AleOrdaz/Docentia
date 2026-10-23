import 'package:docentia/features/courses/models/course_model.dart';
import 'package:docentia/features/courses/providers/courses_provider.dart';
import 'package:docentia/features/courses/repositories/courses_repository.dart';
import 'package:docentia/features/finance/logic/finance_fees.dart';
import 'package:docentia/features/finance/models/expense_model.dart';
import 'package:docentia/features/finance/screens/finance_screen.dart';
import 'package:docentia/features/payments/models/payment_model.dart';
import 'package:docentia/features/payments/providers/payments_provider.dart';
import 'package:docentia/features/students/models/student_model.dart';
import 'package:docentia/features/students/providers/students_provider.dart';
import 'package:docentia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resume el mes y compara contra el mes anterior', () {
    final now = DateTime(2026, 10, 22);
    final payments = [
      _payment(id: 'paid', amount: 8500, status: PaymentStatus.paid, month: 10),
      _payment(id: 'pending', amount: 2000, status: PaymentStatus.pending, month: 10),
      _payment(id: 'overdue', amount: 500, status: PaymentStatus.overdue, month: 10),
      _payment(id: 'upcoming', amount: 1500, status: PaymentStatus.upcoming, month: 10),
      _payment(id: 'prev', amount: 4250, status: PaymentStatus.paid, month: 9),
    ];

    final totals = financeTotals(payments, FinanceWindow.current(now));

    expect(totals.collected, 8500);
    expect(totals.toCollect, 2000);
    expect(totals.toCollectCount, 1);
    expect(totals.overdue, 500);
    expect(totals.overdueCount, 1);
    expect(totals.upcoming, 1500);
    expect(totals.upcomingCount, 1);
    expect(totals.changePercent, 100);
    expect(upcomingDues(payments, FinanceWindow.current(now)).length, 3);
    expect(realProfit(totals.collected, 1500), 7000);
  });

  test('la ganancia real resta solo los gastos del periodo', () {
    const expense = Expense(
      id: 'e1',
      teacherId: 't1',
      description: 'Material',
      amount: 1500,
      date: '2026-10-10',
      category: 'Materiales',
      courseId: 'c1',
    );
    const otherMonth = Expense(
      id: 'e2',
      teacherId: 't1',
      description: 'Licencia',
      amount: 900,
      date: '2026-09-10',
      category: 'Software',
      courseId: 'c1',
    );
    final window = FinanceWindow.month(2026, 10);
    expect(expensesTotal([expense, otherMonth], window), 1500);
    expect(realProfit(8500, 1500), 7000);
  });

  test('una cuota pendiente no inventa movimientos', () {
    final payment = _payment(id: 'p', amount: 200, status: PaymentStatus.pending, month: 10);
    expect(feeMovements(payment, DateTime(2026, 10, 2)), isEmpty);

    final paid = payment.copyWith(status: PaymentStatus.paid, paidAt: DateTime(2026, 10, 15, 10, 24));
    final movements = feeMovements(paid, DateTime(2026, 10, 22));
    expect(movements.map((item) => item.kind), [FeeMovementKind.paid, FeeMovementKind.generated]);
  });

  testWidgets('la vista principal muestra el resumen de cuotas', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    await tester.pumpWidget(_app(now));
    await tester.pumpAndSettle();

    expect(find.text('Finanzas'), findsOneWidget);
    expect(find.text('Control de cuotas y cobros.'), findsOneWidget);
    expect(find.text('Cobrado'), findsOneWidget);
    expect(find.text('Por cobrar'), findsOneWidget);
    expect(find.text('Rosa Jaramillo'), findsOneWidget);
    expect(find.text('Registrar pago'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el resumen cabe en un iPhone estrecho', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(DateTime.now()));
    await tester.pumpAndSettle();
    expect(find.text('Rosa Jaramillo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _app(DateTime now) {
  return ProviderScope(
    overrides: [
      coursesProvider.overrideWith((ref) => CoursesNotifier(_Courses([_course()]))),
      allActiveStudentsProvider.overrideWith((ref) async => [_student()]),
      allPaymentsProvider.overrideWith((ref) async => [
            _payment(
              id: 'pending',
              amount: 200,
              status: PaymentStatus.pending,
              month: now.month,
              year: now.year,
              dueDay: 28,
            ),
          ]),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: FinanceScreen(),
    ),
  );
}

Payment _payment({
  required String id,
  required double amount,
  required PaymentStatus status,
  required int month,
  int year = 2026,
  int dueDay = 15,
}) {
  return Payment(
    id: id,
    studentId: 's1',
    courseId: 'c1',
    periodMonth: month,
    periodYear: year,
    period: 'Octubre $year',
    amount: amount,
    dueDate: '$year-${month.toString().padLeft(2, '0')}-${dueDay.toString().padLeft(2, '0')}',
    status: status,
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
