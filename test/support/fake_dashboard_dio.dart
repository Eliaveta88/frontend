import 'package:dio/dio.dart';

/// [Dio] без сети: отвечает на запросы дашборда фиксированным JSON.
Dio createFakeDashboardDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost',
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final uri = options.uri;
        final path = uri.path;
        final q = uri.queryParameters;

        if (path.contains('/catalog/api/v1/catalog/products')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: <String, dynamic>{
                'total': 42,
                'items': <dynamic>[],
                'skip': 0,
                'limit': 1,
              },
            ),
          );
        }

        if (path.contains('/orders/api/v1/orders')) {
          if (q['limit'] == '8') {
            return handler.resolve(
              Response(
                requestOptions: options,
                data: <String, dynamic>{
                  'items': <dynamic>[],
                  'total': 0,
                  'skip': 0,
                  'limit': 8,
                },
              ),
            );
          }
          if (q.containsKey('created_from')) {
            return handler.resolve(
              Response(
                requestOptions: options,
                data: <String, dynamic>{
                  'total': 7,
                  'items': <dynamic>[],
                  'skip': 0,
                  'limit': 1,
                },
              ),
            );
          }
          return handler.resolve(
            Response(
              requestOptions: options,
              data: <String, dynamic>{
                'total': 99,
                'items': <dynamic>[],
                'skip': 0,
                'limit': 1,
              },
            ),
          );
        }

        if (path.contains('/revenue')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: <String, dynamic>{
                'client_id': 1,
                'total_amount': 1500.0,
                'currency': 'RUB',
              },
            ),
          );
        }

        if (path.contains('/logistics/api/v1/logistics')) {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: <String, dynamic>{
                'total': 2,
                'items': <dynamic>[],
                'skip': 0,
                'limit': 1,
              },
            ),
          );
        }

        if (path.contains('/finance/api/v1/finance/transactions') && options.method == 'GET') {
          return handler.resolve(
            Response(
              requestOptions: options,
              data: <String, dynamic>{
                'items': <dynamic>[],
                'total': 0,
                'skip': 0,
                'limit': 8,
              },
            ),
          );
        }

        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Unhandled fake request: ${options.uri}',
            type: DioExceptionType.unknown,
          ),
        );
      },
    ),
  );

  return dio;
}
