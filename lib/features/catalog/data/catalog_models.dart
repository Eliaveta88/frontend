/// Autocomplete item (`product_id` + `name` from catalog API).
class CatalogAutocompleteItem {
  const CatalogAutocompleteItem({required this.id, required this.name});

  factory CatalogAutocompleteItem.fromJson(Map<String, dynamic> json) {
    return CatalogAutocompleteItem(
      id: json['product_id'] as int? ?? json['id'] as int,
      name: json['name'] as String,
    );
  }

  final int id;
  final String name;
}

class ProductListItem {
  const ProductListItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.sku,
    required this.inStock,
  });

  factory ProductListItem.fromJson(Map<String, dynamic> json) {
    return ProductListItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      sku: json['sku'] as String,
      inStock: json['in_stock'] as bool? ?? true,
    );
  }

  final int id;
  final String name;
  final String category;
  final double price;
  final String sku;
  final bool inStock;
}

class ProductListPage {
  const ProductListPage({
    required this.items,
    required this.total,
  });

  factory ProductListPage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? [];
    return ProductListPage(
      items: raw.map((e) => ProductListItem.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  final List<ProductListItem> items;
  final int total;
}

class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.sku,
    required this.inStock,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      sku: json['sku'] as String,
      inStock: json['in_stock'] as bool? ?? true,
    );
  }

  final int id;
  final String name;
  final String category;
  final double price;
  final String sku;
  final bool inStock;
}
