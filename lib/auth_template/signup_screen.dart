
import 'package:flutter/material.dart';
import 'package:ignousolutionhub/auth_template/auth_form.dart';
import 'package:ignousolutionhub/auth_template/responsive/signup_mobile.dart';
import 'package:ignousolutionhub/auth_template/responsive/signup_tablet.dart';
import 'package:ignousolutionhub/auth_template/responsive/signup_web.dart';
import 'package:ignousolutionhub/responsive/responsive_layout.dart';

class SignupScreenTemplate extends StatelessWidget {
  const SignupScreenTemplate({super.key});

  void _submitAuthForm(String email, String password, bool isLogin) {
    // Implement your signup logic here
    print('Email: $email');
    print('Password: $password');
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
