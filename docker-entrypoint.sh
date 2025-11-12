#!/bin/sh

set -e

# Конфигурация
DOMAIN="ksavelyev.ru"
EMAIL="i@ksavelyev.ru"
CERTBOT_DIR="/etc/letsencrypt"
CERT_PATH="${CERTBOT_DIR}/live/${DOMAIN}"

echo "=== Проверка SSL сертификатов для ${DOMAIN} ==="

# Проверка наличия сертификатов
if [ -f "${CERT_PATH}/fullchain.pem" ]; then
    echo "✓ Сертификаты найдены для ${DOMAIN}"
    echo "=== Запуск nginx ==="
    exec nginx -g "daemon off;"
fi

echo "! Сертификаты не найдены. Запуск автоматической инициализации..."

# Создание директорий
mkdir -p /var/www/certbot
mkdir -p ${CERTBOT_DIR}

# Проверка наличия рекомендуемых параметров TLS
if [ ! -f "${CERTBOT_DIR}/options-ssl-nginx.conf" ]; then
    echo "→ Загрузка рекомендуемых параметров TLS..."
    wget -q https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf \
        -O ${CERTBOT_DIR}/options-ssl-nginx.conf || echo "Предупреждение: не удалось загрузить options-ssl-nginx.conf"
fi

if [ ! -f "${CERTBOT_DIR}/ssl-dhparams.pem" ]; then
    echo "→ Загрузка DH параметров..."
    wget -q https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem \
        -O ${CERTBOT_DIR}/ssl-dhparams.pem || echo "Предупреждение: не удалось загрузить ssl-dhparams.pem"
fi

# Создание временного самоподписанного сертификата
echo "→ Создание временного самоподписанного сертификата..."
mkdir -p ${CERT_PATH}
openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
    -keyout "${CERT_PATH}/privkey.pem" \
    -out "${CERT_PATH}/fullchain.pem" \
    -subj "/CN=${DOMAIN}" 2>/dev/null

# Запуск nginx в фоне для получения сертификата
echo "→ Запуск nginx для валидации домена..."
nginx

# Ожидание запуска nginx
sleep 5

# Удаление временного сертификата
echo "→ Удаление временного сертификата..."
rm -rf ${CERT_PATH}
rm -rf ${CERTBOT_DIR}/archive/${DOMAIN}
rm -rf ${CERTBOT_DIR}/renewal/${DOMAIN}.conf

# Получение настоящего сертификата
echo "→ Запрос SSL сертификата от Let's Encrypt..."
echo "  Домен: ${DOMAIN}"
echo "  Email: ${EMAIL}"

certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email ${EMAIL} \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    --non-interactive \
    -d ${DOMAIN} \
    -d www.${DOMAIN} || {
        echo "! Ошибка получения сертификата"
        echo "! Проверьте DNS настройки для ${DOMAIN}"
        echo "! Продолжаю работу с самоподписанным сертификатом..."

        # Создаем самоподписанный сертификат на 90 дней
        mkdir -p ${CERT_PATH}
        openssl req -x509 -nodes -newkey rsa:2048 -days 90 \
            -keyout "${CERT_PATH}/privkey.pem" \
            -out "${CERT_PATH}/fullchain.pem" \
            -subj "/CN=${DOMAIN}" 2>/dev/null
    }

# Перезагрузка nginx с новыми сертификатами
echo "→ Перезагрузка nginx..."
nginx -s reload

echo "✓ Инициализация завершена"

# Запуск фонового процесса для автообновления сертификатов
(
    while :; do
        sleep 12h
        echo "→ Проверка обновления сертификатов..."
        certbot renew --quiet --deploy-hook "nginx -s reload"
    done
) &

# Запуск фонового процесса для периодической перезагрузки nginx
(
    while :; do
        sleep 6h
        echo "→ Перезагрузка nginx..."
        nginx -s reload
    done
) &

echo "=== Nginx работает ==="
echo "→ Автообновление сертификатов: каждые 12 часов"
echo "→ Перезагрузка nginx: каждые 6 часов"

# Ожидание завершения процесса nginx
wait
