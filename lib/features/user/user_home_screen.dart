
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome User!'),
      ),
    );
  }
}
