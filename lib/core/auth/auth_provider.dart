import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_services/identity_api_service.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final identity = _ref.read(identityApiServiceProvider);
      final data = await identity.login(username: username, password: password);
      final access = data['access_token'] as String?;
      final refresh = data['refresh_token'] as String?;
      if (access == null || refresh == null) {
        throw Exception('Нет токенов в ответе');
      }
      state = AuthState(
        accessToken: access,
        refreshToken: refresh,
      );
    } on DioException catch (e) {
      state = const AuthState();
      final msg = e.response?.data;
      if (msg is Map && msg['detail'] != null) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: msg['detail'].toString(),
        );
      }
      rethrow;
    } catch (_) {
      state = const AuthState();
      rethrow;
    }
  }

  /// Регистрация нового пользователя (POST `/identity/.../users`). Не выполняет вход.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final identity = _ref.read(identityApiServiceProvider);
      await identity.register(username: username, email: email, password: password);
    } on DioException catch (e) {
      final msg = e.response?.data;
      if (msg is Map && msg['detail'] != null) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          message: msg['detail'].toString(),
        );
      }
      rethrow;
    } catch (_) {
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    final token = state.accessToken;
    if (token != null) {
      try {
        final identity = _ref.read(identityApiServiceProvider);
        await identity.logout();
      } catch (_) {
        // сеть / 401 — всё равно чистим локально
      }
    }
    state = const AuthState();
  }

  void setTokens({required String access, required String refresh}) {
    state = AuthState(accessToken: access, refreshToken: refresh);
  }

  void clearTokens() {
    state = const AuthState();
  }
}
