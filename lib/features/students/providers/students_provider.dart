import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_model.dart';
import '../repositories/students_repository.dart';

final _studentsRepositoryInstance = LocalStudentsRepository();

final studentsRepositoryProvider = Provider<StudentsRepository>((ref) {
  return _studentsRepositoryInstance;
});

/// Proveedor de versión/revisión para sincronizar reactivamente cambios de alumnos en toda la app
final studentsRevisionProvider = StateProvider<int>((ref) => 0);

class StudentsNotifier extends StateNotifier<AsyncValue<List<Student>>> {
  final StudentsRepository _repository;
  final String _courseId;
  final Ref? _ref;

  StudentsNotifier(this._repository, this._courseId, [this._ref])
      : super(const AsyncValue.loading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final students = await _repository.getStudentsByCourse(_courseId);
      state = AsyncValue.data(students);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Student> addStudent({
    required String name,
    required String lastName,
    required int age,
    String? assignedLevel,
    required String tutorName,
    required String tutorPhone,
    required String tutorEmail,
    String? secondaryPhone,
  }) async {
    final student = Student(
      id: 'student-${DateTime.now().millisecondsSinceEpoch}',
      courseId: _courseId,
      name: name,
      lastName: lastName,
      age: age,
      assignedLevel: assignedLevel,
      tutorName: tutorName,
      tutorPhone: tutorPhone,
      tutorEmail: tutorEmail,
      secondaryPhone: secondaryPhone,
      active: true,
      createdAt: DateTime.now(),
    );

    await _repository.addStudent(student);
    final updated = await _repository.getStudentsByCourse(_courseId);
    state = AsyncValue.data(updated);

    // Notificar reactivamente a los contadores globales y de Home
    if (_ref != null) {
      _ref!.read(studentsRevisionProvider.notifier).state++;
      _ref!.invalidate(allActiveStudentsProvider);
    }
    return student;
  }

  Future<void> deactivateStudent(String studentId) async {
    await _repository.deactivateStudent(studentId);
    final updated = await _repository.getStudentsByCourse(_courseId);
    state = AsyncValue.data(updated);

    if (_ref != null) {
      _ref!.read(studentsRevisionProvider.notifier).state++;
      _ref!.invalidate(allActiveStudentsProvider);
    }
  }
}

final studentsForCourseProvider = StateNotifierProvider.family<
    StudentsNotifier, AsyncValue<List<Student>>, String>((ref, courseId) {
  final repo = ref.watch(studentsRepositoryProvider);
  // Escuchar revisiones para recargar cuando cambie cualquier alumno
  ref.watch(studentsRevisionProvider);
  return StudentsNotifier(repo, courseId, ref);
});

final selectedStudentIdProvider = StateProvider<String?>((ref) => null);

final selectedStudentProvider = FutureProvider<Student?>((ref) async {
  final studentId = ref.watch(selectedStudentIdProvider);
  if (studentId == null) return null;
  final repo = ref.watch(studentsRepositoryProvider);
  return repo.getStudentById(studentId);
});

final allActiveStudentsProvider = FutureProvider<List<Student>>((ref) async {
  // Al cambiar la versión de alumnos, se recalculan inmediatamente los totales de alumnos
  ref.watch(studentsRevisionProvider);
  final repo = ref.watch(studentsRepositoryProvider);
  return repo.getAllStudents();
});

