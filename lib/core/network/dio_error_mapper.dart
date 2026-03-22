import 'package:dio/dio.dart';

/// Человекочитаемое описание ошибки сети / HTTP для UI и логов.
String dioErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Сервер не отвечает вовремя. Проверьте подключение к сети и повторите попытку.';
      case DioExceptionType.connectionError:
        return 'Нет соединения с сервером${error.message != null ? ': ${error.message}' : ''}. Проверьте сеть.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final data = error.response?.data;
        if (data is Map && data['detail'] != null) {
          return data['detail'].toString();
        }
        return 'Ошибка сервера${code != null ? ' ($code)' : ''}';
      case DioExceptionType.cancel:
        return 'Запрос отменён';
      case DioExceptionType.badCertificate:
        return 'Ошибка TLS-сертификата';
      case DioExceptionType.unknown:
        return error.message ?? 'Неизвестная ошибка сети';
    }
  }
  return error.toString();
}
