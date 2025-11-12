FROM nginx:alpine

# Установка certbot и зависимостей
RUN apk add --no-cache \
    certbot \
    openssl \
    wget

# Копирование entrypoint скрипта
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Создание директорий
RUN mkdir -p /var/www/certbot

# Entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
