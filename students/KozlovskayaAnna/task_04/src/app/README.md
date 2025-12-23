# Monitoring App - Variant 8

Flask приложение с интеграцией Prometheus метрик для лабораторной работы 04.

## Метрики с префиксом app08_

- `app08_http_requests_total` - счётчик всех HTTP запросов
- `app08_http_request_duration_seconds` - гистограмма задержек запросов
- `app08_http_requests_in_progress` - gauge активных запросов
- `app08_http_errors_5xx_total` - счётчик ошибок 5xx
- `app08_http_errors_4xx_total` - счётчик ошибок 4xx
- `app08_health_status` - gauge статуса здоровья приложения
- `app08_app_info` - информация о приложении

## Endpoints

- `/` - главная страница
- `/health` - health check
- `/ready` - readiness check
- `/metrics` - Prometheus метрики
- `/api/data` - пример API endpoint
- `/api/slow` - медленный endpoint (для тестирования latency)
- `/api/error` - endpoint с ошибками (для тестирования алертов)

## Локальный запуск

```bash
pip install -r requirements.txt
python app.py
```

## Docker

```bash
docker build -t monitoring-app:v1 .
docker run -p 8080:8080 monitoring-app:v1
```

## Проверка метрик

```bash
curl http://localhost:8080/metrics
```
