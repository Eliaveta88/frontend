import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: call identity service POST /auth/login
      await Future.delayed(const Duration(seconds: 1));
      state = AuthState(
        accessToken: 'mock_access',
        refreshToken: 'mock_refresh',
      );
    } catch (e) {
      state = const AuthState();
      rethrow;
    }
  }

  Future<void> logout() async {
    // TODO: call identity service POST /auth/logout
    state = const AuthState();
  }

  void setTokens({required String access, required String refresh}) {
    state = AuthState(accessToken: access, refreshToken: refresh);
  }

  void clearTokens() {
    state = const AuthState();
  }
}
