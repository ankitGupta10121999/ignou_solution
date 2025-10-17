import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/auth/login_screen.dart';
import 'package:ignousolutionhub/auth/signup_screen.dart';
import 'package:ignousolutionhub/constants/role_constants.dart';
import 'package:ignousolutionhub/core/locator.dart';
import 'package:ignousolutionhub/features/user/contact_page.dart';
import 'package:ignousolutionhub/features/user/profile_page.dart';
import 'package:ignousolutionhub/features/user/solved_assignments_page.dart';
import 'package:ignousolutionhub/features/user/study_material_page.dart';
import 'package:ignousolutionhub/layout/admin_app_layout.dart';
import 'package:ignousolutionhub/layout/main_app_layout.dart';

import '../core/firestore_service.dart';

/// Simple splash widget for loading state
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Converts a stream to a [Listenable] for GoRouter refresh
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

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String studyMaterial = '/study_material';
  static const String solvedAssignments = '/solved_assignments';
  static const String contact = '/contact';
  static const String profile = '/profile';
  static const String adminHome = '/admin_home';
  static const String allUsers = '/all_users';
  static final AuthService _authService = locator<AuthService>();

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(_authService.authStateChanges),
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: StudentAppLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: studyMaterial,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: StudyMaterialPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: solvedAssignments,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: SolvedAssignmentsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: contact,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: ContactPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: profile,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: ProfilePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: adminHome,
        pageBuilder: (context, state) {
          final authService = locator<AuthService>();
          final currentUser = authService.getCurrentUser();
          return CustomTransitionPage(
            child: currentUser != null
                ? AdminAppLayout()
                : const Scaffold(
                    body: Center(child: Text('User data missing')),
                  ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
      GoRoute(
        path: allUsers,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: StudentAppLayout(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ],
    redirect: (context, state) {
      final authService = locator<AuthService>();
      final currentUser = authService.getCurrentUser();
      final location = state.matchedLocation;

      final isAuthRoute = (location == login || location == signup);
      // Not logged in → go to login
      if (currentUser == null && !isAuthRoute) {
        return login;
      }

      // Logged in and on auth route → send to home/admin
      if (currentUser != null && isAuthRoute) {
        final firestore = locator<FirestoreService>();
        return firestore.getUserRole(currentUser.uid).then((role) {
          final target = role == RoleConstants.admin ? adminHome : home;
          return target;
        });
      }

      // On splash → check login state
      if (location == splash) {
        if (currentUser != null) {
          final firestore = locator<FirestoreService>();
          firestore.getUserRole(currentUser.uid).then((role) {
            final target = role != RoleConstants.admin ? home : adminHome;
            return target;
          });
        } else {
          return login;
        }
      }
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error?.message ?? 'Page not found'}'),
      ),
    ),
  );
}
