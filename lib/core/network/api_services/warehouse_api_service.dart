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

  Future<Map<String, dynamic>> receiveBatch({
    required int productId,
    required int quantity,
    required String unitType,
    required DateTime expiryDate,
    required String cellLocation,
    required String batchReference,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiPaths.warehouseReceive,
      data: {
        'product_id': productId,
        'quantity': quantity,
        'unit_type': unitType,
        'expiry_date': expiryDate.toUtc().toIso8601String(),
        'cell_location': cellLocation,
        'batch_reference': batchReference,
      },
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ оприходования');
    }
    return data;
  }
}

final warehouseApiServiceProvider = Provider<WarehouseApiService>((ref) {
  return WarehouseApiService(ref.watch(dioProvider));
});
