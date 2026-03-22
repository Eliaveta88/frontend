import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../api_config.dart';
import '../../../features/warehouse/data/warehouse_models.dart';

class WarehouseApiService {
  WarehouseApiService(this._dio);

  final Dio _dio;

  Future<StockListPage> listStock({int skip = 0, int limit = 100}) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.warehouseStock(skip: skip, limit: limit));
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ склада');
    }
    return StockListPage.fromJson(data);
  }
}

final warehouseApiServiceProvider = Provider<WarehouseApiService>((ref) {
  return WarehouseApiService(ref.watch(rawDioProvider));
});
