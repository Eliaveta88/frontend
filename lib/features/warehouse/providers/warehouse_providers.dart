import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/warehouse_api_service.dart';
import '../data/warehouse_models.dart';

final warehouseStockProvider = FutureProvider.autoDispose<StockListPage>((ref) async {
  final api = ref.watch(warehouseApiServiceProvider);
  return api.listStock(skip: 0, limit: 100);
});
