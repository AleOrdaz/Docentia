import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../repositories/courses_repository.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return LocalCoursesRepository();
});

class CoursesNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final CoursesRepository _repository;

  CoursesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      final courses = await _repository.getCourses();
      state = AsyncValue.data(courses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Course> addCourse({
    required String name,
    required List<int> classDays,
    required String startTime,
    required String endTime,
    required int totalSessions,
    required double cost,
    required int capacity,
    required PaymentSchedule paymentSchedule,
    String iconKey = 'robotics',
  }) async {
    final tempCourse = Course(
      id: 'course-${DateTime.now().millisecondsSinceEpoch}',
      teacherId: 'teacher-1',
      name: name,
      schedule: '',
      classDays: classDays,
      startTime: startTime,
      endTime: endTime,
      duration: '$totalSessions sesiones',
      currentSession: 1,
      totalSessions: totalSessions,
      cost: cost,
      capacity: capacity,
      paymentSchedule: paymentSchedule,
      iconKey: iconKey,
      active: true,
      createdAt: DateTime.now(),
    );

    final newCourse = tempCourse.copyWith(
      schedule: tempCourse.formattedSchedule,
    );

    await _repository.saveCourse(newCourse);
    final updated = await _repository.getCourses();
    state = AsyncValue.data(updated);
    return newCourse;
  }

  Future<void> updateCourse(Course updatedCourse) async {
    final courseToSave = updatedCourse.copyWith(
      schedule: updatedCourse.formattedSchedule,
    );
    await _repository.updateCourse(courseToSave);
    final updated = await _repository.getCourses();
    state = AsyncValue.data(updated);
  }
}

final coursesProvider =
StateNotifierProvider<CoursesNotifier, AsyncValue<List<Course>>>((ref) {
  final repo = ref.watch(coursesRepositoryProvider);
  return CoursesNotifier(repo);
});

final selectedCourseIdProvider = StateProvider<String?>((ref) => null);

final selectedCourseProvider = Provider<Course?>((ref) {
  final coursesAsync = ref.watch(coursesProvider);
  final selectedId = ref.watch(selectedCourseIdProvider);

  return coursesAsync.when(
    data: (courses) {
      if (courses.isEmpty) return null;
      if (selectedId != null) {
        try {
          return courses.firstWhere((c) => c.id == selectedId);
        } catch (_) {}
      }
      return courses.first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
