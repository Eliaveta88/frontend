import 'package:shared_preferences/shared_preferences.dart';

/// Keys for persisted JWT pair (access + refresh).
abstract final class AuthTokenStorage {
  static const accessKey = 'grauth_access_token';
  static const refreshKey = 'grauth_refresh_token';

  static Future<void> save(
    SharedPreferences prefs, {
    required String access,
    required String refresh,
  }) async {
    await prefs.setString(accessKey, access);
    await prefs.setString(refreshKey, refresh);
  }

  static Future<void> clear(SharedPreferences prefs) async {
    await prefs.remove(accessKey);
    await prefs.remove(refreshKey);
  }
}
