import 'package:flutter_test/flutter_test.dart';
import 'package:gastroroute_frontend/core/auth/auth_state.dart';
import 'package:gastroroute_frontend/core/auth/user_profile.dart';
import 'package:gastroroute_frontend/core/routing/auth_redirect.dart';
import 'package:gastroroute_frontend/core/routing/route_names.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('auth disabled: no redirect', () {
      expect(
        resolveAuthRedirect(
          authGate: false,
          auth: const AuthState(accessToken: null, refreshToken: null),
          matchedLocation: Routes.admin,
        ),
        isNull,
      );
    });

    test('auth enabled and not logged in: send to login', () {
      expect(
        resolveAuthRedirect(
          authGate: true,
          auth: const AuthState(accessToken: null, refreshToken: null),
          matchedLocation: Routes.dashboard,
        ),
        Routes.login,
      );
    });

    test('logged in on login page: send to dashboard', () {
      expect(
        resolveAuthRedirect(
          authGate: true,
          auth: const AuthState(accessToken: 'a', refreshToken: 'r'),
          matchedLocation: Routes.login,
        ),
        Routes.dashboard,
      );
    });

    test('non-admin on /admin: send to dashboard', () {
      expect(
        resolveAuthRedirect(
          authGate: true,
          auth: AuthState(
            accessToken: 'a',
            refreshToken: 'r',
            profile: const UserProfile(id: 1, username: 'u', email: 'u@u.com', roles: ['user']),
          ),
          matchedLocation: Routes.admin,
        ),
        Routes.dashboard,
      );
    });

    test('admin on /admin: no redirect', () {
      expect(
        resolveAuthRedirect(
          authGate: true,
          auth: AuthState(
            accessToken: 'a',
            refreshToken: 'r',
            profile: const UserProfile(id: 1, username: 'u', email: 'u@u.com', roles: ['admin']),
          ),
          matchedLocation: Routes.admin,
        ),
        isNull,
      );
    });
  });
}
