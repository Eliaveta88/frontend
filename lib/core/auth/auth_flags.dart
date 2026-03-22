/// Включить обязательный вход (`/login` + редирект). По умолчанию выключено для локальной разработки.
///
/// Сборка:
/// `flutter run --dart-define=AUTH_ENABLED=true`
const bool kAuthEnabled = bool.fromEnvironment('AUTH_ENABLED', defaultValue: false);
