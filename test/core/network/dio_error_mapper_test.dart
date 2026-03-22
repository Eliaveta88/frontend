import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/core/network/dio_error_mapper.dart';

void main() {
  group('dioErrorMessage', () {
    test('connectionError includes message', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
        message: 'refused',
      );
      expect(dioErrorMessage(e), contains('refused'));
      expect(dioErrorMessage(e), contains('Нет соединения'));
    });

    test('badResponse uses detail from JSON body', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 422,
          data: {'detail': 'Validation failed'},
        ),
      );
      expect(dioErrorMessage(e), 'Validation failed');
    });

    test('badResponse without detail shows status', () {
      final e = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 500,
          data: 'plain',
        ),
      );
      expect(dioErrorMessage(e), contains('500'));
    });

    test('timeout types return timeout text', () {
      for (final t in [DioExceptionType.connectionTimeout, DioExceptionType.sendTimeout, DioExceptionType.receiveTimeout]) {
        final e = DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: t,
        );
        expect(dioErrorMessage(e), contains('Таймаут'));
      }
    });

    test('non-Dio falls back to toString', () {
      expect(dioErrorMessage(Exception('x')), contains('Exception'));
    });
  });
}
