import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/auth/login_screen.dart';
import 'package:ignousolutionhub/auth/signup_screen.dart';
import 'package:ignousolutionhub/constants/appRouter_constants.dart';
import 'package:ignousolutionhub/constants/role_constants.dart';
import 'package:ignousolutionhub/core/locator.dart';
import 'package:ignousolutionhub/features/admin/courses_page.dart';
import 'package:ignousolutionhub/features/admin/subjects_page.dart';
import 'package:ignousolutionhub/features/admin/user_page.dart';
import 'package:ignousolutionhub/features/user/contact_page.dart';
import 'package:ignousolutionhub/features/user/profile_page.dart';
import 'package:ignousolutionhub/features/user/solved_assignments_page.dart';
import 'package:ignousolutionhub/features/user/study_material_page.dart';
import 'package:ignousolutionhub/layout/admin_app_layout.dart';
import 'package:ignousolutionhub/layout/main_app_layout.dart';
import '../core/firestore_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    ) {
  return FadeTransition(opacity: animation, child: child);
}

class AppRouter {
  static final AuthService _authService = locator<AuthService>();

  static final GoRouter router = GoRouter(
    initialLocation: RouterConstant.splash,
    refreshListenable: GoRouterRefreshStream(_authService.authStateChanges),
    routes: [
      /// Splash
      GoRoute(
        path: RouterConstant.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),

      /// Auth routes
      GoRoute(
        path: RouterConstant.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: LoginScreen(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      GoRoute(
        path: RouterConstant.signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: SignupScreen(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        ),
      ),

      /// Student pages
      GoRoute(
        path: RouterConstant.home,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: StudentAppLayout(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: RouterConstant.studyMaterial,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: StudyMaterialPage(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: RouterConstant.solvedAssignments,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: SolvedAssignmentsPage(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: RouterConstant.contact,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: ContactPage(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: RouterConstant.profile,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: ProfilePage(),
          transitionsBuilder: fadeTransition,
          key: state.pageKey,
        ),
      ),

      /// Admin Shell
      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          int index = 0;
          if (location.startsWith(RouterConstant.adminUsers)) index = 0;
          if (location.startsWith(RouterConstant.adminCourses)) index = 1;
          if (location.startsWith(RouterConstant.adminSubjects)) index = 2;
          return AdminAppLayout(index: index, child: child);
        },
        routes: [
          GoRoute(
            path: RouterConstant.adminUsers,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: UsersPage(),
              transitionsBuilder: fadeTransition,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RouterConstant.adminCourses,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: CoursesPage(),
              transitionsBuilder: fadeTransition,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: RouterConstant.adminSubjects,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: SubjectsPage(),
              transitionsBuilder: fadeTransition,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: '${RouterConstant.adminSubjects}/:courseId',
            pageBuilder: (context, state) {
              final courseId = state.pathParameters['courseId'];
              return CustomTransitionPage(
                child: SubjectsPage(courseId: courseId),
                transitionsBuilder: fadeTransition,
                key: state.pageKey,
              );
            },
          ),
        ],
      ),
    ],

    redirect: (context, state) async {
      final currentUser = _authService.getCurrentUser();
      final location = state.matchedLocation;
      final isAuthRoute =
      (location == RouterConstant.login || location == RouterConstant.signup);

      if (currentUser == null && !isAuthRoute) return RouterConstant.login;
      if (currentUser != null && isAuthRoute) {
        final role = await locator<FirestoreService>()
            .getUserRole(currentUser.uid);
        return role == RoleConstants.admin
            ? RouterConstant.adminHome + RouterConstant.allUsers
            : RouterConstant.home;
      }
      if (location == RouterConstant.splash) {
        if (currentUser != null) {
          final role = await locator<FirestoreService>()
              .getUserRole(currentUser.uid);
          return role == RoleConstants.admin
              ? RouterConstant.adminHome + RouterConstant.allUsers
              : RouterConstant.home;
        } else {
          return RouterConstant.login;
        }
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error?.message ?? 'Page not found'}'),
      ),
    ),
  );
}
