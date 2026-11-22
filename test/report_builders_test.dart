import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:docentia/features/attendance/models/attendance_model.dart';
import 'package:docentia/features/reports/services/report_excel_service.dart';
import 'package:docentia/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
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
    expect(data.expectedIncome, 17000);
    expect(data.weeklyHours, closeTo(1.5, 0.01));
    expect(data.attendancePercent, closeTo(75, 0.01));
    expect(data.pendingPaymentStudents, 2);
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

  ClassAttendanceSession workedSession(String date, AttendanceStatus status) {
    return session(
      date: date,
      students: [
        StudentAttendanceItem(
          studentId: 'a',
          studentName: 'Ana López',
          status: status,
        ),
      ],
    );
  }

  test('el excel mensual cobra por clase, semana, quincena o mes', () {
    final ana = student('a', 'Ana', 'López');
    final window = FinanceWindow.month(2026, 10);
    final attended = [
      workedSession('2026-10-05', AttendanceStatus.present),
      workedSession('2026-10-08', AttendanceStatus.late),
      workedSession('2026-10-22', AttendanceStatus.absent),
    ];

    final perClass = buildStudentMonthExport(
      course: course.copyWith(
        billingFrequency: BillingFrequency.perClass,
        cost: 150,
        classDays: const [1, 4],
      ),
      students: [ana],
      sessions: attended,
      window: window,
    ).single;
    expect(perClass.attendances, 2);
    expect(perClass.dailyRate, 150);
    expect(perClass.total, 300);
    expect(perClass.hours, 3);

    final weekly = buildStudentMonthExport(
      course: course.copyWith(
        billingFrequency: BillingFrequency.weekly,
        cost: 400,
        classDays: const [1, 4],
      ),
      students: [ana],
      sessions: attended,
      window: window,
    ).single;
    expect(weekly.dailyRate, 200);
    expect(weekly.total, 400);
    expect(weekly.hours, 3);

    final biweekly = buildStudentMonthExport(
      course: course.copyWith(
        billingFrequency: BillingFrequency.biweekly,
        cost: 800,
        classDays: const [1, 4],
      ),
      students: [ana],
      sessions: [
        workedSession('2026-10-05', AttendanceStatus.present),
        workedSession('2026-10-22', AttendanceStatus.present),
      ],
      window: window,
    ).single;
    expect(biweekly.attendances, 2);
    expect(biweekly.dailyRate, 200);
    expect(biweekly.total, 1600);

    final monthly = buildStudentMonthExport(
      course: course.copyWith(cost: 8000),
      students: [ana],
      sessions: [workedSession('2026-10-05', AttendanceStatus.present)],
      window: window,
    ).single;
    expect(monthly.attendances, 1);
    expect(monthly.dailyRate, 2000);
    expect(monthly.total, 8000);
    expect(monthly.hours, 1.5);
  });

  test('el excel del mes se puede abrir y trae las métricas del alumno', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    final bytes = ReportExcelService().buildStudentMonthWorkbook(
      courseName: 'Robótica',
      periodLabel: 'octubre 2026',
      billingFrequency: BillingFrequency.perClass,
      rows: const [
        StudentMonthExportRow(
          name: 'Ana López',
          attendances: 2,
          dailyRate: 150,
          total: 300,
          hours: 3,
        ),
      ],
      l10n: l10n,
    );

    expect(bytes.sublist(0, 2), [0x50, 0x4B]);
    final archive = ZipDecoder().decodeBytes(bytes);
    final sheet = archive.findFile('xl/worksheets/sheet1.xml');
    final xml = utf8.decode(sheet!.content as List<int>);
    expect(xml, contains('Ana López'));
    expect(xml, contains('Asistencias del mes'));
    expect(xml, contains('>2</v>'));
    expect(xml, contains('>300.0</v>'));
    expect(xml, contains('>3.0</v>'));
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

  test('sugiere baja con dos cuotas vencidas o atraso de 60 días', () {
    final ana = student('a', 'Ana', 'López');
    final luis = student('b', 'Luis', 'Pérez');
    final now = DateTime(2026, 11, 2);
    final names = studentsSuggestedForDeactivation(
      students: [ana, luis],
      now: now,
      payments: const [
        Payment(
          id: 'p1',
          studentId: 'a',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-08-15',
          periodMonth: 8,
          periodYear: 2026,
          status: PaymentStatus.overdue,
        ),
        Payment(
          id: 'p2',
          studentId: 'b',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-09-15',
          periodMonth: 9,
          periodYear: 2026,
          status: PaymentStatus.overdue,
        ),
        Payment(
          id: 'p3',
          studentId: 'b',
          courseId: 'c1',
          amount: 8500,
          dueDate: '2026-10-15',
          periodMonth: 10,
          periodYear: 2026,
          status: PaymentStatus.overdue,
        ),
      ],
    );

    expect(names, ['Ana López', 'Luis Pérez']);
    expect(courseWeeklyHours(course), closeTo(1.5, 0.01));
  });
}
