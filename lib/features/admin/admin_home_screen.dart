
import 'package:flutter/material.dart';
import 'package:ignousolutionhub/features/admin/admin_home_mobile.dart';
import 'package:ignousolutionhub/features/admin/admin_home_tablet.dart';
import 'package:ignousolutionhub/features/admin/admin_home_web.dart';
import 'package:ignousolutionhub/responsive/responsive_layout.dart';

import 'package:ignousolutionhub/models/user_model.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: AdminHomeMobile(user: user),
      tablet: AdminHomeTablet(user: user),
      web: AdminHomeWeb(user: user),
    );
  }
}
