import 'package:flutter/foundation.dart';

import 'user_profile.dart';

@immutable
class AuthState {
  const AuthState({
    this.accessToken,
    this.refreshToken,
    this.isLoading = false,
    this.profile,
  });

  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;

  /// Заполняется после успешного входа (из ответа `login`) или `GET /users/me`.
  final UserProfile? profile;

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
    UserProfile? profile,
    bool clearProfile = false,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
      profile: clearProfile ? null : (profile ?? this.profile),
    );
  }
}
