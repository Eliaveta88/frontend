import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_services/identity_api_service.dart';
import '../../features/finance/providers/finance_providers.dart';
import 'auth_state.dart';
import 'user_profile.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  static const int _defaultFinanceClientId = 1;

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
      UserProfile? profile;
      final u = data['user'];
      if (u is Map<String, dynamic>) {
        profile = UserProfile.fromJson(u);
      }
      state = AuthState(
        accessToken: access,
        refreshToken: refresh,
        profile: profile,
      );
      if (profile != null) {
        _ref.read(financeClientIdProvider.notifier).state = profile.id;
      }
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
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Обновить профиль с `GET /users/me` (например после refresh токена).
  Future<void> refreshProfile() async {
    final token = state.accessToken;
    if (token == null) return;
    try {
      final identity = _ref.read(identityApiServiceProvider);
      final data = await identity.getCurrentUser();
      final profile = UserProfile.fromJson(data);
      state = state.copyWith(profile: profile);
      _ref.read(financeClientIdProvider.notifier).state = profile.id;
    } catch (_) {
      // игнорируем — профиль останется прежним или пустым
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
    _ref.read(financeClientIdProvider.notifier).state = _defaultFinanceClientId;
  }

  void setTokens({required String access, required String refresh}) {
    state = AuthState(
      accessToken: access,
      refreshToken: refresh,
      profile: state.profile,
    );
  }

  void clearTokens() {
    state = const AuthState();
    _ref.read(financeClientIdProvider.notifier).state = _defaultFinanceClientId;
  }
}
