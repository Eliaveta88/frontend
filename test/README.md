# Тесты GastroRoute Frontend

Запуск всех тестов (сейчас **~22** unit/widget-теста):

```bash
cd GastroRoute_frontend
flutter test
```

Запуск с покрытием (нужен `coverage`):

```bash
flutter test --coverage
```

## Что покрыто (по планам P1–P2 и фаза UX)

| Область | Файлы |
|--------|--------|
| Сеть | `dio_error_mapper_test.dart`, `api_config_test.dart` |
| Виджеты фазы 1 | `empty_list_state_test.dart`, `async_error_card_test.dart`, `loading_skeletons_test.dart` |
| Модели API | `core/models_json_test.dart` (каталог, identity, заказы, склад) |
| Приложение | полный smoke — см. `integration_test` при необходимости (роутер + таймеры) |

Интеграционные тесты с реальным Traefik в CI не включены — используйте ручной прогон или `integration_test` при необходимости.
