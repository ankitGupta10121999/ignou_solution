import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/firestore_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();
    final firestoreService = locator<FirestoreService>();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/login'); // clears all previous routes
            });
            return const SizedBox(); // empty placeholder
          } else {
            return FutureBuilder(
              future: firestoreService.getUser(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final userModel = snapshot.data!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (userModel.role == 'admin') {
                        context.go('/all_users');
                      } else {
                        context.go('/user_home');
                      }
                    });
                    return const SizedBox();
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/login');
                    });
                    return const SizedBox();
                  }
                } else {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
