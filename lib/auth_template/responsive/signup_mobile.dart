
import 'package:flutter/material.dart';
import 'package:ignousolutionhub/auth_template/auth_form.dart';

class SignupMobile extends StatelessWidget {
  const SignupMobile({super.key, required this.submitAuthForm});

  final void Function(
    String email,
    String password,
    bool isLogin,
  ) submitAuthForm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                AuthForm(
                  isLogin: false,
                  onSubmit: submitAuthForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
