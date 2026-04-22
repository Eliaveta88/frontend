import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Включить обязательный вход (`/login` + редирект). По умолчанию выключено для локальной разработки.
///
/// Сборка:
/// `flutter run --dart-define=AUTH_ENABLED=true`
const bool kAuthEnabled = bool.fromEnvironment('AUTH_ENABLED', defaultValue: false);

/// Значение по умолчанию совпадает с [kAuthEnabled]; в тестах переопределяйте через [ProviderScope.overrides].
final authEnabledProvider = Provider<bool>((ref) => kAuthEnabled);
