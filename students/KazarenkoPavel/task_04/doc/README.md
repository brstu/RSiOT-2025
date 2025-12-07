# Лабораторная работа №4: Мониторинг и Helm

## Метаданные студента

- **ФИО:** Казаренко Павел Владимирович
- **Группа:** АС-63
- **StudentID:** 220008
- **Email:** as006305@g.bstu.by
- **GitHub:** Catsker
- **Вариант:** 05
- **Дата:** 27.10.2024

## Вариант 5

- **Префикс метрик:** `app05_`
- **SLO:** 99.5%
- **P95 Latency:** ≤300ms
- **Alert условие:** 5xx > 2% за 15 минут

## 1. Установка мониторинга

```bash
# Добавление репозитория Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Установка kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# Проверка установки
kubectl get pods -n monitoring
```

## 2. Сборка и деплой приложения

### Сборка Docker образа

```bash
docker build -t web05:stu-220008-v05 -f Dockerfile .
```

### Установка Helm чарта

```bash
# Создание namespace
kubectl create namespace app05

# Установка чарта
helm install web05 ./helm/web05 -n app05

# Проверка
helm list -n app05
kubectl get all -n app05
```

## 3. Проверка метрик

```bash
# Port forwarding для Prometheus
kubectl port-forward -n monitoring svc/monitoring-prometheus 9090:9090

# Port forwarding для Grafana
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80

# Проверка метрик в браузере
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)

# Проверка метрик приложения
curl http://web05-service.app05.svc.cluster.local:8091/metrics
```

## 4. Дашборды Grafana

Импортируйте дашборд из файла `grafana-dashboards/web05-dashboard.json`:

1. Откройте Grafana (http://localhost:3000)
2. Навигация → Dashboards → Import 
3. Загрузите JSON файл 
4. Выберите Prometheus как источник данных

Метрики на дашборде:

- Request Rate (запросы в секунду)
- Error Rate (% ошибок 4xx/5xx)
- P95 Latency (время ответа)
- SLO Compliance (соответствие 99.5%)

## 5. Алерты

Настроены 2 алерта:

### 1. HighErrorRate

- Условие: Error rate > 2% за 15 минут
- Серьезность: critical
- Проверка: app05_http_errors_total / app05_http_requests_total * 100 > 2

### 2. HighLatency

- Условие: P95 latency > 300ms за 5 минут
- Серьезность: warning
- Проверка: histogram_quantile(0.95, rate(app05_http_request_duration_seconds_bucket[5m])) > 0.3

## 6. Структура Helm чарта

```text
helm/web05/
├── Chart.yaml          # Метаданные чарта
├── values.yaml         # Параметры для варианта 5
└── templates/
    ├── deployment.yaml     # Deployment с метриками
    ├── service.yaml        # Service
    ├── servicemonitor.yaml # ServiceMonitor для Prometheus
    └── prometheusrule.yaml # Правила алертов
```

## 7. Тестирование

### Генерация нагрузки для тестирования алертов

```bash
# Тестирование latency (должен сработать alert >300ms)
for i in {1..100}; do
  curl "http://localhost:8091/slow?delay=0.4"
done

# Тестирование ошибок (должен сработать alert >2%)
for i in {1..50}; do
  curl "http://localhost:8091/error?code=500"
done
```

## 8. Архитектура мониторинга

```text
┌─────────────────┐    метрики    ┌──────────────┐
│   Flask App     │───────────────▶│  Prometheus  │
│   (app05_*)     │               │              │
└─────────────────┘               └──────┬───────┘
                                         │
                                    ┌────▼──────┐
                                    │  Alerts   │
                                    │ (2% 5xx)  │
                                    └────┬──────┘
                                         │
                                    ┌────▼──────┐
                                    │  Grafana  │
                                    │ Dashboard │
                                    └───────────┘
```

## 9. Очистка

```bash
# Удаление Helm релиза
helm uninstall web05 -n app05

# Удаление мониторинга
helm uninstall monitoring -n monitoring

# Удаление namespace
kubectl delete namespace app05 monitoring
```
