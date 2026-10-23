import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/complete_profile_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/courses/screens/home_screen.dart';
import '../../features/courses/screens/courses_list_screen.dart';
import '../../features/attendance/screens/calendar_screen.dart';
import '../../features/attendance/screens/course_detail_screen.dart';
import '../../features/attendance/screens/attendance_history_screen.dart';
import '../../features/attendance/screens/take_attendance_screen.dart';
import '../../features/students/screens/student_detail_screen.dart';
import '../../features/profile/screens/teacher_profile_screen.dart';
import '../../features/finance/screens/finance_expenses_screen.dart';
import '../../features/finance/screens/finance_reminders_screen.dart';
import '../../features/finance/screens/finance_reports_screen.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/finance/screens/payment_detail_screen.dart';
import '../../features/finance/screens/payment_list_screen.dart';
import '../../features/design/screens/style_guide_screen.dart';
import '../widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen(
    authProvider.select(
      (s) => (s.isAuthenticated, s.needsProfileSetup, s.isLoading),
    ),
    (_, __) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isLoggingIn = loc == '/login';
      final isCompletingProfile = loc == '/complete-profile';

      if (!auth.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }
      if (auth.isLoading) return null;
      if (auth.needsProfileSetup) {
        return isCompletingProfile ? null : '/complete-profile';
      }
      if (isLoggingIn || isCompletingProfile) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SlidingNavigationContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) => const CoursesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/finance',
                builder: (context, state) => const FinanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const TeacherProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/course-detail/:courseId',
        builder: (context, state) {
          final courseId = (state.pathParameters['courseId'] as String?) ?? 'course-1';
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/course-detail/:courseId/attendance',
        builder: (context, state) {
          final courseId = (state.pathParameters['courseId'] as String?) ?? '';
          return TakeAttendanceScreen(courseId: courseId);
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
        path: '/finance/payments',
        builder: (context, state) => const PaymentListScreen(),
      ),
      GoRoute(
        path: '/finance/payment/:paymentId',
        builder: (context, state) {
          final paymentId = state.pathParameters['paymentId'] ?? '';
          return PaymentDetailScreen(paymentId: paymentId);
        },
      ),
      GoRoute(
        path: '/finance/reports',
        builder: (context, state) => const FinanceReportsScreen(),
      ),
      GoRoute(
        path: '/finance/reminders',
        builder: (context, state) => const FinanceRemindersScreen(),
      ),
      GoRoute(
        path: '/finance/expenses',
        builder: (context, state) => const FinanceExpensesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const TeacherProfileScreen(),
      ),
      GoRoute(
        path: '/estilos',
        builder: (context, state) => const StyleGuideScreen(),
      ),
    ],
  );
});
