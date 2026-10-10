import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/courses/screens/home_screen.dart';
import '../../features/courses/screens/courses_list_screen.dart';
import '../../features/attendance/screens/calendar_screen.dart';
import '../../features/attendance/screens/course_detail_screen.dart';
import '../../features/attendance/screens/attendance_history_screen.dart';
import '../../features/students/screens/student_detail_screen.dart';
import '../../features/profile/screens/teacher_profile_screen.dart';
import '../../features/finance/screens/finance_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Notifica al router solo cuando cambia la sesión (no isLoading, error, etc.)
  final refresh = ValueNotifier<bool>(ref.read(authProvider).isAuthenticated);

  ref.listen<bool>(
    authProvider.select((s) => s.isAuthenticated),
        (_, next) => refresh.value = next,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authProvider).isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !isLoggingIn) return '/login';
      if (loggedIn && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (context, state) => const CoursesListScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/course-detail/:courseId',
        builder: (context, state) {
          final courseId = (state.pathParameters['courseId'] as String?) ?? 'course-1';
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/course-detail/:courseId/history',
        builder: (context, state) {
          final courseId = (state.pathParameters['courseId'] as String?) ?? 'course-1';
          return AttendanceHistoryScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/student-detail/:studentId',
        builder: (context, state) {
          final studentId = (state.pathParameters['studentId'] as String?) ?? '';
          return StudentDetailScreen(studentId: studentId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const TeacherProfileScreen(),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => const FinanceScreen(),
      ),
    ],
  );
});
