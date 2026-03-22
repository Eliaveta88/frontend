/// Пути к backend API (базовый URL задаётся в окружении приложения).
abstract final class ApiPaths {
  static const identityLogin = '/identity/api/v1/identity/login';
  static const identityRefresh = '/identity/api/v1/identity/refresh';
  static const identityLogout = '/identity/api/v1/identity/logout';
  static const identityMe = '/identity/api/v1/identity/users/me';
  /// POST create user (register).
  static const identityRegisterUsers = '/identity/api/v1/identity/users';

  static String identityUsersList({int skip = 0, int limit = 50}) =>
      '/identity/api/v1/identity/users?skip=$skip&limit=$limit';

  static String catalogProducts({int skip = 0, int limit = 50}) =>
      '/catalog/api/v1/catalog/products?skip=$skip&limit=$limit';

  /// POST создание товара (тело без query).
  static const catalogProductsCreate = '/catalog/api/v1/catalog/products';

  static String catalogProduct(int id) => '/catalog/api/v1/catalog/products/$id';

  static String catalogAutocomplete(String query, {int limit = 10}) =>
      '/catalog/api/v1/catalog/products/autocomplete?query=${Uri.encodeQueryComponent(query)}&limit=$limit';

  static String financeTransactions(int clientId, {int skip = 0, int limit = 50}) =>
      '/finance/api/v1/finance/transactions?client_id=$clientId&skip=$skip&limit=$limit';

  static String financeBalance(int clientId) =>
      '/finance/api/v1/finance/accounts/$clientId/balance';

  /// Сумма завершённых положительных транзакций за полуинтервал [from, to) — см. finance `GET .../revenue`.
  static String financeRevenue(int clientId, {required String fromIso, required String toIso}) {
    final q = Uri(queryParameters: {
      'from': fromIso,
      'to': toIso,
    }).query;
    return '/finance/api/v1/finance/accounts/$clientId/revenue?$q';
  }

  static const financeTransactionsPost = '/finance/api/v1/finance/transactions';

  static const financeInvoiceGenerate = '/finance/api/v1/finance/invoices/generate';

  /// Список заказов.
  static String ordersList({
    int skip = 0,
    int limit = 50,
    String? createdFromIso,
    String? createdToIso,
  }) {
    final params = <String, String>{
      'skip': '$skip',
      'limit': '$limit',
    };
    if (createdFromIso != null) {
      params['created_from'] = createdFromIso;
    }
    if (createdToIso != null) {
      params['created_to'] = createdToIso;
    }
    final q = Uri(queryParameters: params).query;
    return '/orders/api/v1/orders?$q';
  }

  /// POST создание заказа (тот же префикс, без query).
  static const ordersCreate = '/orders/api/v1/orders';

  static String ordersOrder(int id) => '/orders/api/v1/orders/$id';

  static String warehouseStock({int skip = 0, int limit = 50}) =>
      '/warehouse/api/v1/warehouse?skip=$skip&limit=$limit';

  static const warehouseReceive = '/warehouse/api/v1/warehouse/receive';

  static String logisticsRoutes({
    int skip = 0,
    int limit = 50,
    String? status,
  }) {
    final params = <String, String>{
      'skip': '$skip',
      'limit': '$limit',
    };
    if (status != null && status.isNotEmpty) {
      params['status'] = status;
    }
    return '/logistics/api/v1/logistics?${Uri(queryParameters: params).query}';
  }

  /// POST создание маршрута (тело без query).
  static const logisticsRoutesCreate = '/logistics/api/v1/logistics';
}
