
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/models/user_model.dart';

import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

class AdminHomeWeb extends StatelessWidget {
  const AdminHomeWeb({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final authService = locator<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home (Web)'),
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
      body: Row(
        children: [
          if (user.role == 'admin')
            NavigationRail(
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('All Users'),
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (index) {
                if (index == 0) {
                  context.go('/all_users');
                }
              },
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: Text('Welcome Admin!\nRole: ${user.role}'),
            ),
          ),
        ],
      ),
    );
  }
}

