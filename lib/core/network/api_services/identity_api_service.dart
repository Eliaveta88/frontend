import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../api_config.dart';

/// Identity microservice API (Traefik path prefix `/identity`).
///
/// Use [raw] client for login, register, refresh (no Bearer).
/// Use [authenticated] for `/users/me`, logout (Bearer from [AuthInterceptor]).
class IdentityApiService {
  IdentityApiService({
    required Dio raw,
    required Dio authenticated,
  })  : _raw = raw,
        _authenticated = authenticated;

  final Dio _raw;
  final Dio _authenticated;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _raw.post<Map<String, dynamic>>(
      ApiPaths.identityLogin,
      data: {
        'username': username,
        'password': password,
      },
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Пустой ответ сервера');
    }
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _raw.post<Map<String, dynamic>>(
      ApiPaths.identityRegisterUsers,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Пустой ответ при регистрации');
    }
    return data;
  }

  Future<void> logout() async {
    await _authenticated.post<Map<String, dynamic>>(ApiPaths.identityLogout);
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _authenticated.get<Map<String, dynamic>>(ApiPaths.identityMe);
    final data = response.data;
    if (data == null) {
      throw Exception('Пустой ответ профиля');
    }
    return data;
  }

  /// Список пользователей (для экрана администрирования).
  Future<Map<String, dynamic>> listUsers({int skip = 0, int limit = 100}) async {
    final response = await _raw.get<Map<String, dynamic>>(ApiPaths.identityUsersList(skip: skip, limit: limit));
    final data = response.data;
    if (data == null) {
      throw Exception('Пустой ответ списка пользователей');
    }
    return data;
  }
}

final identityApiServiceProvider = Provider<IdentityApiService>((ref) {
  return IdentityApiService(
    raw: ref.watch(rawDioProvider),
    authenticated: ref.watch(dioProvider),
  );
});
