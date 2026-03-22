import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/features/catalog/data/catalog_models.dart';
import 'package:gastroroute_frontend/features/identity/data/identity_users_models.dart';
import 'package:gastroroute_frontend/features/orders/data/order_models.dart';
import 'package:gastroroute_frontend/features/warehouse/data/warehouse_models.dart';

/// Парсинг JSON-моделей (каталог, identity, заказы, склад) — планы P2.
void main() {
  group('Catalog', () {
    test('ProductListPage.fromJson', () {
      final page = ProductListPage.fromJson({
        'items': [
          {
            'id': 5,
            'name': 'Сыр',
            'category': 'Молочка',
            'price': 350.0,
            'sku': 'S-1',
            'in_stock': false,
          },
        ],
        'total': 100,
      });
      expect(page.total, 100);
      expect(page.items.single.inStock, isFalse);
    });

    test('CatalogAutocompleteItem', () {
      final i = CatalogAutocompleteItem.fromJson({'product_id': 7, 'name': 'X'});
      expect(i.id, 7);
    });
  });

  group('IdentityUserListPage', () {
    test('fromJson', () {
      final page = IdentityUserListPage.fromJson({
        'items': [
          {
            'id': 1,
            'username': 'admin',
            'email': 'a@x.com',
            'roles': ['admin'],
          },
        ],
        'total': 1,
        'skip': 0,
        'limit': 100,
      });
      expect(page.items.first.username, 'admin');
    });
  });

  group('OrderListPage', () {
    test('fromJson', () {
      final page = OrderListPage.fromJson({
        'items': [
          {
            'id': 10,
            'client_id': 1,
            'client_name': 'C',
            'total_amount': 100.5,
            'status': 'draft',
            'delivery_date': '2026-03-20T12:00:00Z',
            'route_id': null,
            'created_at': '2026-03-19T10:00:00Z',
          },
        ],
        'total': 42,
        'skip': 0,
        'limit': 50,
      });
      expect(page.items.single.id, 10);
    });
  });

  group('StockListPage', () {
    test('fromJson', () {
      final page = StockListPage.fromJson({
        'items': [
          {
            'product_id': 1,
            'product_name': 'Milk',
            'available': 10,
            'reserved': 2,
            'total': 12,
            'cell_location': 'A-1',
            'batch_id': 99,
            'expiry_date': '2026-12-31T00:00:00Z',
          },
        ],
        'total': 1,
        'skip': 0,
        'limit': 200,
      });
      expect(page.items.single.productName, 'Milk');
    });
  });
}
