import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../finance/providers/finance_providers.dart';

/// Агрегат KPI для дашборда (параллельные запросы к каталогу, заказам, финансам).
class DashboardSummary {
  const DashboardSummary({
    this.catalogTotal,
    this.ordersTotal,
    this.ordersToday,
    this.revenueTodayRub,
    this.routesInProgress,
    this.partialErrors = const [],
  });

  /// Всего позиций в каталоге (поле `total` из API).
  final int? catalogTotal;

  /// Всего заказов в системе.
  final int? ordersTotal;

  /// Заказов с `created_at` за сегодня (по первой странице списка, до `limit`).
  final int? ordersToday;

  /// Сумма проведённых (`completed`) транзакций за сегодня для текущего `client_id`.
  final double? revenueTodayRub;

  /// Маршруты со статусом `in_progress` (по первой странице списка).
  final int? routesInProgress;

  /// Частичные сбои (остальные KPI могли загрузиться).
  final List<String> partialErrors;
}

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final raw = ref.watch(rawDioProvider);
  final clientId = ref.watch(financeClientIdProvider);

  int? catalogTotal;
  int? ordersTotal;
  int? ordersToday;
  double? revenueTodayRub;
  int? routesInProgress;
  final partialErrors = <String>[];

  Future<void> loadCatalog() async {
    try {
      final r = await raw.get<Map<String, dynamic>>(ApiPaths.catalogProducts(skip: 0, limit: 1));
      final data = r.data;
      if (data != null) {
        catalogTotal = (data['total'] as num?)?.toInt();
      }
    } catch (e) {
      partialErrors.add('Каталог: ${dioErrorMessage(e)}');
    }
  }

  Future<void> loadOrders() async {
    try {
      final r = await raw.get<Map<String, dynamic>>(ApiPaths.ordersList(skip: 0, limit: 200));
      final data = r.data;
      if (data == null) return;
      ordersTotal = (data['total'] as num?)?.toInt();
      final items = data['items'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var n = 0;
      for (final e in items) {
        final m = e as Map<String, dynamic>;
        final ca = m['created_at'];
        if (ca is! String) continue;
        final d = DateTime.tryParse(ca);
        if (d == null) continue;
        final d0 = DateTime(d.year, d.month, d.day);
        if (d0 == today) n++;
      }
      ordersToday = n;
    } catch (e) {
      partialErrors.add('Заказы: ${dioErrorMessage(e)}');
    }
  }

  Future<void> loadFinanceToday() async {
    try {
      final r = await raw.get<Map<String, dynamic>>(
        ApiPaths.financeTransactions(clientId, skip: 0, limit: 100),
      );
      final data = r.data;
      if (data == null) return;
      final items = data['items'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var sum = 0.0;
      for (final e in items) {
        final m = e as Map<String, dynamic>;
        final ca = m['created_at'];
        if (ca is! String) continue;
        final d = DateTime.tryParse(ca);
        if (d == null) continue;
        final d0 = DateTime(d.year, d.month, d.day);
        if (d0 != today) continue;
        final status = m['status']?.toString() ?? '';
        if (status != 'completed') continue;
        final amt = (m['amount'] as num?)?.toDouble() ?? 0;
        if (amt > 0) sum += amt;
      }
      revenueTodayRub = sum;
    } on DioException catch (e) {
      partialErrors.add('Финансы: ${dioErrorMessage(e)}');
    } catch (e) {
      partialErrors.add('Финансы: ${dioErrorMessage(e)}');
    }
  }

  Future<void> loadLogistics() async {
    try {
      final r = await raw.get<Map<String, dynamic>>(ApiPaths.logisticsRoutes(skip: 0, limit: 200));
      final data = r.data;
      if (data == null) return;
      final items = data['items'] as List<dynamic>? ?? [];
      var n = 0;
      for (final e in items) {
        final m = e as Map<String, dynamic>;
        if (m['status']?.toString() == 'in_progress') n++;
      }
      routesInProgress = n;
    } catch (e) {
      partialErrors.add('Логистика: ${dioErrorMessage(e)}');
    }
  }

  await Future.wait<void>([
    loadCatalog(),
    loadOrders(),
    loadFinanceToday(),
    loadLogistics(),
  ]);

  return DashboardSummary(
    catalogTotal: catalogTotal,
    ordersTotal: ordersTotal,
    ordersToday: ordersToday,
    revenueTodayRub: revenueTodayRub,
    routesInProgress: routesInProgress,
    partialErrors: partialErrors,
  );
});
