import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import 'api_client.dart';
import 'api_config.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(authProvider).accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final token = _ref.read(authProvider).accessToken;
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          // rawDio без interceptors — иначе цикл с dioProvider
          final retryDio = _ref.read(rawDioProvider);
          final response = await retryDio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }
      _ref.read(authProvider.notifier).clearTokens();
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refresh = _ref.read(authProvider).refreshToken;
    if (refresh == null) return false;

    final raw = _ref.read(rawDioProvider);
    try {
      final response = await raw.post<Map<String, dynamic>>(
        ApiPaths.identityRefresh,
        data: {'refresh_token': refresh},
      );
      final data = response.data;
      if (data == null) return false;
      _ref.read(authProvider.notifier).setTokens(
            access: data['access_token'] as String,
            refresh: data['refresh_token'] as String,
          );
      return true;
    } catch (_) {
      return false;
    }
  }
}
