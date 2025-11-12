# CV - Константин Савельев

Резюме с премиальным дизайном на HTML/CSS.

## Запуск с Docker

### Быстрый старт

```bash
docker-compose up -d
```

Резюме будет доступно по адресу:
- http://localhost (дефолтный сервер)
- http://ksavelyev.ru (при соответствующей настройке DNS)

### Остановка

```bash
docker-compose down
```

### Перезапуск после изменений

```bash
docker-compose restart
```

## Структура проекта

```
cv/
├── index.html              # Основной HTML файл
├── styles.css              # Стили
├── me.jpg                  # Фото профиля
├── docker-compose.yml      # Docker Compose конфигурация
├── nginx/
│   └── conf.d/
│       └── default.conf    # Nginx конфигурация
└── README.md               # Документация
```

## Технологии

- HTML5
- CSS3 (с CSS Variables)
- Font Awesome
- Google Fonts (Playfair Display, Lato)
- Nginx (Alpine)
- Docker Compose

## Особенности дизайна

- Адаптивная верстка
- Плавные анимации при скролле
- Цветовое кодирование технологий по категориям
- Hover эффекты
- Градиенты и тени
- Иконки Font Awesome

## Разработка

Для локальной разработки можно использовать любой веб-сервер, например:

```bash
python -m http.server 8000
```

Или открыть index.html напрямую в браузере.
