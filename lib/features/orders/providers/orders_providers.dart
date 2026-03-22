import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/orders_api_service.dart';
import '../data/order_models.dart';

final ordersListProvider = FutureProvider.autoDispose<OrderListPage>((ref) async {
  final api = ref.watch(ordersApiServiceProvider);
  return api.listOrders(skip: 0, limit: 100);
});

final orderDetailProvider = FutureProvider.family.autoDispose<OrderDetail, int>((ref, id) async {
  final api = ref.watch(ordersApiServiceProvider);
  return api.getOrder(id);
});
