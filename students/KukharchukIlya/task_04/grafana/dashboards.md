# Описание дашбордов Grafana

## Дашборд 1: Доступность сервиса (Availability)

### Панель 1: Процент доступности (Single Stat)

**Запрос PromQL:**

```promql
avg_over_time(up{job="app13-app", namespace="app-as-63-220017-v13"}[5m]) * 100
```

**Настройки:**

- Тип: Single Stat
- Единицы измерения: Percent (0-100)
- Пороги:
  - Красный: < 99.0%
  - Желтый: 99.0% - 99.5%
  - Зеленый: > 99.5%
- Заголовок: "Доступность сервиса"

### Панель 2: График доступности (Graph)

**Запрос PromQL:**

```promql
avg_over_time(up{job="app13-app", namespace="app-as-63-220017-v13"}[1m]) * 100
```

**Настройки:**

- Тип: Graph
- Легенда: {{job}}
- Y-axis: 0-100 (Percent)
- Заголовок: "Доступность сервиса (история)"

---

## Дашборд 2: Задержка (Latency)

### Панель 1: p95 задержка (Single Stat)

**Запрос PromQL:**

```promql
histogram_quantile(0.95,
  rate(app13_http_request_duration_seconds_bucket{job="app13-app", namespace="app-as-63-220017-v13"}[5m])
) * 1000
```

**Настройки:**

- Тип: Single Stat
- Единицы измерения: milliseconds (ms)
- Пороги:
  - Красный: > 300ms
  - Желтый: 200ms - 300ms
  - Зеленый: < 200ms
- Заголовок: "p95 Задержка"

### Панель 2: p99 задержка (Single Stat)

**Запрос PromQL:**

```promql
histogram_quantile(0.99,
  rate(app13_http_request_duration_seconds_bucket{job="app13-app", namespace="app-as-63-220017-v13"}[5m])
) * 1000
```

**Настройки:**

- Тип: Single Stat
- Единицы измерения: milliseconds (ms)
- Заголовок: "p99 Задержка"

### Панель 3: График задержек p50, p95, p99 (Graph)

**Запросы PromQL:**

```promql
# p50
histogram_quantile(0.50,
  rate(app13_http_request_duration_seconds_bucket{job="app13-app", namespace="app-as-63-220017-v13"}[5m])
) * 1000

# p95
histogram_quantile(0.95,
  rate(app13_http_request_duration_seconds_bucket{job="app13-app", namespace="app-as-63-220017-v13"}[5m])
) * 1000

# p99
histogram_quantile(0.99,
  rate(app13_http_request_duration_seconds_bucket{job="app13-app", namespace="app-as-63-220017-v13"}[5m])
) * 1000
```

**Настройки:**

- Тип: Graph
- Легенда: p50, p95, p99
- Y-axis: milliseconds (ms)
- Линия порога: 300ms (красная пунктирная)
- Заголовок: "Распределение задержек (p50, p95, p99)"

---

## Дашборд 3: Частота ошибок 5xx

### Панель 1: Процент ошибок 5xx (Single Stat)

**Запрос PromQL:**

```promql
(
  sum(rate(app13_http_requests_total{job="app13-app", namespace="app-as-63-220017-v13", status=~"5.."}[10m]))
  /
  sum(rate(app13_http_requests_total{job="app13-app", namespace="app-as-63-220017-v13"}[10m]))
  * 100
)
```

**Настройки:**

- Тип: Single Stat
- Единицы измерения: Percent (0-100)
- Пороги:
  - Красный: > 2%
  - Желтый: 1% - 2%
  - Зеленый: < 1%
- Заголовок: "Частота ошибок 5xx (за 10 минут)"

### Панель 2: График частоты ошибок 5xx (Graph)

**Запрос PromQL:**

```promql
(
  sum(rate(app13_http_requests_total{job="app13-app", namespace="app-as-63-220017-v13", status=~"5.."}[5m]))
  /
  sum(rate(app13_http_requests_total{job="app13-app", namespace="app-as-63-220017-v13"}[5m]))
  * 100
)
```

**Настройки:**

- Тип: Graph
- Легенда: Error Rate 5xx
- Y-axis: 0-10 (Percent)
- Линия порога: 2% (красная пунктирная)
- Заголовок: "Частота ошибок 5xx (история)"

### Панель 3: Количество ошибок по статусам (Graph)

**Запрос PromQL:**

```promql
sum(rate(app13_http_requests_total{job="app13-app", namespace="app-as-63-220017-v13", status=~"5.."}[5m])) by (status)
```

**Настройки:**

- Тип: Graph
- Легенда: {{status}}
- Y-axis: requests/second
- Заголовок: "Количество ошибок по статусам"

---

## Дашборд 4: Общий обзор (Overview)

### Панель 1: Общее количество запросов (Graph)

**Запрос PromQL:**

```promql
sum(rate(app13_http_requests_total{job="app13-app", namespace="app-as-63-220017-v13"}[5m])) by (method, status)
```

**Настройки:**

- Тип: Graph
- Легенда: {{method}} - {{status}}
- Y-axis: requests/second
- Заголовок: "RPS по методам и статусам"

### Панель 2: Активные соединения (Gauge)

**Запрос PromQL:**

```promql
app13_active_connections{job="app13-app", namespace="app-as-63-220017-v13"}
```

**Настройки:**

- Тип: Gauge
- Единицы измерения: connections
- Min: 0
- Max: 1000
- Заголовок: "Активные соединения"

### Панель 3: Распределение времени ответа (Heatmap)

**Запрос PromQL:**

```promql
sum(rate(app13_http_request_duration_seconds_bucket{job="app13-app", namespace="app-as-63-220017-v13"}[5m])) by (le)
```

**Настройки:**

- Тип: Heatmap
- Format: Heatmap
- Data source: Prometheus
- Заголовок: "Распределение времени ответа"

---

## Инструкция по импорту дашбордов

1. Войдите в Grafana (http://localhost:3000)
2. Перейдите в раздел Dashboards → Import
3. Выберите один из вариантов:
   - **Вариант 1**: Создать дашборд вручную, используя описание выше
   - **Вариант 2**: Использовать JSON экспорт (если доступен)
4. Настройте Data Source: выберите Prometheus
5. Сохраните дашборд

---

## PromQL запросы для тестирования

### Проверка метрик в Prometheus UI

1. **Общее количество запросов:**

```promql
app13_http_requests_total
```

2. **RPS (Requests Per Second):**

```promql
rate(app13_http_requests_total[5m])
```

3. **Задержка p95:**

```promql
histogram_quantile(0.95, rate(app13_http_request_duration_seconds_bucket[5m])) * 1000
```

4. **Частота ошибок 5xx:**

```promql
sum(rate(app13_http_requests_total{status=~"5.."}[10m])) / sum(rate(app13_http_requests_total[10m])) * 100
```

5. **Доступность:**

```promql
avg_over_time(up{job="app13-app"}[5m]) * 100
```
