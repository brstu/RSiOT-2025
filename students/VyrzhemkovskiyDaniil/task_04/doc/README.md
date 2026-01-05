# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br>
<p align="center"><strong>Лабораторная работа №4</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> "Мониторинг и observability в Kubernetes"</p>
<br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Выржемковский Д. И.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Вариант №2

**Параметры задания:**

- **Префикс метрик:** `app02_`
- **SLO доступность:** `99.5%`
- **P95 латенси:** `250ms`
- **Алерт по ошибкам:** `5xx > 1.5% за 10 минут`

---

## Установка системы мониторинга

### 1. Установка kube-prometheus-stack

```bash
# Добавить Helm репозиторий
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Создать namespace для мониторинга
kubectl create namespace monitoring

# Установить полный стек мониторинга
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword="admin123" \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false
```

### 2. Доступ к интерфейсам

```bash
# Получить доступ к Grafana (порт 3000)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Получить доступ к Prometheus (порт 9090)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Получить доступ к Alertmanager (порт 9093)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```

**Данные для входа в Grafana:**

- URL: <http://localhost:3000>
- Логин: `admin`
- Пароль: `admin123`

---

## Развертывание приложения

### 1. Создание namespace для приложения

```bash
# Создать namespace для приложения
kubectl apply -f 01-namespace.yaml
```

### 2. Установка приложения

```bash
# Запустить скрипт развертывания
chmod +x deploy-all.sh
./deploy-all.sh
```

Скрипт автоматически развернет:

- ServiceAccount для экспортера метрик
- ConfigMap с кодом экспортера метрик
- Deployment приложения с sidecar контейнером для метрик
- Service для доступа к приложению и метрикам
- ServiceMonitor для автоматического сбора метрик Prometheus
- PrometheusRules с алертами
- Grafana Dashboard

### 3. Проверка установки

```bash
# Проверить состояние подов
kubectl get pods -n app02-monitoring

# Проверить сервисы
kubectl get svc -n app02-monitoring

# Проверить ServiceMonitor
kubectl get servicemonitor -n app02-monitoring

# Проверить PrometheusRules
kubectl get prometheusrules -n app02-monitoring
```

---

## Описание приложения

### Метрики (префикс `app02_`)

Приложение экспортирует следующие метрики Prometheus:

1. **`app02_http_requests_total`** - счетчик HTTP запросов
   - Labels: `method`, `endpoint`, `status`
   - Тип: Counter

2. **`app02_http_request_duration_seconds`** - гистограмма времени выполнения
   - Labels: `method`, `endpoint`
   - Buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5]
   - Тип: Histogram

3. **`app02_http_requests_active`** - активные HTTP запросы
   - Тип: Gauge

4. **`app02_http_error_rate`** - текущий процент ошибок (5xx)
   - Тип: Gauge

5. **`app02_application_uptime_seconds`** - время работы приложения
   - Тип: Gauge

6. **`app02_application_info`** - информационная метрика
   - Labels: `name`, `student`, `group`, `variant`
   - Тип: Gauge

### Endpoints приложения

- **`GET /`** - главная страница с информацией о приложении и SLO
- **`GET /metrics`** - метрики в формате Prometheus (порт 8080)
- **`GET /health`** - health check для Kubernetes проб
- **`GET /api/v1/data`** - тестовый API endpoint
- **`GET /simulate-error`** - endpoint для симуляции ошибок 500

---

## Конфигурация мониторинга

### ServiceMonitor

```yaml
spec:
  selector:
    matchLabels:
      app: app02-webapp
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
    honorLabels: true
    params:
      prefix: ["app02_"]
```

### Prometheus Rules (Алерты)

Настроены четыре алерта согласно требованиям варианта:

1. **App02AvailabilityBelowSLO**
   - Условие: Доступность < 99.5% за 5 минут
   - Формула: `(1 - (rate(app02_http_requests_total{status=~"2.."}[5m]) / rate(app02_http_requests_total[5m]))) > 0.005`
   - Severity: warning
   - For: 5m

2. **App02HighLatency**
   - Условие: P95 латенси > 250ms
   - Формула: `histogram_quantile(0.95, rate(app02_http_request_duration_seconds_bucket[5m])) > 0.25`
   - Severity: warning
   - For: 3m

3. **App02HighErrorRate**
   - Условие: Ошибки 5xx > 1.5% за 10 минут
   - Формула: `(rate(app02_http_requests_total{status=~"5.."}[10m]) / rate(app02_http_requests_total[10m])) > 0.015`
   - Severity: critical
   - For: 5m

4. **App02MetricsMissing**
   - Условие: Нет метрик более 5 минут
   - Формула: `absent(app02_http_requests_total[5m])`
   - Severity: critical
   - For: 5m

---

## Дашборды Grafana

### Доступные дашборды

