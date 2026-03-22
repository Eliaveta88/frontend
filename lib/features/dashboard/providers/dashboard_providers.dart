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

  /// Заказов с `created_at` за календарный сегодня (локальная дата → `total` с API с фильтром).
  final int? ordersToday;

  /// Сумма проведённых (`completed`) транзакций за сегодня для текущего `client_id`.
  final double? revenueTodayRub;

  /// Маршруты со статусом `in_progress` (поле `total` с API при фильтре по статусу).
  final int? routesInProgress;

  /// Частичные сбои (остальные KPI могли загрузиться).
  final List<String> partialErrors;
}

final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final dio = ref.watch(dioProvider);
  final clientId = ref.watch(financeClientIdProvider);

  int? catalogTotal;
  int? ordersTotal;
  int? ordersToday;
  double? revenueTodayRub;
  int? routesInProgress;
  final partialErrors = <String>[];

  Future<void> loadCatalog() async {
    try {
      final r = await dio.get<Map<String, dynamic>>(ApiPaths.catalogProducts(skip: 0, limit: 1));
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
      final rAll = await dio.get<Map<String, dynamic>>(ApiPaths.ordersList(skip: 0, limit: 1));
      final dataAll = rAll.data;
      if (dataAll != null) {
        ordersTotal = (dataAll['total'] as num?)?.toInt();
      }
      final now = DateTime.now();
      final startLocal = DateTime(now.year, now.month, now.day);
      final endLocal = startLocal.add(const Duration(days: 1));
      final rToday = await dio.get<Map<String, dynamic>>(
        ApiPaths.ordersList(
          skip: 0,
          limit: 1,
          createdFromIso: startLocal.toUtc().toIso8601String(),
          createdToIso: endLocal.toUtc().toIso8601String(),
        ),
      );
      final dataToday = rToday.data;
      if (dataToday != null) {
        ordersToday = (dataToday['total'] as num?)?.toInt();
      }
    } catch (e) {
      partialErrors.add('Заказы: ${dioErrorMessage(e)}');
    }
  }

  Future<void> loadFinanceToday() async {
    try {
      final now = DateTime.now();
      final startLocal = DateTime(now.year, now.month, now.day);
      final endLocal = startLocal.add(const Duration(days: 1));
      final r = await dio.get<Map<String, dynamic>>(
        ApiPaths.financeRevenue(
          clientId,
          fromIso: startLocal.toUtc().toIso8601String(),
          toIso: endLocal.toUtc().toIso8601String(),
        ),
      );
      final data = r.data;
      if (data == null) return;
      final total = data['total_amount'];
      if (total is num) {
        revenueTodayRub = total.toDouble();
      }
    } on DioException catch (e) {
      partialErrors.add('Финансы: ${dioErrorMessage(e)}');
    } catch (e) {
      partialErrors.add('Финансы: ${dioErrorMessage(e)}');
    }
  }

  Future<void> loadLogistics() async {
    try {
      final r = await dio.get<Map<String, dynamic>>(
        ApiPaths.logisticsRoutes(skip: 0, limit: 1, status: 'in_progress'),
      );
      final data = r.data;
      if (data == null) return;
      routesInProgress = (data['total'] as num?)?.toInt();
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
