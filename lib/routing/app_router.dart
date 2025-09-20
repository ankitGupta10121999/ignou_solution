import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/login_screen.dart';
import 'package:ignousolutionhub/auth/signup_screen.dart';
import 'package:ignousolutionhub/auth/wrapper.dart';
import 'package:ignousolutionhub/features/admin/all_users_screen.dart';
import 'package:ignousolutionhub/features/user/user_home_screen.dart';

import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

class AppRouter {
  static final router = GoRouter(
    redirect: (context, state) {
      final authService = locator<AuthService>();
      final user = authService.getCurrentUser();

      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Wrapper()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/user_home',
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: '/all_users',
        builder: (context, state) => const AllUsersScreen(),
      ),
    ],
  );
}
