import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client.dart';
import '../api_config.dart';
import '../../../features/catalog/data/catalog_models.dart';

/// Catalog microservice API (Traefik path prefix `/catalog`).
class CatalogApiService {
  CatalogApiService(this._dio);

  final Dio _dio;

  Future<ProductListPage> listProducts({int skip = 0, int limit = 50}) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.catalogProducts(skip: skip, limit: limit));
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ каталога');
    }
    return ProductListPage.fromJson(data);
  }

  Future<ProductDetail> getProduct(int id) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.catalogProduct(id));
    final data = r.data;
    if (data == null) {
      throw Exception('Товар не найден');
    }
    return ProductDetail.fromJson(data);
  }

  Future<ProductDetail> createProduct({
    required String name,
    required String category,
    required double price,
    required String sku,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiPaths.catalogProductsCreate,
      data: {
        'name': name,
        'category': category,
        'price': price,
        'sku': sku,
      },
    );
    final data = r.data;
    if (data == null) {
      throw Exception('Пустой ответ при создании товара');
    }
    return ProductDetail.fromJson(data);
  }

  Future<List<CatalogAutocompleteItem>> autocomplete(String query, {int limit = 10}) async {
    final r = await _dio.get<Map<String, dynamic>>(ApiPaths.catalogAutocomplete(query, limit: limit));
    final data = r.data;
    if (data == null) {
      return [];
    }
    final raw = data['items'] as List<dynamic>? ?? [];
    return raw.map((e) => CatalogAutocompleteItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

final catalogApiServiceProvider = Provider<CatalogApiService>((ref) {
  return CatalogApiService(ref.watch(dioProvider));
});
