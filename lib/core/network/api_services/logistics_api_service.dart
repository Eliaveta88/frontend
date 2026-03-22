import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../api_config.dart';
import '../../../features/logistics/data/logistics_models.dart';

class LogisticsApiService {
  LogisticsApiService(this._dio);

  final Dio _dio;

  Future<RouteListPage> listRoutes({int skip = 0, int limit = 100}) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.logisticsRoutes(skip: skip, limit: limit));
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ логистики');
    }
    return RouteListPage.fromJson(data);
  }
}

final logisticsApiServiceProvider = Provider<LogisticsApiService>((ref) {
  return LogisticsApiService(ref.watch(rawDioProvider));
});
