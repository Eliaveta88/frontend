import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_interceptor.dart';

/// Resolves Traefik (or reverse proxy) origin without a trailing `/`.
///
/// - If `API_BASE_URL` is set via `--dart-define`, it wins.
/// - On Flutter Web, if unset, uses [Uri.base.origin] (same host as the app —
///   useful when the SPA is served behind the same Traefik as APIs).
/// - Otherwise defaults to `http://localhost` (mobile/desktop dev against Docker).
String resolveApiBaseUrl() {
  const fromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  final trimmed = fromEnv.trim();
  if (trimmed.isNotEmpty) {
    return trimmed.replaceAll(RegExp(r'/$'), '');
  }
  if (kIsWeb) {
    return Uri.base.origin;
  }
  return 'http://localhost';
}

/// Базовый URL Traefik без завершающего `/`.
///
/// Запуск: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost`
final apiBaseUrlProvider = Provider<String>((ref) {
  return resolveApiBaseUrl();
});

/// Клиент без Bearer — логин, refresh.
final rawDioProvider = Provider<Dio>((ref) {
  final base = ref.watch(apiBaseUrlProvider);
  return Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
});

/// Клиент с [AuthInterceptor] — защищённые маршруты identity и при необходимости других сервисов.
final dioProvider = Provider<Dio>((ref) {
  final base = ref.watch(apiBaseUrlProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref));
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }
  return dio;
});

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
