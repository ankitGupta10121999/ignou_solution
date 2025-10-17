import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ignousolutionhub/auth/auth_service.dart';
import 'package:ignousolutionhub/core/locator.dart';

// 1. Define the state
class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});

  LoginState copyWith({bool? isLoading, String? error}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. Create the StateNotifier
class LoginController extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginController(this._authService) : super(LoginState());

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      state = state.copyWith(isLoading: false);
      return userCredential != null;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }
}

// 3. Create the StateNotifierProvider
final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
      final authService = locator<AuthService>();
      return LoginController(authService);
    });
