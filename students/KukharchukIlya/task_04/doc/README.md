# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №4</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> "Наблюдаемость и метрики"</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Кухарчук И.Н.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Метаданные студента

- ФИО: Кухарчук Илья Николаевич
- Группа: АС-63
- № студенческого (StudentID): 220017
- Email (учебный): as006314@g.bstu.by
- GitHub username: IlyaKukharchuk
- Вариант №: 13
- Дата выполнения: 13/11/2025
- ОС (версия), версия Docker Desktop/Engine: Windows 10 (10.0.19045), Docker Desktop / Engine (указать версию при наличии), kubectl (указать версию при наличии), Helm (указать версию при наличии)

---

## Параметры варианта 13

- **Префикс метрик**: `app13_`
- **SLO доступности**: 99.0%
- **SLO задержки (p95)**: 300ms
- **Алерт по ошибкам**: 5xx > 2% за 10 минут

---

## Цель работы

- Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes
- Добавить экспонирование метрик в приложение (endpoint `/metrics`) с использованием client-библиотек Prometheus
- Создать ServiceMonitor/PodMonitor для автоматического сбора метрик
- Разработать дашборды в Grafana для визуализации ключевых метрик (доступность, задержка, ошибки)
- Настроить алерты по SLO (Service Level Objectives) с использованием PrometheusRule и Alertmanager
- Упаковать приложение в Helm-чарт с параметризацией основных настроек

---

## Архитектура мониторинга

```
┌─────────────────────────────────────────────────────────────┐
│                  Namespace: monitoring                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │  Prometheus  │    │   Grafana    │    │ Alertmanager │ │
│  │  (Operator)  │    │              │    │              │ │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘ │
│         │                   │                    │         │
│         └───────────────────┴────────────────────┘         │
│                            │                               │
└────────────────────────────┼───────────────────────────────┘
                             │
┌────────────────────────────┼───────────────────────────────┐
│                  Namespace: app-as-63-220017-v13          │
├────────────────────────────┼───────────────────────────────┤
│                            │                               │
│  ┌──────────────┐    ┌─────▼──────────┐                  │
│  │  Application │    │ ServiceMonitor │                  │
│  │  /metrics    │◄───┤  (Discovery)    │                  │
│  └──────────────┘    └─────────────────┘                  │
│                                                           │
│  ┌──────────────┐    ┌─────────────────┐                 │
│  │ PrometheusRule│    │   Helm Chart    │                 │
│  │  (Alerts)    │    │  (Deployment)   │                 │
│  └──────────────┘    └─────────────────┘                 │
└───────────────────────────────────────────────────────────┘
```

### Компоненты системы мониторинга

1. **Prometheus** - сбор и хранение метрик
2. **Grafana** - визуализация метрик через дашборды
3. **Alertmanager** - управление и роутинг алертов
4. **ServiceMonitor** - автоматическое обнаружение метрик приложения
5. **PrometheusRule** - правила алертов по SLO

---

## Ход выполнения работы

### 1. Установка kube-prometheus-stack

#### 1.1 Добавление Helm репозитория

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

#### 1.2 Создание namespace для мониторинга

```bash
kubectl create namespace monitoring
```

#### 1.3 Установка kube-prometheus-stack

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
```

#### 1.4 Проверка установки

```bash
# Проверить поды
kubectl get pods -n monitoring

# Проверить сервисы
kubectl get svc -n monitoring

# Доступ к Grafana (port-forward)
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Grafana будет доступна по адресу: http://localhost:3000

- Логин по умолчанию: `admin`
- Пароль: получить командой `kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d`

---

### 2. Деплой приложения через Helm

#### 2.1 Установка Helm-чарта

```bash
cd helm/app13
helm install app13-app . \
  --namespace app-as-63-220017-v13 \
  --create-namespace \
  --set metrics.prefix=app13_ \
  --set app.port=8061 \
  --set app.replicas=2
```

#### 2.2 Проверка деплоя

```bash
# Проверить поды
kubectl get pods -n app-as-63-220017-v13

# Проверить сервисы
kubectl get svc -n app-as-63-220017-v13

# Проверить метрики
kubectl port-forward -n app-as-63-220017-v13 svc/app13-app 8061:8061
curl http://localhost:8061/metrics
```

---

### 3. Настройка ServiceMonitor

ServiceMonitor автоматически создается при установке Helm-чарта. Он настроен на сбор метрик с endpoint `/metrics` приложения.

Проверка ServiceMonitor:

```bash
kubectl get servicemonitor -n app-as-63-220017-v13
kubectl describe servicemonitor app13-app -n app-as-63-220017-v13
```

---

### 4. Проверка метрик в Prometheus

#### 4.1 Доступ к Prometheus

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
```

Prometheus будет доступен по адресу: http://localhost:9090

#### 4.2 Проверка метрик

В Prometheus UI выполните запросы:

```promql
# Общее количество запросов
app13_http_requests_total

