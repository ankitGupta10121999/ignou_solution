
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome User!'),
          ElevatedButton(
            onPressed: () async {
              await authService.signOut();
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
