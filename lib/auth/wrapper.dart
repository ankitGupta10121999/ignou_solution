import 'package:flutter/material.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/auth/login_screen.dart';
import 'package:ignousolutionhub/constants/role_constants.dart';
import 'package:ignousolutionhub/core/firestore_service.dart';
import 'package:ignousolutionhub/core/locator.dart';
import 'package:ignousolutionhub/layout/main_app_layout.dart';

import '../layout/admin_app_layout.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();
    final firestoreService = locator<FirestoreService>();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        } else {
          return FutureBuilder(
            future: firestoreService.getUser(user.uid),
            builder: (context, userModelSnapshot) {
              if (userModelSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (userModelSnapshot.hasError ||
                  userModelSnapshot.data == null) {
                authService.signOut();
                return const LoginScreen();
              }
              final role = userModelSnapshot.data?.role;
              if (role == RoleConstants.student) {
                return const StudentAppLayout();
              } else {
                return const AdminAppLayout();
              }
            },
          );
        }
      },
    );
  }
}