# Задержка p95
histogram_quantile(0.95, rate(app13_http_request_duration_seconds_bucket[5m]))

# Частота ошибок 5xx
rate(app13_http_requests_total{status=~"5.."}[5m]) / rate(app13_http_requests_total[5m])
```

---

### 5. Создание дашбордов в Grafana

#### 5.1 Дашборд "Доступность сервиса"

**Метрика**: `avg_over_time(up{job="app13-app"}[5m]) * 100`

**Панель**: Single Stat

- Показывает процент доступности сервиса
- Порог: 99.0% (SLO)

#### 5.2 Дашборд "Задержка p95/p99"

**Метрики**:

- p95: `histogram_quantile(0.95, rate(app13_http_request_duration_seconds_bucket[5m]))`
- p99: `histogram_quantile(0.99, rate(app13_http_request_duration_seconds_bucket[5m]))`

**Панель**: Graph

- Показывает задержку в миллисекундах
- Порог: p95 < 300ms (SLO)

#### 5.3 Дашборд "Частота ошибок 5xx"

**Метрика**: `rate(app13_http_requests_total{status=~"5.."}[5m]) / rate(app13_http_requests_total[5m]) * 100`

**Панель**: Graph

- Показывает процент ошибок 5xx
- Порог: < 2% за 10 минут

#### 5.4 Импорт дашбордов

Дашборды можно импортировать из файлов в директории `grafana/`:

- `availability-dashboard.json`
- `latency-dashboard.json`
- `errors-dashboard.json`

---

### 6. Настройка алертов (PrometheusRule)

PrometheusRule автоматически создается при установке Helm-чарта. Он содержит следующие алерты:

1. **app13_availability_slo** - доступность ниже 99.0%
2. **app13_latency_p95_slo** - p95 задержка выше 300ms
3. **app13_error_rate_5xx** - частота ошибок 5xx выше 2% за 10 минут

#### 6.1 Проверка алертов

```bash
# Проверить PrometheusRule
kubectl get prometheusrule -n app-as-63-220017-v13
kubectl describe prometheusrule app13-alerts -n app-as-63-220017-v13

# Проверить алерты в Prometheus UI
# Перейти в раздел Alerts: http://localhost:9090/alerts
```

#### 6.2 Тестирование алертов

Для тестирования можно создать нагрузку на приложение:

```bash
# Установить hey (HTTP load testing tool)
# Для Windows: choco install hey
# Для Linux/Mac: go install github.com/rakyll/hey@latest

# Создать нагрузку
hey -n 10000 -c 10 http://localhost:8061/
```

---

### 7. Описание метрик

Приложение экспонирует следующие метрики с префиксом `app13_`:

#### 7.1 Счётчик запросов

```
app13_http_requests_total{method="GET",status="200"}
```

- Тип: Counter
- Описание: Общее количество HTTP запросов
- Метки: method, status

#### 7.2 Гистограмма задержек

```
app13_http_request_duration_seconds_bucket{method="GET",le="0.005"}
```

- Тип: Histogram
- Описание: Распределение времени обработки запросов
- Метки: method
- Ведра: 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10

#### 7.3 Gauge активных соединений

```
app13_active_connections
```

- Тип: Gauge
- Описание: Текущее количество активных соединений

---

## Структура Helm-чарта

```
helm/app13/
├── Chart.yaml          # Метаданные чарта
├── values.yaml         # Значения по умолчанию
└── templates/
    ├── deployment.yaml  # Deployment приложения
    ├── service.yaml    # Service для приложения
    ├── ingress.yaml    # Ingress (опционально)
    ├── servicemonitor.yaml  # ServiceMonitor для Prometheus
    └── prometheusrule.yaml  # PrometheusRule с алертами
```

---

## Критерии оценивания

| Критерий                                                           | Баллы | Статус |
| ------------------------------------------------------------------ | ----- | ------ |
| Установка и настройка kube-prometheus-stack                        | 15    | ✅     |
| Интеграция метрик в приложение (endpoint /metrics, prefix app13\_) | 20    | ✅     |
| Настройка ServiceMonitor для автоматического сбора метрик          | 15    | ✅     |
| Создание дашбордов в Grafana (2-3 дашборда)                        | 15    | ✅     |
| Настройка алертов по SLO (PrometheusRule)                          | 15    | ✅     |
| Helm-чарт приложения с корректной параметризацией                  | 15    | ✅     |
| Метаданные, именование, оформление README                          | 5     | ✅     |

---

## Вывод

Развернута система мониторинга на базе Prometheus и Grafana. Приложение интегрировано с системой мониторинга через метрики с префиксом `app13_`. Настроены дашборды для визуализации доступности, задержки и ошибок. Созданы алерты по SLO: доступность 99.0%, p95 задержка 300ms, частота ошибок 5xx < 2% за 10 минут. Приложение упаковано в Helm-чарт с полной параметризацией. Все компоненты работают корректно.
