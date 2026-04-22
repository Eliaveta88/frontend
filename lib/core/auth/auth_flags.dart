import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Включить обязательный вход (`/login` + редирект). По умолчанию включено; гостевого режима нет.
///
/// Отключить локально (например для e2e): `flutter run --dart-define=AUTH_ENABLED=false`.
const bool kAuthEnabled = bool.fromEnvironment('AUTH_ENABLED', defaultValue: true);

/// Значение по умолчанию совпадает с [kAuthEnabled]; в тестах переопределяйте через [ProviderScope.overrides].
final authEnabledProvider = Provider<bool>((ref) => kAuthEnabled);
