import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastroroute_frontend/core/auth/auth_persistence.dart';
import 'package:gastroroute_frontend/core/auth/auth_provider.dart';
import 'package:gastroroute_frontend/core/network/api_services/identity_api_service.dart';
import 'package:gastroroute_frontend/core/persistence/shared_preferences_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockIdentityApi extends Mock implements IdentityApiService {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  test('login sets tokens and profile', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mock = _MockIdentityApi();
    when(
      () => mock.login(username: any(named: 'username'), password: any(named: 'password')),
    ).thenAnswer(
      (_) async => {
        'access_token': 'access',
        'refresh_token': 'refresh',
        'user': {
          'id': 42,
          'username': 'tester',
          'email': 't@t.com',
          'roles': ['user'],
        },
      },
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authPersistenceProvider.overrideWithValue(PrefsOnlyAuthPersistence()),
        identityApiServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).login(username: 'tester', password: 'secret');

    final s = container.read(authProvider);
    expect(s.accessToken, 'access');
    expect(s.refreshToken, 'refresh');
    expect(s.profile?.id, 42);
    expect(s.profile?.username, 'tester');
    verify(() => mock.login(username: 'tester', password: 'secret')).called(1);
  });

  test('logout clears state', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final mock = _MockIdentityApi();
    when(
      () => mock.login(username: any(named: 'username'), password: any(named: 'password')),
    ).thenAnswer(
      (_) async => {
        'access_token': 'a',
        'refresh_token': 'r',
        'user': {'id': 1, 'username': 'u', 'email': 'u@u.com', 'roles': []},
      },
    );
    when(() => mock.logout()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authPersistenceProvider.overrideWithValue(PrefsOnlyAuthPersistence()),
        identityApiServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).login(username: 'u', password: 'p');
    await container.read(authProvider.notifier).logout();

    final s = container.read(authProvider);
    expect(s.accessToken, isNull);
    expect(s.isAuthenticated, isFalse);
    verify(() => mock.logout()).called(1);
  });
}
