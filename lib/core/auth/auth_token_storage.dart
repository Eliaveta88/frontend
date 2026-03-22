import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Хранение пары JWT: на **Web** — [SharedPreferences]; на **iOS/Android** (и др. натив) —
/// [FlutterSecureStorage] (Keychain / EncryptedSharedPreferences).
abstract final class AuthTokenStorage {
  static const accessKey = 'grauth_access_token';
  static const refreshKey = 'grauth_refresh_token';

  static const FlutterSecureStorage _vault = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> save(
    SharedPreferences prefs, {
    required String access,
    required String refresh,
  }) async {
    if (kIsWeb) {
      await prefs.setString(accessKey, access);
      await prefs.setString(refreshKey, refresh);
      return;
    }
    await _vault.write(key: accessKey, value: access);
    await _vault.write(key: refreshKey, value: refresh);
    await prefs.remove(accessKey);
    await prefs.remove(refreshKey);
  }

  static Future<void> clear(SharedPreferences prefs) async {
    await prefs.remove(accessKey);
    await prefs.remove(refreshKey);
    if (!kIsWeb) {
      await _vault.delete(key: accessKey);
      await _vault.delete(key: refreshKey);
    }
  }

  /// Восстановление при старте; при миграции с prefs в vault переносит значения.
  static Future<({String? access, String? refresh})> read(SharedPreferences prefs) async {
    if (kIsWeb) {
      return (
        access: prefs.getString(accessKey),
        refresh: prefs.getString(refreshKey),
      );
    }
    var access = await _vault.read(key: accessKey);
    var refresh = await _vault.read(key: refreshKey);
    final legacyA = prefs.getString(accessKey);
    final legacyR = prefs.getString(refreshKey);
    if ((access == null || refresh == null) && legacyA != null && legacyR != null) {
      await prefs.remove(accessKey);
      await prefs.remove(refreshKey);
      await _vault.write(key: accessKey, value: legacyA);
      await _vault.write(key: refreshKey, value: legacyR);
      access = legacyA;
      refresh = legacyR;
    }
    return (access: access, refresh: refresh);
  }
}
