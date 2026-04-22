# Flutter Web → статика в nginx (один origin с API через Traefik).
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Build-time флаги, которые пробрасываются в Flutter через --dart-define.
# `AUTH_ENABLED=true` в prod-сборке включает обязательный вход + guard'ы роутера.
ARG AUTH_ENABLED=false
ARG API_BASE_URL=""

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .
# Без API_BASE_URL: на web используется Uri.base.origin — тот же хост, что и у SPA.
RUN flutter build web --release \
    --dart-define=AUTH_ENABLED=${AUTH_ENABLED} \
    --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
