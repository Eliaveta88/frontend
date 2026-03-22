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

Пара **access / refresh** токенов сохраняется в **SharedPreferences** (в т.ч. на Web — в localStorage). После перезапуска приложения сессия восстанавливается, профиль подтягивается через `GET .../users/me`.

### Публичные и защищённые запросы

| Клиент | Назначение |
|--------|------------|
| **`rawDioProvider`** | Без `Authorization`: `POST /login`, `POST /refresh`, регистрация пользователя (`POST /users`), список пользователей в админке (`GET /users`) — пока без JWT на бэкенде. |
| **`dioProvider`** | С [AuthInterceptor](lib/core/network/auth_interceptor.dart): при наличии access-токена добавляется `Bearer`; автоматический refresh при 401. Используется для каталога, заказов, склада, финансов, логистики и для `GET /users/me`, `POST /logout`. |

Если токена нет (режим без `AUTH_ENABLED` или до входа), `dioProvider` отправляет те же запросы, что и раньше без заголовка авторизации.

### Ошибки сети в UI

Сообщения для пользователя нормализуются через `lib/core/network/dio_error_mapper.dart` (`dioErrorMessage`).

## Что уже подключено к API

| Экран | Запросы |
|-------|---------|
| Шапка | Поиск по каталогу: autocomplete → переход к карточке товара |
| Дашборд | KPI; выручка за день — `GET .../finance/accounts/{id}/revenue?from=&to=`; лента из заказов и транзакций; pull-to-refresh |
| Каталог | `GET .../catalog/api/v1/catalog/products`, карточка товара по id |
| Заказы | Список и детали через `/orders/api/v1/orders` |
| Склад | `GET .../warehouse/api/v1/warehouse` — остатки |
| Логистика | `GET .../logistics/api/v1/logistics` — маршруты |
| Финансы | Баланс и транзакции по `client_id` (поле на странице) |
| Логин | `POST .../identity/api/v1/identity/login` (токены в `authProvider`) |
| Refresh | Через `AuthInterceptor` → `POST .../identity/refresh` |

Каталог, заказы, склад, финансы и логистика идут через **`dioProvider`**: при входе к запросам добавляется Bearer; без токена поведение как у анонимного клиента. Только логин, refresh и часть identity-эндпоинтов остаются на **`rawDioProvider`** (см. таблицу выше).

## Запуск

```bash
cd GastroRoute_frontend
flutter pub get
flutter run -d chrome
```

CORS на сервисах уже разрешён для разработки (`allow_origins=["*"]`).
