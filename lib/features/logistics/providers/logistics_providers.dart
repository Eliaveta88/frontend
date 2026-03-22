import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/logistics_api_service.dart';
import '../data/logistics_models.dart';

final logisticsRoutesProvider = FutureProvider.autoDispose<RouteListPage>((ref) async {
  final api = ref.watch(logisticsApiServiceProvider);
  return api.listRoutes(skip: 0, limit: 100);
});
