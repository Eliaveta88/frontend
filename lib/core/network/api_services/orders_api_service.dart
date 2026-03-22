import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../api_config.dart';
import '../../../features/orders/data/order_models.dart';

/// Orders microservice (Traefik prefix `/orders`).
class OrdersApiService {
  OrdersApiService(this._dio);

  final Dio _dio;

  Future<OrderListPage> listOrders({int skip = 0, int limit = 50}) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.ordersList(skip: skip, limit: limit));
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ списка заказов');
    }
    return OrderListPage.fromJson(data);
  }

  Future<OrderDetail> getOrder(int id) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.ordersOrder(id));
    final data = r.data;
    if (data == null) {
      throw Exception('Заказ не найден');
    }
    return OrderDetail.fromJson(data);
  }

  /// POST [ApiPaths.ordersCreate].
  Future<OrderDetail> createOrder({
    required int clientId,
    required List<Map<String, dynamic>> items,
    required DateTime deliveryDate,
    String? notes,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiPaths.ordersCreate,
      data: {
        'client_id': clientId,
        'items': items,
        'delivery_date': deliveryDate.toUtc().toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes,
      },
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ при создании заказа');
    }
    return OrderDetail.fromJson(data);
  }
}

final ordersApiServiceProvider = Provider<OrdersApiService>((ref) {
  return OrdersApiService(ref.watch(rawDioProvider));
});
