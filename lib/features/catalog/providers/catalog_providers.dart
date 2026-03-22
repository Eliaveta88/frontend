import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_services/catalog_api_service.dart';
import '../data/catalog_models.dart';

final catalogProductsProvider = FutureProvider.autoDispose<ProductListPage>((ref) async {
  final api = ref.watch(catalogApiServiceProvider);
  return api.listProducts(skip: 0, limit: 100);
});

final productDetailProvider = FutureProvider.family.autoDispose<ProductDetail, int>((ref, id) async {
  final api = ref.watch(catalogApiServiceProvider);
  return api.getProduct(id);
});
