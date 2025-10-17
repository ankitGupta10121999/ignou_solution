import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:ignousolutionhub/auth/login_controller.dart';
import 'package:ignousolutionhub/routing/app_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Call the signIn method on our controller
      await ref
          .read(loginControllerProvider.notifier)
          .signIn(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors and show a SnackBar
    ref.listen<LoginState>(loginControllerProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Watch the provider for state changes
    final loginState = ref.watch(loginControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F9F9), Color(0xFFE8F5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoginCard(loginState.isLoading),
                SizedBox(height: 40.h),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(bool isLoading) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'IGNOUE SOLUTION HUB',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002147),
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 24.h),
                _buildEmailField(),
                SizedBox(height: 16.h),
                _buildPasswordField(),
                SizedBox(height: 8.h),
                _buildForgotPasswordLink(),
                SizedBox(height: 24.h),
                _buildLoginButton(isLoading),
                SizedBox(height: 16.h),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      onEditingComplete: () => FocusScope.of(context).nextFocus(),
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      onEditingComplete: _login,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Forgot password functionality coming soon!'),
            ),
          );
        },
        child: const Text(
          'Forgot password?',
          style: TextStyle(color: Color(0xFF28A745)),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002147),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Login',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return TextButton(
      onPressed: () {
        // Use go_router for navigation
        context.go(AppRouter.signup);
      },
      child: const Text.rich(
        TextSpan(
          text: 'Don\'t have an account? ',
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Color(0xFF28A745),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Handwritten Assignments | Free Delivery | Study Material',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color(0xFF002147),
        fontFamily: 'Roboto',
      ),
    );
  }
}