1. **App02 Monitoring Dashboard** - основной дашборд мониторинга
   - Статус доступности с цветовой индикацией по порогу 99.5%
   - График P95 латенси с порогом 250ms
   - График процента ошибок 5xx с порогом 1.5%
   - Количество HTTP запросов по методам и статусам
   - Активные соединения
   - Время работы приложения

### Импорт дашборда

Дашборд автоматически импортируется через ConfigMap с меткой `grafana_dashboard: "1"`. Prometheus Operator автоматически обнаруживает и импортирует дашборды с этой меткой.

Для ручного импорта через UI Grafana:

```bash
# Получить пароль Grafana
kubectl get secret -n monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

# Импортировать через UI Grafana:
# 1. Открыть http://localhost:3000
# 2. Нажать "Create" → "Import"
# 3. Вставить содержимое файла 10-grafana-dashboard.yaml (раздел data)
```

---

## Тестирование системы

### Нагрузочное тестирование

```bash
# Запустить тест нагрузки
kubectl apply -f 11-test-load.yaml

# Проверить логи теста
kubectl logs -n app02-monitoring job/app02-load-test
```

**Тест выполняет:**

- 1000 HTTP запросов к приложению
- Задержку 0.1 секунды между запросами
- Каждый 50-й запрос к API endpoint
- Каждый 20-й запрос симулирует ошибку (5% запросов)

### Проверка метрик

```bash
# Проверить экспорт метрик
kubectl port-forward -n app02-monitoring svc/app02-service 8080:8080
curl http://localhost:8080/metrics | grep app02_

# Проверить health endpoint
curl http://localhost:8080/health

# Проверить основную страницу
curl http://localhost:8080/
```

### Проверка алертов

```bash
# Запустить скрипт проверки метрик
kubectl apply -f 12-verify-metrics.yaml

# Проверить логи проверки
kubectl logs -n app02-monitoring job/app02-verify-metrics

# Проверить статус алертов в Prometheus
# Открыть http://localhost:9090/alerts

# Выполнить тестовые запросы в Prometheus:
# - rate(app02_http_requests_total[5m])
# - histogram_quantile(0.95, rate(app02_http_request_duration_seconds_bucket[5m]))
# - rate(app02_http_requests_total{status=~"5.."}[10m]) / rate(app02_http_requests_total[10m])
```

---

## Архитектура решения

```
┌─────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────┐        ┌─────────────────────┐     │
│  │   App02     │        │   kube-prometheus-  │     │
│  │ Deployment  │◄──────►│      stack          │     │
│  │             │ metrics│                     │     │
│  └─────────────┘        │  • Prometheus       │     │
│         │               │  • Grafana          │     │
│         ▼               │  • Alertmanager     │     │
│  ┌─────────────┐        │  • ServiceMonitors  │     │
│  │  Service    │        └─────────────────────┘     │
│  │ (app02-web) │                   │                │
│  └─────────────┘                   ▼                │
│                            ┌───────────────┐        │
│                            │   Alerts      │        │
│                            │  Dashboard    │        │
│                            └───────────────┘        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**Компоненты:**

1. **Приложение app02-webapp** - веб-приложение с экспортером метрик
2. **Service** - обеспечивает сетевой доступ к приложению
3. **ServiceMonitor** - автоматически настраивает Prometheus для сбора метрик
4. **PrometheusRules** - определяет алерты на основе SLO
5. **Grafana Dashboard** - визуализация метрик и алертов
6. **Alertmanager** - управление и отправка уведомлений

---

## Метаданные

Все ресурсы Kubernetes содержат необходимые метки:

```yaml
labels:
  student: vyrzhemkovskiy-daniil
  group: ac-63
  variant: 2
  prefix: app02_
```

Проверка метаданных:

```bash
# Проверить метки всех ресурсов
kubectl get all -n app02-monitoring --show-labels | grep -E "student|group|variant"

# Проверить метки конкретного ресурса
kubectl describe deployment app02-webapp -n app02-monitoring | grep -A5 "Labels:"
```

---

## Удаление

```bash
# Удалить приложение и все ресурсы
kubectl delete namespace app02-monitoring

# Удалить систему мониторинга
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring

# Очистить все файлы из проекта
kubectl delete -f . --recursive=true 2>/dev/null || true
```

## Вывод

Развернута полная система мониторинга для приложения согласно варианту №2. Приложение экспортирует метрики с префиксом `app02_`, настроены алерты по SLO:

- Доступность: 99.5%
- P95 латенси: 250ms
- Ошибки 5xx: не более 1.5% за 10 минут

Система включает все необходимые компоненты:

- **Prometheus** для сбора и хранения метрик
- **Grafana** для визуализации через автоматически импортируемый дашборд
- **Alertmanager** для управления уведомлениями
- **ServiceMonitor** для автоматического обнаружения метрик
- **PrometheusRules** для определения алертов на основе SLO
