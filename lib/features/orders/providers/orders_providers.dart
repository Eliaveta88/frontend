import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/orders_api_service.dart';
import '../data/order_models.dart';

/// Размер страницы списка заказов.
const kOrdersPageSize = 25;

final ordersSkipProvider = StateProvider<int>((ref) => 0);

final ordersListProvider = FutureProvider.autoDispose<OrderListPage>((ref) async {
  final skip = ref.watch(ordersSkipProvider);
  final api = ref.watch(ordersApiServiceProvider);
  return api.listOrders(skip: skip, limit: kOrdersPageSize);
});

final orderDetailProvider = FutureProvider.family.autoDispose<OrderDetail, int>((ref, id) async {
  final api = ref.watch(ordersApiServiceProvider);
  return api.getOrder(id);
});
