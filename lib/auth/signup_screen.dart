import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/firestore_service.dart';
import 'package:ignousolutionhub/core/locator.dart';
import 'package:ignousolutionhub/models/user_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = locator<AuthService>();
  final FirestoreService _firestoreService = locator<FirestoreService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userCredential = await _authService
                        .signUpWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                    if (userCredential != null) {
                      final user = UserModel(
                        uid: userCredential.user!.uid,
                        email: userCredential.user!.email!,
                        role: 'user',
                      );
                      await _firestoreService.addUser(user);
                      context.go('/user_home');
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () {
                  context.go('/');
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
