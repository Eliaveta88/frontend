import 'package:flutter/foundation.dart';

@immutable
class AuthState {
  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.isLoading = false,
  });

  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
