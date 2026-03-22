import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../api_config.dart';
import '../../../features/logistics/data/logistics_models.dart';

class LogisticsApiService {
  LogisticsApiService(this._dio);

  final Dio _dio;

  Future<RouteListPage> listRoutes({
    int skip = 0,
    int limit = 100,
    String? status,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      ApiPaths.logisticsRoutes(skip: skip, limit: limit, status: status),
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ логистики');
    }
    return RouteListPage.fromJson(data);
  }

  /// Создать маршрут с точками доставки.
  Future<RouteRow> createRoute({
    required int vehicleId,
    required int driverId,
    required String driverName,
    required DateTime startTime,
    required List<({int clientId, String address})> points,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiPaths.logisticsRoutesCreate,
      data: {
        'vehicle_id': vehicleId,
        'driver_id': driverId,
        'driver_name': driverName,
        'start_time': startTime.toUtc().toIso8601String(),
        'points': [
          for (final p in points)
            <String, dynamic>{
              'client_id': p.clientId,
              'address': p.address,
            },
        ],
      },
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ при создании маршрута');
    }
    return RouteRow.fromJson(data);
  }
}

final logisticsApiServiceProvider = Provider<LogisticsApiService>((ref) {
  return LogisticsApiService(ref.watch(dioProvider));
});
