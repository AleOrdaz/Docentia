import 'package:flutter_test/flutter_test.dart';
import 'package:docentia/features/courses/models/course_model.dart';
import 'package:docentia/features/students/models/student_model.dart';
import 'package:docentia/features/attendance/models/attendance_model.dart';
import 'package:docentia/features/payments/models/payment_model.dart';
import 'package:docentia/features/finance/models/expense_model.dart';
import 'package:docentia/features/auth/models/teacher_model.dart';

void main() {
  group('Course Model Tests', () {
    test('Course serialization and deserialization should match values', () {
      final course = Course(
        id: 'course-test',
        teacherId: 'teacher-1',
        name: 'Inglés Avanzado B2',
        schedule: 'Lun & Mié 17:00 - 18:30',
        classDays: const [1, 3],
        startTime: '17:00',
        endTime: '18:30',
        duration: '32 sesiones',
        currentSession: 14,
        totalSessions: 32,
        cost: 45000,
        capacity: 30,
        paymentSchedule: PaymentSchedule.firstHalf,
        active: true,
        createdAt: DateTime(2026, 9, 29),
      );

      final map = course.toMap();
      expect(map['name'], 'Inglés Avanzado B2');
      expect(map['cost'], 45000.0);
      expect(map['paymentSchedule'], 'firstHalf');
      expect(map['iconKey'], 'robotics');

      final fromMap = Course.fromMap(map);
      expect(fromMap.id, 'course-test');
      expect(fromMap.iconKey, 'robotics');
      expect(fromMap.paymentSchedule, PaymentSchedule.firstHalf);
      expect(fromMap.capacity, 30);

      final fromJson = Course.fromJson(map);
      expect(fromJson.name, 'Inglés Avanzado B2');
    });

    test('nextClassDate uses today if it is a class day, otherwise the next one', () {
      final course = Course(
        id: 'course-test',
        teacherId: 'teacher-1',
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
        active: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final tuesday = DateTime(2026, 10, 27);
      expect(tuesday.weekday, 2);
      expect(course.nextClassDate(tuesday), DateTime(2026, 10, 27));

      final wednesday = DateTime(2026, 10, 28);
      expect(wednesday.weekday, 3);
      expect(course.nextClassDate(wednesday), DateTime(2026, 10, 29));
    });
  });

  group('Student Model Tests', () {
    test('Student fullName and initials are calculated correctly', () {
      final student = Student(
        id: 'student-test',
        courseId: 'course-test',
        name: 'Camila',
        lastName: 'Morales Díaz',
        age: 16,
        tutorRelationship: TutorRelationship.mother,
        tutorName: 'Patricia Díaz',
        tutorPhone: '+54 9 11 4522 8901',
        tutorEmail: 'tutor@ejemplo.com',
        active: true,
        createdAt: DateTime(2026, 9, 29),
      );

      expect(student.fullName, 'Camila Morales Díaz');
      expect(student.initials, 'CM');

      final map = student.toMap();
      final fromMap = Student.fromMap(map);
      expect(fromMap.fullName, 'Camila Morales Díaz');
      expect(fromMap.active, true);
      expect(fromMap.tutorRelationship, TutorRelationship.mother);
      expect(fromMap.emergencyName, '');
      expect(fromMap.emergencyPhone, '');
    });
  });

  group('Attendance Model Tests', () {
    test('Attendance fromMap safely parses dynamic map values', () {
      final Map<String, dynamic> rawMap = {
        'id': 'att-1',
        'studentId': 'st-1',
        'courseId': 'c-1',
        'date': '2026-09-29',
        'status': 'present',
        'note': null,
      };

      final attendance = Attendance.fromMap(rawMap);
      expect(attendance.id, 'att-1');
      expect(attendance.status, AttendanceStatus.present);
      expect(attendance.note, isNull);
    });
  });

  group('Payment Model Tests', () {
    test('Payment fromMap safely parses dynamic map values', () {
      final Map<String, dynamic> rawMap = {
        'id': 'pay-1',
        'studentId': 'st-1',
        'courseId': 'c-1',
        'amount': 45000,
        'dueDate': '2026-09-15',
        'status': 'paid',
        'paidAt': '2026-09-12T00:00:00.000',
      };

      final payment = Payment.fromMap(rawMap);
      expect(payment.id, 'pay-1');
      expect(payment.amount, 45000.0);
      expect(payment.status, PaymentStatus.paid);
      expect(payment.paidAt, isNotNull);
      expect(payment.isProrated, isFalse);
    });
  });

  group('Expense & Teacher Models Tests', () {
    test('Expense and Teacher fromMap parse safely without dynamic type mismatch', () {
      final Map<String, dynamic> expenseMap = {
        'id': 'exp-1',
        'teacherId': 't-1',
        'description': 'Libros',
        'amount': 32000,
        'date': '2026-09-03',
        'category': 'Materiales',
      };

      final expense = Expense.fromMap(expenseMap);
      expect(expense.id, 'exp-1');
      expect(expense.amount, 32000.0);

      final Map<String, dynamic> teacherMap = {
        'id': 't-1',
        'name': 'Prof. Martín',
        'email': 'martin@docentia.edu',
        'photoUrl': 'https://example.com/photo.jpg',
        'provider': 'google',
        'bio': null,
        'phone': null,
        'createdAt': '2026-01-15T00:00:00.000',
      };

      final teacher = Teacher.fromMap(teacherMap);
      expect(teacher.name, 'Prof. Martín');
      expect(teacher.bio, isNull);
    });
  });
}
