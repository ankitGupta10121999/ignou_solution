import 'package:flutter/material.dart';
import 'package:ignousolutionhub/auth_template/auth_form.dart';
import 'package:ignousolutionhub/auth_template/responsive/signup_mobile.dart';
import 'package:ignousolutionhub/auth_template/responsive/signup_tablet.dart';
import 'package:ignousolutionhub/auth_template/responsive/signup_web.dart';
import 'package:ignousolutionhub/responsive/responsive_layout.dart';

import '../auth/auth_service.dart';
import '../core/locator.dart';

class SignupScreenTemplate extends StatefulWidget {
  const SignupScreenTemplate({super.key});

  @override
  State<SignupScreenTemplate> createState() => _SignupScreenTemplateState();
}

class _SignupScreenTemplateState extends State<SignupScreenTemplate> {
  final AuthService _authService = locator<AuthService>();

  void _submitAuthForm(String email, String password, bool isLogin) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: SignupMobile(submitAuthForm: _submitAuthForm),
        tablet: SignupTablet(submitAuthForm: _submitAuthForm),
        web: SignupWeb(submitAuthForm: _submitAuthForm),
      ),
    );
  }
}
