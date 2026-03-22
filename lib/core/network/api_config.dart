/// Пути к API за Traefik (см. docker-compose / docker/traefik/dynamic.yml).
///
/// Полный URL: `{baseUrl}{path}` — например `http://localhost/catalog/api/v1/...`
abstract final class ApiPaths {
  static const identityLogin = '/identity/api/v1/identity/login';
  static const identityRefresh = '/identity/api/v1/identity/refresh';
  static const identityLogout = '/identity/api/v1/identity/logout';
  static const identityMe = '/identity/api/v1/identity/users/me';
  /// POST create user (register).
  static const identityRegisterUsers = '/identity/api/v1/identity/users';

  static String catalogProducts({int skip = 0, int limit = 50}) =>
      '/catalog/api/v1/catalog/products?skip=$skip&limit=$limit';

  static String catalogProduct(int id) => '/catalog/api/v1/catalog/products/$id';

  static String catalogAutocomplete(String query, {int limit = 10}) =>
      '/catalog/api/v1/catalog/products/autocomplete?query=${Uri.encodeQueryComponent(query)}&limit=$limit';

  static String financeTransactions(int clientId, {int skip = 0, int limit = 50}) =>
      '/finance/api/v1/finance/transactions?client_id=$clientId&skip=$skip&limit=$limit';

  static String financeBalance(int clientId) =>
      '/finance/api/v1/finance/accounts/$clientId/balance';

  /// Список заказов (Traefik stripPrefix `/orders` → сервис видит `/api/v1/...`).
  static String ordersList({int skip = 0, int limit = 50}) =>
      '/orders/api/v1/orders?skip=$skip&limit=$limit';

  static String ordersOrder(int id) => '/orders/api/v1/orders/$id';

  static String warehouseStock({int skip = 0, int limit = 50}) =>
      '/warehouse/api/v1/warehouse?skip=$skip&limit=$limit';
}
