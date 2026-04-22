import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_token_storage.dart';

/// Абстракция над хранением JWT (web: prefs, native: secure storage). В тестах подменяют на prefs-only.
abstract class AuthPersistence {
  Future<({String? access, String? refresh})> readTokens(SharedPreferences prefs);

  Future<void> saveTokens(
    SharedPreferences prefs, {
    required String access,
    required String refresh,
  });

  Future<void> clearTokens(SharedPreferences prefs);
}

class DefaultAuthPersistence implements AuthPersistence {
  @override
  Future<({String? access, String? refresh})> readTokens(SharedPreferences prefs) =>
      AuthTokenStorage.read(prefs);

  @override
  Future<void> saveTokens(
    SharedPreferences prefs, {
    required String access,
    required String refresh,
  }) =>
      AuthTokenStorage.save(prefs, access: access, refresh: refresh);

  @override
  Future<void> clearTokens(SharedPreferences prefs) => AuthTokenStorage.clear(prefs);
}

/// Только SharedPreferences (как ветка web в [AuthTokenStorage]) — удобно для unit/widget-тестов на VM.
class PrefsOnlyAuthPersistence implements AuthPersistence {
  @override
  Future<({String? access, String? refresh})> readTokens(SharedPreferences prefs) async => (
        access: prefs.getString(AuthTokenStorage.accessKey),
        refresh: prefs.getString(AuthTokenStorage.refreshKey),
      );

  @override
  Future<void> saveTokens(
    SharedPreferences prefs, {
    required String access,
    required String refresh,
  }) async {
    await prefs.setString(AuthTokenStorage.accessKey, access);
    await prefs.setString(AuthTokenStorage.refreshKey, refresh);
  }

  @override
  Future<void> clearTokens(SharedPreferences prefs) async {
    await prefs.remove(AuthTokenStorage.accessKey);
    await prefs.remove(AuthTokenStorage.refreshKey);
  }
}

final authPersistenceProvider = Provider<AuthPersistence>((ref) => DefaultAuthPersistence());
