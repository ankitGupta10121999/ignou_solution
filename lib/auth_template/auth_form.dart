
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
  });

  final bool isLogin;
  final void Function(
    String email,
    String password,
    bool isLogin,
  ) onSubmit;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;
  var _email = '';
  var _password = '';
  var _obscurePassword = true;
  String? _errorMessage;

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try  {
       widget.onSubmit(
          _email.trim(),
          _password.trim(),
          widget.isLogin,
        );
      } on FirebaseAuthException catch (e){
        setState(() {
          print(_errorMessage);
          print(e.message);
          _errorMessage = e.message;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const ValueKey('email'),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
            onSaved: (value) {
              _email = value!;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              labelText: 'Email address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('password'),
            validator: (value) {
              if (value == null || value.length < 7) {
                return 'Password must be at least 7 characters long.';
              }
              return null;
            },
            onSaved: (value) {
              _password = value!;
            },
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _trySubmit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, 
                  vertical: 8.0
                ),
              ),
              child: Text(widget.isLogin ? 'Login' : 'Signup'),
            ),
        ],
      ),
    );
  }
}
