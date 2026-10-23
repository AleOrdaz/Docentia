import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../courses/models/course_model.dart';
import '../../courses/providers/courses_provider.dart';
import '../../payments/models/payment_model.dart';
import '../../payments/providers/payments_provider.dart';
import '../../students/models/student_model.dart';
import '../../students/providers/students_provider.dart';
import '../logic/finance_fees.dart';

class FeeEntry {
  final Payment payment;
  final Student? student;
  final Course? course;

  const FeeEntry({
    required this.payment,
    required this.student,
    required this.course,
  });

  String get studentName => student?.fullName.trim() ?? '';
  String get courseName => course?.name ?? '';
  String get initials => student?.initials ?? '';
  String get tutorName => student?.tutorName ?? '';
  String get tutorPhone => student?.tutorPhone ?? '';
}

class FinanceCatalog {
  final List<FeeEntry> entries;
  final List<Course> courses;
  final List<Student> students;
  final List<Payment> payments;

  const FinanceCatalog({
    required this.entries,
    required this.courses,
    required this.students,
    required this.payments,
  });
}

final financeWindowProvider = StateProvider<FinanceWindow>((ref) => FinanceWindow.current());

final financeListQueryProvider = StateProvider<FinanceListQuery>((ref) => const FinanceListQuery());

final financeCatalogProvider = Provider<AsyncValue<FinanceCatalog>>((ref) {
  final paymentsAsync = ref.watch(allPaymentsProvider);
  final studentsAsync = ref.watch(allActiveStudentsProvider);
  final coursesAsync = ref.watch(coursesProvider);

  if (paymentsAsync.isLoading || studentsAsync.isLoading || coursesAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (paymentsAsync.hasError) {
    return AsyncValue.error(paymentsAsync.error!, paymentsAsync.stackTrace ?? StackTrace.empty);
  }
  if (coursesAsync.hasError) {
    return AsyncValue.error(coursesAsync.error!, coursesAsync.stackTrace ?? StackTrace.empty);
  }

  final payments = paymentsAsync.value ?? const <Payment>[];
  final students = studentsAsync.value ?? const <Student>[];
  final courses = coursesAsync.value ?? const <Course>[];
  final studentsById = {for (final student in students) student.id: student};
  final coursesById = {for (final course in courses) course.id: course};

  final entries = [
    for (final payment in payments)
      FeeEntry(
        payment: payment,
        student: studentsById[payment.studentId],
        course: coursesById[payment.courseId],
      ),
  ]..sort((a, b) => a.payment.dueDate.compareTo(b.payment.dueDate));

  return AsyncValue.data(FinanceCatalog(
    entries: entries,
    courses: courses,
    students: students,
    payments: payments,
  ));
});

void reloadFinance(WidgetRef ref) {
  ref.invalidate(allPaymentsProvider);
  ref.invalidate(coursesProvider);
  ref.invalidate(allActiveStudentsProvider);
}
