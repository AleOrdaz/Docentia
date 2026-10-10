import '../../../core/services/storage_service.dart';
import '../models/course_model.dart';

abstract class CoursesRepository {
  Future<List<Course>> getCourses();
  Future<Course?> getCourseById(String id);
  Future<void> saveCourse(Course course);
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);
}

class LocalCoursesRepository implements CoursesRepository {
  List<Course>? _cached;

  @override
  Future<List<Course>> getCourses() async {
    if (_cached != null) return List.unmodifiable(_cached!);
    _cached = await StorageService.getCourses();
    return List.unmodifiable(_cached!);
  }

  @override
  Future<Course?> getCourseById(String id) async {
    final courses = await getCourses();
    try {
      return courses.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCourse(Course course) async {
    final courses = (await getCourses()).toList();
    courses.insert(0, course);
    _cached = courses;
    await StorageService.saveCourses(courses);
  }

  @override
  Future<void> updateCourse(Course course) async {
    final courses = (await getCourses()).toList();
    final index = courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      courses[index] = course;
      _cached = courses;
      await StorageService.saveCourses(courses);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    final courses = (await getCourses()).toList();
    courses.removeWhere((c) => c.id == id);
    _cached = courses;
    await StorageService.saveCourses(courses);
  }
}
