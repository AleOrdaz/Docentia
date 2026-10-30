import 'package:docentia/features/attendance/models/attendance_model.dart';
import 'package:docentia/features/courses/models/course_model.dart';
import 'package:docentia/features/finance/logic/finance_fees.dart';
import 'package:docentia/features/finance/models/expense_model.dart';
import 'package:docentia/features/finance/providers/finance_catalog_provider.dart';
import 'package:docentia/features/payments/models/payment_model.dart';
import 'package:docentia/features/reports/logic/report_builders.dart';
import 'package:docentia/features/students/models/student_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final course = Course(
    id: 'c1',
    teacherId: 't1',
    name: 'Robótica',
    schedule: 'Lun 17:00 - 18:30',
    classDays: const [1],
    startTime: '17:00',
    endTime: '18:30',
    duration: '32 sesiones',
    currentSession: 4,
    totalSessions: 32,
    cost: 8500,
    capacity: 12,
    paymentSchedule: PaymentSchedule.firstHalf,
    active: true,
    createdAt: DateTime(2026, 9, 1),
  );

  Student student(String id, String name, String last) {
    return Student(
      id: id,
      courseId: 'c1',
      name: name,
      lastName: last,
      age: 10,
      tutorName: 'Tutor',
      tutorPhone: '555',
      tutorEmail: 'tutor@test.com',
      active: true,
      createdAt: DateTime(2026, 9, 1),
    );
  }

  ClassAttendanceSession session({
    required String date,
    required List<StudentAttendanceItem> students,
  }) {
    return ClassAttendanceSession(
      id: 's-$date',
      courseId: 'c1',
      date: date,
      startTime: '17:00',
      endTime: '18:30',
      students: students,
      createdAt: DateTime(2026, 10, 1),
    );
  }

  test('el reporte del curso separa retardos y filtra por periodo', () {
    final ana = student('a', 'Ana', 'López');
    final luis = student('b', 'Luis', 'Pérez');
    final window = FinanceWindow.month(2026, 10);
    final data = buildCourseReport(
      course: course,
      students: [ana, luis],
      sessions: [
        session(
          date: '2026-10-06',
          students: const [
            StudentAttendanceItem(studentId: 'a', studentName: 'Ana López', status: AttendanceStatus.present),
            StudentAttendanceItem(studentId: 'b', studentName: 'Luis Pérez', status: AttendanceStatus.late),
          ],
        ),
        session(
          date: '2026-10-13',
          students: const [
            StudentAttendanceItem(studentId: 'a', studentName: 'Ana López', status: AttendanceStatus.absent),
            StudentAttendanceItem(studentId: 'b', studentName: 'Luis Pérez', status: AttendanceStatus.present),
          ],
        ),
        session(
          date: '2026-09-29',
          students: const [
            StudentAttendanceItem(studentId: 'a', studentName: 'Ana López', status: AttendanceStatus.absent),
          ],
        ),
      ],
      payments: const [
        Payment(
          id: 'p1',
          studentId: 'a',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-10-15',
          periodMonth: 10,
          periodYear: 2026,
          status: PaymentStatus.paid,
          paidAmount: 8500,
        ),
        Payment(
          id: 'p2',
          studentId: 'b',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-10-15',
          periodMonth: 10,
          periodYear: 2026,
          status: PaymentStatus.overdue,
        ),
        Payment(
          id: 'p3',
          studentId: 'a',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-09-15',
          periodMonth: 9,
          periodYear: 2026,
          status: PaymentStatus.overdue,
        ),
      ],
      expenses: const [
        Expense(
          id: 'e1',
          teacherId: 't1',
          description: 'Material',
          amount: 500,
          date: '2026-10-08',
          category: 'Materiales',
          courseId: 'c1',
        ),
        Expense(
          id: 'e2',
          teacherId: 't1',
          description: 'Otro curso',
          amount: 200,
          date: '2026-10-08',
          category: 'Materiales',
          courseId: 'c2',
        ),
      ],
      window: window,
    );

    expect(data.sessionCount, 2);
    expect(data.presents, 2);
    expect(data.lates, 1);
    expect(data.absences, 1);
    expect(data.collected, 8500);
    expect(data.overdue, 8500);
    expect(data.expenses, 500);
    expect(data.profit, 8000);
    expect(data.students.first.name, 'Ana López');
    expect(data.students.first.presents, 1);
    expect(data.students.first.absences, 1);
    expect(data.students.first.paymentStatus, PaymentStatus.paid);
    expect(data.students.last.name, 'Luis Pérez');
    expect(data.students.last.lates, 1);
    expect(data.students.last.paymentStatus, PaymentStatus.overdue);
  });

  test('el reporte financiero agrupa ingresos y lista adeudos del periodo', () {
    final window = FinanceWindow.month(2026, 10);
    final catalog = FinanceCatalog(
      courses: [course],
      students: [student('a', 'Ana', 'López'), student('b', 'Luis', 'Pérez')],
      payments: const [
        Payment(
          id: 'p1',
          studentId: 'a',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-10-15',
          periodMonth: 10,
          periodYear: 2026,
          status: PaymentStatus.paid,
          paidAmount: 8500,
        ),
        Payment(
          id: 'p2',
          studentId: 'b',
          courseId: 'c1',
          amount: 4000,
          dueDate: '2026-10-15',
          periodMonth: 10,
          periodYear: 2026,
          status: PaymentStatus.pending,
        ),
      ],
      entries: [
        FeeEntry(
          payment: const Payment(
            id: 'p1',
            studentId: 'a',
            courseId: 'c1',
            amount: 8500,
            dueDate: '2026-10-15',
            periodMonth: 10,
            periodYear: 2026,
            status: PaymentStatus.paid,
            paidAmount: 8500,
          ),
          student: student('a', 'Ana', 'López'),
          course: course,
        ),
        FeeEntry(
          payment: const Payment(
            id: 'p2',
            studentId: 'b',
            courseId: 'c1',
            amount: 4000,
            dueDate: '2026-10-15',
            periodMonth: 10,
            periodYear: 2026,
            status: PaymentStatus.pending,
          ),
          student: student('b', 'Luis', 'Pérez'),
          course: course,
        ),
      ],
    );

    final data = buildFinanceReport(
      catalog: catalog,
      window: window,
      expenses: const [
        Expense(
          id: 'e1',
          teacherId: 't1',
          description: 'Renta',
          amount: 1500,
          date: '2026-10-02',
          category: 'Renta',
        ),
      ],
      fallbackCourse: 'Curso',
      fallbackStudent: 'Alumno',
    );

    expect(data.totals.collected, 8500);
    expect(data.totals.toCollect, 4000);
    expect(data.expenses, 1500);
    expect(data.profit, 7000);
    expect(data.byCourse.single.courseName, 'Robótica');
    expect(data.byCourse.single.collected, 8500);
    expect(data.unpaid.single.studentName, 'Luis Pérez');
    expect(data.unpaid.single.amount, 4000);
  });

  test('el nombre del archivo no lleva espacios ni acentos', () {
    expect(
      reportFilename('Robótica Educativa', FinanceWindow.month(2026, 10)),
      'reporte-robotica-educativa-2026-10.pdf',
    );
  });

  test('includesDate respeta mes y rango', () {
    expect(FinanceWindow.month(2026, 10).includesDate('2026-10-06'), isTrue);
    expect(FinanceWindow.month(2026, 10).includesDate('2026-09-30'), isFalse);
    expect(
      FinanceWindow.range(DateTime(2026, 10, 1), DateTime(2026, 10, 15)).includesDate('2026-10-15'),
      isTrue,
    );
    expect(
      FinanceWindow.range(DateTime(2026, 10, 1), DateTime(2026, 10, 15)).includesDate('2026-10-16'),
      isFalse,
    );
  });
}
