import 'package:flutter_test/flutter_test.dart';

import 'package:gastroroute_frontend/core/network/api_config.dart';

void main() {
  group('ApiPaths', () {
    test('ordersList base query', () {
      final p = ApiPaths.ordersList(skip: 10, limit: 20);
      expect(p, startsWith('/orders/api/v1/orders?'));
      expect(p, contains('skip=10'));
      expect(p, contains('limit=20'));
    });

    test('ordersList adds created_from and created_to', () {
      final p = ApiPaths.ordersList(
        skip: 0,
        limit: 1,
        createdFromIso: '2026-03-19T00:00:00.000Z',
        createdToIso: '2026-03-20T00:00:00.000Z',
      );
      expect(p, contains('created_from='));
      expect(p, contains('created_to='));
    });

    test('identityUsersList', () {
      expect(
        ApiPaths.identityUsersList(skip: 5, limit: 100),
        '/identity/api/v1/identity/users?skip=5&limit=100',
      );
    });

    test('warehouseReceive constant', () {
      expect(ApiPaths.warehouseReceive, '/warehouse/api/v1/warehouse/receive');
    });

    test('catalogAutocomplete encodes query', () {
      final p = ApiPaths.catalogAutocomplete('молоко & сыр');
      expect(p, contains(Uri.encodeQueryComponent('молоко & сыр')));
    });

    test('logisticsRoutes optional status', () {
      expect(
        ApiPaths.logisticsRoutes(skip: 0, limit: 1),
        '/logistics/api/v1/logistics?skip=0&limit=1',
      );
      final withStatus = ApiPaths.logisticsRoutes(
        skip: 0,
        limit: 1,
        status: 'in_progress',
      );
      expect(withStatus, contains('status=in_progress'));
    });
  });
}
