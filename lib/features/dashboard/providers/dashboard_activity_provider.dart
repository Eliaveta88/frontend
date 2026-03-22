import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_services/orders_api_service.dart';
import '../../finance/providers/finance_providers.dart';
import '../data/activity_feed_item.dart';

/// Последние заказы и транзакции (два параллельных запроса), объединённые по дате.
final dashboardActivityProvider =
    FutureProvider.autoDispose<List<ActivityFeedItem>>((ref) async {
  final dio = ref.watch(dioProvider);
  final clientId = ref.watch(financeClientIdProvider);
  final ordersApi = ref.watch(ordersApiServiceProvider);

  final items = <ActivityFeedItem>[];

  try {
    final page = await ordersApi.listOrders(skip: 0, limit: 8);
    for (final o in page.items) {
      items.add(ActivityFeedItem.fromOrder(o));
    }
  } catch (_) {
    // частичный сбой — лента может показать только транзакции
  }

  try {
    final r = await dio.get<Map<String, dynamic>>(
      ApiPaths.financeTransactions(clientId, skip: 0, limit: 8),
    );
    final data = r.data;
    if (data != null) {
      final raw = data['items'] as List<dynamic>? ?? [];
      for (final e in raw) {
        items.add(ActivityFeedItem.fromTransaction(e as Map<String, dynamic>));
      }
    }
  } on DioException catch (_) {
    // частичный сбой
  } catch (_) {}

  items.sort((a, b) => b.at.compareTo(a.at));
  if (items.length > 12) {
    return items.sublist(0, 12);
  }
  return items;
});
