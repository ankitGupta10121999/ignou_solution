
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/models/user_model.dart';

import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

class AdminHomeTablet extends StatelessWidget {
  const AdminHomeTablet({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home (Tablet)'),
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
      drawer: user.role == 'admin'
          ? Drawer(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('All Users'),
                    onTap: () {
                      context.go('/all_users');
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Center(
        child: Text('Welcome Admin!\nRole: ${user.role}'),
      ),
    );
  }
}
