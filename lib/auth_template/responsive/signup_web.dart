
import 'package:flutter/material.dart';
import 'package:ignousolutionhub/auth_template/auth_form.dart';

class SignupWeb extends StatelessWidget {
  const SignupWeb({super.key, required this.submitAuthForm});

  final void Function(
    String email,
    String password,
    bool isLogin,
  ) submitAuthForm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Theme.of(context).primaryColor,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlutterLogo(size: 150),
                  SizedBox(height: 20),
                  Text(
                    'IGNOU Solution Hub',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your one-stop solution for IGNOU assignments.',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: AuthForm(
                    isLogin: false,
                    onSubmit: submitAuthForm,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
