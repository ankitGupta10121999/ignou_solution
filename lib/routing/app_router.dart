
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/login_screen.dart';
import 'package:ignousolutionhub/auth/signup_screen.dart';
import 'package:ignousolutionhub/auth/wrapper.dart';
import 'package:ignousolutionhub/features/admin/admin_home_screen.dart';
import 'package:ignousolutionhub/features/admin/all_users_screen.dart';
import 'package:ignousolutionhub/features/user/contact_page.dart';
import 'package:ignousolutionhub/features/user/home_page.dart';
import 'package:ignousolutionhub/features/user/profile_page.dart';
import 'package:ignousolutionhub/features/user/solved_assignments_page.dart';
import 'package:ignousolutionhub/features/user/study_material_page.dart';
import 'package:ignousolutionhub/layout/main_app_layout.dart';
import 'package:ignousolutionhub/models/user_model.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Wrapper(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const StudentAppLayout(),
      ),
      GoRoute(
        path: '/study_material',
        builder: (context, state) => const StudyMaterialPage(),
      ),
      GoRoute(
        path: '/solved_assignments',
        builder: (context, state) => const SolvedAssignmentsPage(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/admin_home',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return AdminHomeScreen(user: user);
        },
      ),
      GoRoute(
        path: '/all_users',
        builder: (context, state) => const AllUsersScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
