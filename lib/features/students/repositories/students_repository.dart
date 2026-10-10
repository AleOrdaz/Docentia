import '../../../core/services/storage_service.dart';
import '../models/student_model.dart';

abstract class StudentsRepository {
  Future<List<Student>> getAllStudents();
  Future<List<Student>> getStudentsByCourse(String courseId);
  Future<Student?> getStudentById(String id);
  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deactivateStudent(String id);
}

class LocalStudentsRepository implements StudentsRepository {
  List<Student>? _cached;

  Future<List<Student>> _all() async {
    if (_cached != null) return _cached!;
    _cached = await StorageService.getStudents();
    return _cached!;
  }

  @override
  Future<List<Student>> getAllStudents() async {
    final list = await _all();
    return list.where((s) => s.active).toList();
  }

  @override
  Future<List<Student>> getStudentsByCourse(String courseId) async {
    final list = await _all();
    return list.where((s) => s.courseId == courseId && s.active).toList();
  }

  @override
  Future<Student?> getStudentById(String id) async {
    final list = await _all();
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addStudent(Student student) async {
    final list = (await _all()).toList();
    list.add(student);
    _cached = list;
    await StorageService.saveStudents(list);
  }

  @override
  Future<void> updateStudent(Student student) async {
    final list = (await _all()).toList();
    final index = list.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      list[index] = student;
      _cached = list;
      await StorageService.saveStudents(list);
    }
  }

  @override
  Future<void> deactivateStudent(String id) async {
    final list = (await _all()).toList();
    final index = list.indexWhere((s) => s.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(active: false);
      _cached = list;
      await StorageService.saveStudents(list);
    }
  }
}
