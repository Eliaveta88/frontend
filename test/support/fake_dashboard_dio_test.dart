import 'package:flutter_test/flutter_test.dart';

import 'fake_dashboard_dio.dart';

void main() {
  test('fake dio resolves orders list total', () async {
    final dio = createFakeDashboardDio();
    final r = await dio.get<Map<String, dynamic>>(
      '/orders/api/v1/orders?skip=0&limit=1',
    );
    expect(r.data?['total'], 99);
  });

  test('fake dio resolves orders today total', () async {
    final dio = createFakeDashboardDio();
    final r = await dio.get<Map<String, dynamic>>(
      '/orders/api/v1/orders?skip=0&limit=1&created_from=2020-01-01T00:00:00.000Z&created_to=2020-01-02T00:00:00.000Z',
    );
    expect(r.data?['total'], 7);
  });
}
