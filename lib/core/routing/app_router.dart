import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/pages/catalog_page.dart';
import '../../features/catalog/pages/product_detail_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/finance/pages/finance_page.dart';
import '../../features/identity/pages/admin_page.dart';
import '../../features/identity/pages/login_page.dart';
import '../../features/logistics/pages/logistics_page.dart';
import '../../features/orders/pages/orders_page.dart';
import '../../features/orders/pages/order_detail_page.dart';
import '../../features/warehouse/pages/warehouse_page.dart';
import '../auth/auth_provider.dart';
import '../widgets/app_shell.dart';
import 'route_names.dart';

final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();
const _authEnabled = false;

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: Routes.dashboard,
    redirect: (context, state) {
      if (!_authEnabled) return null;
      final loggedIn = auth.isAuthenticated;
      final goingToLogin = state.matchedLocation == Routes.login;

      if (!loggedIn && !goingToLogin) return Routes.login;
      if (loggedIn && goingToLogin) return Routes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: Routes.orders,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersPage(),
            ),
          ),
          GoRoute(
            path: Routes.orderDetail,
            builder: (context, state) => OrderDetailPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: Routes.catalog,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogPage(),
            ),
          ),
          GoRoute(
            path: Routes.productDetail,
            builder: (context, state) => ProductDetailPage(
              id: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: Routes.warehouse,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WarehousePage(),
            ),
          ),
          GoRoute(
            path: Routes.finance,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinancePage(),
            ),
          ),
          GoRoute(
            path: Routes.logistics,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LogisticsPage(),
            ),
          ),
          GoRoute(
            path: Routes.admin,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
