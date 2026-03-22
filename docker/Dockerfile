# Flutter Web → статика в nginx (один origin с API через Traefik).
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .
# Без API_BASE_URL: на web используется Uri.base.origin — тот же хост, что и у SPA.
RUN flutter build web --release

FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
