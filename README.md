# GastroRoute — Flutter Web

## Бэкенд (Traefik)

API доступно по префиксам сервисов, например:

- `http://localhost/catalog/api/v1/...`
- `http://localhost/identity/api/v1/...`
- `http://localhost/finance/api/v1/...`
- `http://localhost/warehouse/api/v1/...`
- `http://localhost/logistics/api/v1/...`

Поднимите стек: `docker compose up -d --build` в корне репозитория.

### UI через Traefik

После сборки сервиса **`frontend`** интерфейс открывается на **`http://localhost/`** (тот же origin, что и API). В `docker/traefik/dynamic.yml` маршрут `frontend` имеет низкий приоритет, чтобы пути `/catalog`, `/identity` и т.д. уходили в микросервисы.

## Базовый URL для фронта

В Docker-сборке **`API_BASE_URL` не задаётся** — на Web используется **`Uri.base.origin`** (например `http://localhost` при открытии `http://localhost/`).

Локальная разработка без Docker: по умолчанию клиент ходит на **`http://localhost`** (порт **80** у Traefik).

Другой хост/порт:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.10
```

### Обязательный вход

По умолчанию приложение открывается **без** экрана логина (удобно для разработки). Чтобы требовать JWT и редиректить на `/login`:

```bash
flutter run -d chrome --dart-define=AUTH_ENABLED=true --dart-define=API_BASE_URL=http://localhost
```

После успешного входа `client_id` для финансов подставляется из **id пользователя** identity (для сидов 1:1 с `accounts.client_id`).

### Ошибки сети в UI

Сообщения для пользователя нормализуются через `lib/core/network/dio_error_mapper.dart` (`dioErrorMessage`).

## Что уже подключено к API

| Экран | Запросы |
|-------|---------|
| Шапка | Поиск по каталогу: autocomplete → переход к карточке товара |
| Дашборд | KPI: каталог, заказы, финансы, логистика (`in_progress`), pull-to-refresh |
| Каталог | `GET .../catalog/api/v1/catalog/products`, карточка товара по id |
| Заказы | Список и детали через `/orders/api/v1/orders` |
| Склад | `GET .../warehouse/api/v1/warehouse` — остатки |
| Логистика | `GET .../logistics/api/v1/logistics` — маршруты |
| Финансы | Баланс и транзакции по `client_id` (поле на странице) |
| Логин | `POST .../identity/api/v1/identity/login` (токены в `authProvider`) |
| Refresh | Через `AuthInterceptor` → `POST .../identity/refresh` |

Каталог и финансы используют **публичные** запросы (`rawDio` без JWT). Для защищённых маршрутов используйте `dioProvider` (Bearer из `authProvider`).

## Запуск

```bash
cd GastroRoute_frontend
flutter pub get
flutter run -d chrome
```

CORS на сервисах уже разрешён для разработки (`allow_origins=["*"]`).
