import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_services/orders_api_service.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../finance/providers/finance_providers.dart';
import '../data/activity_feed_item.dart';

/// Результат загрузки ленты «активности»: заказы + транзакции плюс сообщения о частичных сбоях.
class DashboardActivity {
  const DashboardActivity({
    required this.items,
    this.ordersError,
    this.transactionsError,
  });

  final List<ActivityFeedItem> items;
  final String? ordersError;
  final String? transactionsError;

  bool get hasPartialFailure => ordersError != null || transactionsError != null;
}

/// Последние заказы и транзакции (два параллельных запроса), объединённые по дате.
final dashboardActivityProvider =
    FutureProvider.autoDispose<DashboardActivity>((ref) async {
  final dio = ref.watch(dioProvider);
  final clientId = ref.watch(financeClientIdProvider);
  final ordersApi = ref.watch(ordersApiServiceProvider);

  final items = <ActivityFeedItem>[];
  String? ordersErr;
  String? txsErr;

  try {
    final page = await ordersApi.listOrders(skip: 0, limit: 8);
    for (final o in page.items) {
      items.add(ActivityFeedItem.fromOrder(o));
    }
  } catch (e) {
    ordersErr = dioErrorMessage(e);
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
  } catch (e) {
    txsErr = dioErrorMessage(e);
  }

  items.sort((a, b) => b.at.compareTo(a.at));
  final trimmed = items.length > 12 ? items.sublist(0, 12) : items;
  return DashboardActivity(
    items: trimmed,
    ordersError: ordersErr,
    transactionsError: txsErr,
  );
});
