import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Лёгкая прослойка i18n: карты RU/EN по ключам и `of(context)`.
///
/// Сейчас в приложении большинство строк — RU inline. Этот модуль закладывает
/// инфраструктуру: когда строка нужна в двух локалях, её добавляют в `_values`
/// и используют `AppStrings.of(context).t('key')` или именованные геттеры.
class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
  ];

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const AppStrings(Locale('ru'));
  }

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();

  static const Map<String, Map<String, String>> _values = {
    'ru': {
      'app.title': 'GastroRoute',
      'common.retry': 'Повторить',
      'common.close': 'Закрыть',
      'common.cancel': 'Отмена',
      'common.save': 'Сохранить',
      'common.loading': 'Загрузка…',
      'common.error': 'Ошибка',
      'error.unknown': 'Неизвестная ошибка',
    },
    'en': {
      'app.title': 'GastroRoute',
      'common.retry': 'Retry',
      'common.close': 'Close',
      'common.cancel': 'Cancel',
      'common.save': 'Save',
      'common.loading': 'Loading…',
      'common.error': 'Error',
      'error.unknown': 'Unknown error',
    },
  };

  String t(String key) {
    final bucket = _values[locale.languageCode] ?? _values['ru']!;
    return bucket[key] ?? _values['ru']![key] ?? key;
  }

  String get appTitle => t('app.title');
  String get commonRetry => t('common.retry');
  String get commonClose => t('common.close');
  String get commonCancel => t('common.cancel');
  String get commonSave => t('common.save');
  String get commonLoading => t('common.loading');
  String get commonError => t('common.error');
  String get errorUnknown => t('error.unknown');
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppStrings.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
