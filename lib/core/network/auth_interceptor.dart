import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';

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
          final response = await Dio().fetch(err.requestOptions);
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

    try {
      final response = await Dio().post(
        '${_ref.read(authProvider).accessToken != null ? '' : 'http://localhost:8000/api'}/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final data = response.data as Map<String, dynamic>;
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
