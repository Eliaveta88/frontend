import '../auth/auth_state.dart';
import 'route_names.dart';

/// Логика [GoRouter.redirect] для auth-gate и RBAC на `/admin` (удобно unit-тестировать без HTTP).
String? resolveAuthRedirect({
  required bool authGate,
  required AuthState auth,
  required String matchedLocation,
}) {
  if (!authGate) return null;
  final loggedIn = auth.isAuthenticated;
  final goingToLogin = matchedLocation == Routes.login;

  if (!loggedIn && !goingToLogin) return Routes.login;
  if (loggedIn && goingToLogin) return Routes.dashboard;

  if (loggedIn && matchedLocation == Routes.admin) {
    final roles = auth.profile?.roles ?? const <String>[];
    final isAdmin = roles.any((r) => r.toLowerCase() == 'admin');
    if (!isAdmin) return Routes.dashboard;
  }
  return null;
}
