# GastroRoute — Flutter Web

## Бэкенд (Traefik)

API доступно по префиксам сервисов, например:

- `http://localhost/catalog/api/v1/...`
- `http://localhost/identity/api/v1/...`
- `http://localhost/finance/api/v1/...`

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

## Что уже подключено к API

| Экран | Запросы |
|-------|---------|
| Дашборд | Только бизнес-обзор (KPI); состояние сервисов смотрите в Traefik |
| Каталог | `GET .../catalog/api/v1/catalog/products`, карточка товара по id |
| Финансы | Баланс и транзакции по `client_id` (поле в шапке) |
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
