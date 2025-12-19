# Лабораторная работа №04

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №04</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> "Наблюдаемость и метрики"</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Козловская Анна Геннадьевна</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавлять экспонирование метрик в приложение с использованием client-библиотек Prometheus, создавать ServiceMonitor/PodMonitor для автоматического сбора метрик, разрабатывать дашборды в Grafana для визуализации ключевых метрик (доступность, задержка, ошибки), настраивать алерты по SLO с использованием PrometheusRule и Alertmanager, упаковывать приложение в Helm-чарт с параметризацией основных настроек, а также настроить GitOps-синхронизацию с использованием Argo CD.

---

### Вариант №8

**Параметры варианта:**

- Префикс метрик: `app08_`
- SLO доступности: `99.5%`
- SLO задержки P95: `350ms`
- Алерт: `5xx > 2.5% за 15 минут`

## Метаданные студента

- **ФИО:** Козловская Анна Геннадьевна
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220012
- **Email (учебный):** <AS006309@g.bstu.by>
- **GitHub username:** annkrq
- **Вариант №:** 8
- **Дата выполнения:** 19 декабря 2025 г.
- **ОС и версия:** Windows 11 Pro 23H2
- **Версия Docker Desktop:** 4.35.1
- **Версия kubectl:** 1.31.0
- **Версия Helm:** 3.16.0
- **Версия Minikube:** 1.34.0

---

## Окружение и инструменты

Для выполнения лабораторной работы использовались следующие инструменты и технологии:

### Инфраструктура

- **Kubernetes:** Оркестрация контейнеров (Minikube/Kind)
- **Docker:** Контейнеризация приложения
- **Helm:** Пакетный менеджер для Kubernetes

### Мониторинг

- **kube-prometheus-stack:** Полный стек мониторинга (Prometheus Operator, Grafana, Alertmanager)
- **Prometheus:** Система мониторинга и базы данных временных рядов
- **Grafana:** Платформа визуализации и аналитики
- **Alertmanager:** Управление алертами

### Приложение

- **Python 3.11:** Язык программирования
- **Flask 3.0:** Web-фреймворк
- **prometheus-client 0.19:** Клиентская библиотека Prometheus для Python
- **gunicorn 21.2:** WSGI HTTP сервер

### GitOps (дополнительно)

- **Argo CD:** Continuous Delivery для Kubernetes

---

## Структура репозитория

```
task_04/
├── doc/
│   ├── README.md                          # Основной отчет (данный файл)
│   └── screenshots/                       # Скриншоты выполнения
│       ├── 01-prometheus-ui.png
│       ├── 02-grafana-ui.png
│       ├── 03-alertmanager-ui.png
│       ├── 04-metrics-endpoint.png
│       ├── 05-servicemonitor.png
│       ├── 06-prometheusrule.png
│       ├── 07-dashboard-availability.png
│       ├── 08-dashboard-latency.png
│       ├── 09-dashboard-errors.png
│       ├── 10-alert-firing.png
│       └── 11-argocd-sync.png
│
└── src/
    ├── app/                               # Исходный код приложения
    │   ├── app.py                         # Flask приложение с метриками
    │   ├── requirements.txt               # Python зависимости
    │   ├── Dockerfile                     # Multi-stage Dockerfile
    │   └── README.md                      # Документация приложения
    │
    ├── helm/                              # Helm чарт
    │   ├── Chart.yaml                     # Метаданные чарта
    │   ├── values.yaml                    # Значения по умолчанию
    │   └── templates/                     # Kubernetes манифесты
    │       ├── _helpers.tpl
    │       ├── namespace.yaml
    │       ├── serviceaccount.yaml
    │       ├── deployment.yaml
    │       ├── service.yaml
    │       ├── ingress.yaml
    │       ├── servicemonitor.yaml        # ServiceMonitor для Prometheus
    │       ├── prometheusrule.yaml        # PrometheusRule с алертами
    │       ├── hpa.yaml
    │       └── NOTES.txt
    │
    ├── k8s/                               # Дополнительные манифесты (если нужны)
    │
    ├── grafana-dashboards/                # JSON дашборды Grafana
    │   ├── availability-dashboard.json    # Дашборд доступности
    │   ├── latency-dashboard.json         # Дашборд задержек
    │   └── errors-dashboard.json          # Дашборд ошибок
    │
    ├── argocd/                            # GitOps конфигурация
    │   ├── application.yaml               # Argo CD Application
    │   └── README.md                      # Инструкции по GitOps
    │
    └── scripts/                           # Скрипты автоматизации
        ├── install-monitoring.sh          # Установка kube-prometheus-stack
        ├── install-monitoring.ps1         # (Windows PowerShell версия)
        ├── deploy-app.sh                  # Деплой приложения через Helm
        ├── deploy-app.ps1                 # (Windows PowerShell версия)
        ├── install-argocd.sh              # Установка Argo CD
        ├── install-argocd.ps1             # (Windows PowerShell версия)
        └── load-test.sh                   # Скрипт генерации нагрузки
```

---

## Подробное описание выполнения

### 1. Установка системы мониторинга (kube-prometheus-stack)

#### 1.1. Подготовка кластера Kubernetes

Для работы использовался локальный Kubernetes кластер на базе Minikube:

```bash
# Запуск Minikube с достаточными ресурсами
minikube start --cpus=4 --memory=8192 --driver=docker

# Проверка статуса кластера
kubectl cluster-info
kubectl get nodes
```

#### 1.2. Установка kube-prometheus-stack через Helm

Выполнена установка полного стека мониторинга с помощью скрипта:

```bash
cd src/scripts
./install-monitoring.sh  # Linux/macOS
# или
.\install-monitoring.ps1  # Windows PowerShell
```

Скрипт выполняет следующие действия:

1. Добавляет Helm репозиторий `prometheus-community`
2. Создает namespace `monitoring`
3. Устанавливает kube-prometheus-stack с необходимыми параметрами:
   - `serviceMonitorSelectorNilUsesHelmValues=false` - разрешает обнаружение всех ServiceMonitor
   - `podMonitorSelectorNilUsesHelmValues=false` - разрешает обнаружение всех PodMonitor
   - `ruleSelectorNilUsesHelmValues=false` - разрешает загрузку всех PrometheusRule
   - `retention=7d` - хранение метрик 7 дней
   - `grafana.adminPassword=admin` - пароль администратора Grafana

#### 1.3. Проверка установки компонентов

```bash
# Проверка подов в namespace monitoring
kubectl get pods -n monitoring

# Проверка сервисов
kubectl get svc -n monitoring

# Проверка CRD (Custom Resource Definitions)
kubectl get servicemonitor -n monitoring
kubectl get prometheusrule -n monitoring
```

#### 1.4. Доступ к компонентам мониторинга

**Prometheus:**

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

URL: <http://localhost:9090>

![Prometheus UI](./screenshots/01-prometheus-ui.png)

**Grafana:**

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

URL: <http://localhost:3000>  
Логин: `admin` / Пароль: `admin`

![Grafana UI](./screenshots/02-grafana-ui.png)

**Alertmanager:**

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```

URL: <http://localhost:9093>

![Alertmanager UI](./screenshots/03-alertmanager-ui.png)

---

### 2. Добавление метрик в приложение

#### 2.1. Разработка Flask приложения с Prometheus метриками

Создано Flask приложение с интеграцией клиентской библиотеки Prometheus.

**Основные компоненты приложения:**

- **Endpoints:**
  - `/` - главная страница с информацией о приложении
  - `/health` - health check
  - `/ready` - readiness check
  - `/metrics` - endpoint с метриками Prometheus
  - `/api/data` - пример API endpoint
  - `/api/slow` - медленный endpoint для тестирования latency
  - `/api/error` - endpoint с возможными ошибками 5xx

- **Метрики с префиксом app08_:**
  - `app08_http_requests_total` (Counter) - счётчик всех HTTP запросов по методам, endpoints и статус-кодам
  - `app08_http_request_duration_seconds` (Histogram) - гистограмма задержек запросов с buckets от 5ms до 10s
  - `app08_http_requests_in_progress` (Gauge) - количество активных запросов
  - `app08_http_errors_5xx_total` (Counter) - счётчик ошибок 5xx
  - `app08_http_errors_4xx_total` (Counter) - счётчик ошибок 4xx
  - `app08_health_status` (Gauge) - статус здоровья приложения (0/1)
  - `app08_app_info` (Gauge) - информация о приложении с labels (version, student_id, group, variant)

**Ключевые фрагменты кода:**

```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest

# Определение метрик с префиксом app08_
http_requests_total = Counter(
    'app08_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'app08_http_request_duration_seconds',
    'HTTP request latency in seconds',
    ['method', 'endpoint'],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.35, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0)
)

# Автоматический сбор метрик через middleware
@app.before_request
def before_request():
    request.start_time = time.time()
    http_requests_in_progress.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).inc()

@app.after_request
def after_request(response):
    if hasattr(request, 'start_time'):
        request_latency = time.time() - request.start_time
        endpoint = request.endpoint or 'unknown'
        
        http_request_duration_seconds.labels(
            method=request.method,
            endpoint=endpoint
        ).observe(request_latency)
        
        http_requests_total.labels(
            method=request.method,
            endpoint=endpoint,
            status=response.status_code
        ).inc()
        
        if 500 <= response.status_code < 600:
            http_errors_5xx_total.labels(
                method=request.method,
                endpoint=endpoint
            ).inc()
```

#### 2.2. Создание Dockerfile

Разработан multi-stage Dockerfile с полными метаданными студента:

```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Метаданные студента (labels)
LABEL org.bstu.student.fullname="Козловская Анна Геннадьевна" \
      org.bstu.student.id="220012" \
      org.bstu.group="АС-63" \
      org.bstu.variant="8" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="annkrq" \
      org.bstu.student.slug="as63-220012-v8"

# Копирование зависимостей из builder
COPY --from=builder /root/.local /root/.local
COPY app.py .

# Создание non-root пользователя
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Запуск через gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
```

#### 2.3. Сборка и тестирование образа

```bash
cd src/app

# Сборка образа
docker build -t monitoring-app:1.0.0 .

# Локальный запуск для тестирования
docker run -p 8080:8080 monitoring-app:1.0.0

# Проверка метрик
curl http://localhost:8080/metrics
```

![Metrics Endpoint](./screenshots/04-metrics-endpoint.png)

Пример вывода метрик:

```
# HELP app08_http_requests_total Total HTTP requests
# TYPE app08_http_requests_total counter
app08_http_requests_total{endpoint="index",method="GET",status="200"} 15.0
app08_http_requests_total{endpoint="api_data",method="GET",status="200"} 42.0

# HELP app08_http_request_duration_seconds HTTP request latency in seconds
# TYPE app08_http_request_duration_seconds histogram
app08_http_request_duration_seconds_bucket{endpoint="index",le="0.005",method="GET"} 10.0
app08_http_request_duration_seconds_bucket{endpoint="index",le="0.01",method="GET"} 15.0
app08_http_request_duration_seconds_sum{endpoint="index",method="GET"} 0.089
app08_http_request_duration_seconds_count{endpoint="index",method="GET"} 15.0

# HELP app08_health_status Application health status (1=healthy, 0=unhealthy)
# TYPE app08_health_status gauge
app08_health_status 1.0
```

---

### 3. Создание Helm чарта

#### 3.1. Структура Helm чарта

Создан полный Helm чарт с параметризацией всех необходимых настроек:

```
helm/
├── Chart.yaml              # Метаданные чарта
├── values.yaml            # Значения по умолчанию
└── templates/
    ├── _helpers.tpl       # Helper функции
    ├── namespace.yaml     # Namespace для приложения
    ├── serviceaccount.yaml
    ├── deployment.yaml    # Deployment с приложением
    ├── service.yaml       # Service
    ├── ingress.yaml       # Ingress (опционально)
    ├── servicemonitor.yaml # ServiceMonitor для Prometheus
    ├── prometheusrule.yaml # PrometheusRule с алертами
    ├── hpa.yaml           # HorizontalPodAutoscaler (опционально)
    └── NOTES.txt          # Инструкции после установки
```

#### 3.2. Ключевые параметры в values.yaml

```yaml
# Метаданные студента
student:
  fullname: "Козловская Анна Геннадьевна"
  id: "220012"
  group: "АС-63"
  variant: "8"
  slug: "as63-220012-v8"

# Настройки приложения
replicaCount: 2
image:
  repository: monitoring-app
  tag: "1.0.0"

# Namespace
namespaceOverride: "app-as63-220012-v8"

# Resources
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

# Настройки метрик
metrics:
  enabled: true
  prefix: "app08_"
  serviceMonitor:
    enabled: true
    interval: 30s

# SLO и алерты для варианта 8
slo:
  availability: 99.5    # 99.5% доступность
  latencyP95: 350       # p95 <= 350ms
  errorRate5xx: 2.5     # 5xx <= 2.5% за 15м
```

#### 3.3. ServiceMonitor для автоматического сбора метрик

В чарте создан ServiceMonitor, который автоматически обнаруживается Prometheus:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "monitoring-app.fullname" . }}
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      {{- include "monitoring-app.selectorLabels" . | nindent 6 }}
  namespaceSelector:
    matchNames:
      - {{ include "monitoring-app.namespace" . }}
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
    scrapeTimeout: 10s
```

#### 3.4. PrometheusRule с алертами по SLO

Создан PrometheusRule с 4 алертами согласно требованиям варианта 8:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ include "monitoring-app.fullname" . }}
  namespace: monitoring
spec:
  groups:
  - name: monitoring-app-slo-alerts
    interval: 30s
    rules:
    # Алерт 1: Высокий процент ошибок 5xx (>2.5% за 15 минут)
    - alert: HighErrorRate5xx
      expr: |
        (sum(rate(app08_http_errors_5xx_total[15m])) by (job) / 
         sum(rate(app08_http_requests_total[15m])) by (job)) * 100 > 2.5
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High 5xx error rate detected"
        description: "5xx error rate is {{ $value }}% (threshold: 2.5%)"
    
    # Алерт 2: Высокая задержка P95 (>350ms)
    - alert: HighLatencyP95
      expr: |
        histogram_quantile(0.95, 
          sum(rate(app08_http_request_duration_seconds_bucket[5m])) by (le, job)
        ) > 0.350
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High P95 latency detected"
        description: "P95 latency is {{ $value }}s (threshold: 0.350s)"
    
    # Алерт 3: Низкая доступность (<99.5%)
    - alert: LowAvailability
      expr: |
        (sum(rate(app08_http_requests_total{status!~"5.."}[15m])) by (job) / 
         sum(rate(app08_http_requests_total[15m])) by (job)) * 100 < 99.5
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Service availability below SLO"
        description: "Availability is {{ $value }}% (SLO: 99.5%)"
    
    # Алерт 4: Сервис недоступен
    - alert: ServiceDown
      expr: |
        up{job="mon-as63-220012-v8-monitoring-app"} == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Service is down"
```

#### 3.5. Валидация Helm чарта

```bash
cd src/helm

# Lint - проверка синтаксиса
helm lint .

# Template - генерация манифестов без установки
helm template as63-220012-v8-app . --namespace app-as63-220012-v8

# Dry-run - симуляция установки
helm install as63-220012-v8-app . --namespace app-as63-220012-v8 --create-namespace --dry-run
```

Все проверки пройдены успешно, ошибок не обнаружено.

---

### 4. Деплой приложения через Helm

#### 4.1. Установка чарта

```bash
cd src/scripts
./deploy-app.sh  # Linux/macOS
# или
.\deploy-app.ps1  # Windows PowerShell
```

Скрипт выполняет:

1. Валидацию чарта (`helm lint`)
2. Создание namespace `app-as63-220012-v8`
3. Установку/обновление приложения через `helm upgrade --install`

#### 4.2. Проверка развёртывания

```bash
# Проверка всех ресурсов
kubectl get all -n app-as63-220012-v8

# Проверка подов
kubectl get pods -n app-as63-220012-v8

# Логи приложения
kubectl logs -n app-as63-220012-v8 -l app.kubernetes.io/name=monitoring-app -f

# Проверка ServiceMonitor
kubectl get servicemonitor -n monitoring as63-220012-v8-app-monitoring-app

# Проверка PrometheusRule
kubectl get prometheusrule -n monitoring as63-220012-v8-app-monitoring-app
```

![ServiceMonitor](./screenshots/05-servicemonitor.png)
![PrometheusRule](./screenshots/06-prometheusrule.png)

#### 4.3. Доступ к приложению

```bash
# Port-forward для локального доступа
kubectl port-forward -n app-as63-220012-v8 svc/as63-220012-v8-app-monitoring-app 8080:8080

# Проверка endpoints
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/metrics
```

---

### 5. Создание дашбордов в Grafana

#### 5.1. Импорт дашбордов

Созданы 3 JSON дашборда для визуализации ключевых метрик:

1. **Дашборд доступности** (`availability-dashboard.json`)
   - Service Availability (%) с порогами SLO
   - Service Health Status
   - Availability Over Time
   - Total Requests
   - Success Rate (2xx/3xx)
   - Uptime Status

2. **Дашборд задержек** (`latency-dashboard.json`)
   - P95 Latency с порогом SLO 350ms
   - P99 Latency
   - Average Latency
   - Latency Percentiles Over Time (P50, P90, P95, P99)
   - Latency by Endpoint
   - Request Duration Heatmap

3. **Дашборд ошибок** (`errors-dashboard.json`)
   - 5xx Error Rate с порогом SLO 2.5%
   - 4xx Error Rate
   - Total Error Rate
   - 5xx Error Rate Over Time (15m window)
   - Error Breakdown by Status Code
   - Errors by Endpoint
   - Success vs Errors Distribution

#### 5.2. Импорт в Grafana

1. Откройте Grafana UI (<http://localhost:3000>)
2. Перейдите в **Dashboards** → **Import**
3. Загрузите JSON файлы из `src/grafana-dashboards/`
4. Выберите Prometheus data source

![Dashboard Availability](./screenshots/07-dashboard-availability.png)
![Dashboard Latency](./screenshots/08-dashboard-latency.png)
![Dashboard Errors](./screenshots/09-dashboard-errors.png)

#### 5.3. Настройка Data Source

В Grafana уже преднастроен Prometheus data source от kube-prometheus-stack:

- **Name:** Prometheus
- **URL:** <http://kube-prometheus-stack-prometheus.monitoring.svc:9090>
- **Access:** Server (default)

---

### 6. Тестирование алертов

#### 6.1. Генерация тестовой нагрузки

Для проверки срабатывания алертов используется скрипт генерации нагрузки:

```bash
cd src/scripts

# Запустить port-forward в отдельном терминале
kubectl port-forward -n app-as63-220012-v8 svc/as63-220012-v8-app-monitoring-app 8080:8080

# Запустить генерацию нагрузки
./load-test.sh
```

Скрипт генерирует:

- 70% нормальных запросов к `/api/data`
- 20% медленных запросов к `/api/slow` (для тестирования latency алерта)
- 10% запросов к `/api/error` (для тестирования 5xx алерта)

#### 6.2. Проверка алертов в Prometheus

1. Откройте Prometheus UI (<http://localhost:9090>)
2. Перейдите в **Alerts**
3. Проверьте состояние алертов:
   - `HighErrorRate5xx`
   - `HighLatencyP95`
   - `LowAvailability`
   - `ServiceDown`

#### 6.3. Проверка алертов в Alertmanager

1. Откройте Alertmanager UI (<http://localhost:9093>)
2. Проверьте сработавшие алерты
3. Убедитесь, что алерты содержат правильные labels (severity, variant, student_id)

![Alert Firing](./screenshots/10-alert-firing.png)

#### 6.4. Демонстрация срабатывания алертов

##### Сценарий 1: Высокий процент ошибок 5xx

- При запуске load-test.sh примерно 10% запросов возвращают ошибки 5xx
- Через 5-10 минут должен сработать алерт `HighErrorRate5xx`
- Алерт имеет severity: critical

##### Сценарий 2: Высокая задержка P95

- Медленные запросы к `/api/slow` генерируют задержки 100-600ms
- Некоторые запросы превышают SLO порог 350ms
- Должен сработать алерт `HighLatencyP95`
- Алерт имеет severity: warning

##### Сценарий 3: Низкая доступность

- При высоком проценте ошибок доступность падает ниже 99.5%
- Срабатывает алерт `LowAvailability`
- Алерт имеет severity: critical

---

### 7. GitOps с Argo CD (дополнительное задание)

#### 7.1. Установка Argo CD

```bash
cd src/scripts
./install-argocd.sh  # Linux/macOS
# или
.\install-argocd.ps1  # Windows PowerShell
```

После установки:

1. Получить пароль администратора:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

1. Port-forward для доступа к UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

1. Открыть <https://localhost:8080>

#### 7.2. Создание Application для GitOps

Применен Application манифест для автоматической синхронизации:

```bash
kubectl apply -f src/argocd/application.yaml
```

Application настроен на:

- **Source:** Git репозиторий `https://github.com/brstu/RSiOT-2025.git`, ветка `task_04`
- **Path:** `students/KozlovskayaAnna/task_04/src/helm`
- **Destination:** namespace `app-as63-220012-v8`
- **SyncPolicy:**
  - `automated: true` - автоматическая синхронизация при изменениях
  - `prune: true` - удаление ресурсов, которых нет в Git
  - `selfHeal: true` - автовосстановление при ручных изменениях

#### 7.3. Проверка синхронизации

```bash
# Проверить статус Application
kubectl get application -n argocd monitoring-app-as63-220012-v8

# Детальная информация
kubectl describe application -n argocd monitoring-app-as63-220012-v8
```

![Argo CD Sync](./screenshots/11-argocd-sync.png)

#### 7.4. Демонстрация автоматической синхронизации

1. Внести изменение в `values.yaml` (например, изменить `replicaCount: 3`)
2. Закоммитить и запушить в Git
3. Argo CD автоматически обнаружит изменения (в течение 3 минут по умолчанию)
4. Применит изменения к кластеру
5. В UI Argo CD можно наблюдать процесс синхронизации

**Преимущества GitOps:**

- Декларативное описание инфраструктуры
- Версионирование всех изменений в Git
- Автоматическое применение изменений
- Возможность отката к предыдущей версии
- Аудит всех изменений

---

## Схема архитектуры наблюдаемости

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                          │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                  Namespace: app-as63-220012-v8                │ │
│  │                                                               │ │
│  │  ┌─────────────┐  ┌─────────────┐                            │ │
│  │  │   Pod 1     │  │   Pod 2     │                            │ │
│  │  │ Flask App   │  │ Flask App   │                            │ │
│  │  │  :8080      │  │  :8080      │                            │ │
│  │  │ /metrics    │  │ /metrics    │                            │ │
│  │  └──────┬──────┘  └──────┬──────┘                            │ │
│  │         │                 │                                   │ │
│  │         └────────┬────────┘                                   │ │
│  │                  │                                            │ │
│  │           ┌──────▼──────┐                                     │ │
│  │           │   Service   │                                     │ │
│  │           │  ClusterIP  │                                     │ │
│  │           └─────────────┘                                     │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                  Namespace: monitoring                        │ │
│  │                                                               │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │              ServiceMonitor (CRD)                       │ │ │
│  │  │  selector: app.kubernetes.io/name=monitoring-app       │ │ │
│  │  │  endpoint: /metrics, interval: 30s                     │ │ │
│  │  └──────────────────────┬──────────────────────────────────┘ │ │
│  │                         │                                     │ │
│  │                         ▼                                     │ │
│  │           ┌─────────────────────────┐                        │ │
│  │           │   Prometheus Server     │                        │ │
│  │           │  - Scrapes metrics      │                        │ │
│  │           │  - Stores time series   │                        │ │
│  │           │  - Evaluates rules      │                        │ │
│  │           └────────┬────────────────┘                        │ │
│  │                    │                                          │ │
│  │  ┌─────────────────┼─────────────────────────────────────┐  │ │
│  │  │ PrometheusRule  │  (CRD)                              │  │ │
│  │  │  - HighErrorRate5xx (>2.5% за 15м)                    │  │ │
│  │  │  - HighLatencyP95 (>350ms)                            │  │ │
│  │  │  - LowAvailability (<99.5%)                           │  │ │
│  │  │  - ServiceDown                                        │  │ │
│  │  └────────────────────────────────────────────────────────┘  │ │
│  │                    │                                          │ │
│  │                    ▼                                          │ │
│  │           ┌─────────────────┐                                │ │
│  │           │  Alertmanager   │                                │ │
│  │           │  - Routing      │                                │ │
│  │           │  - Grouping     │                                │ │
│  │           │  - Silencing    │                                │ │
│  │           └─────────────────┘                                │ │
│  │                    │                                          │ │
│  │                    ▼                                          │ │
│  │           ┌─────────────────┐                                │ │
│  │           │    Grafana      │                                │ │
│  │           │  - Dashboards   │◄────── JSON Dashboards         │ │
│  │           │  - Visualization│        (availability,          │ │
│  │           │  - Alerting     │         latency, errors)       │ │
│  │           └─────────────────┘                                │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                    Namespace: argocd                          │ │
│  │                                                               │ │
│  │           ┌─────────────────────────┐                        │ │
│  │           │   Argo CD Server        │                        │ │
│  │           │  - Git Sync (3 min)     │                        │ │
│  │           │  - Auto Deploy          │◄───── Git Repository   │ │
│  │           │  - Self Healing         │       (Helm Chart)     │ │
│  │           └─────────────────────────┘                        │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘

Метрики:
  app08_http_requests_total           - Counter (запросы)
  app08_http_request_duration_seconds - Histogram (задержки)
  app08_http_requests_in_progress     - Gauge (активные)
  app08_http_errors_5xx_total         - Counter (ошибки 5xx)
  app08_http_errors_4xx_total         - Counter (ошибки 4xx)
  app08_health_status                 - Gauge (здоровье)
  app08_app_info                      - Gauge (информация)

SLO (Вариант 8):
  - Доступность: 99.5%
  - Latency P95: 350ms
  - Error Rate 5xx: <2.5% за 15 минут
```

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Установка kube-prometheus-stack (Prometheus, Grafana, Alertmanager)
- [✅] Flask приложение с интеграцией prometheus-client
- [✅] Endpoint `/metrics` с префиксом `app08_`
- [✅] Базовые метрики: Counter (requests), Histogram (latency), Gauge (status)
- [✅] Dockerfile (multi-stage, non-root user, labels org.bstu.*)
- [✅] Helm чарт с полной параметризацией
- [✅] Templates: Deployment, Service, Ingress, ServiceMonitor, PrometheusRule
- [✅] ServiceMonitor для автоматического сбора метрик (interval: 30s)
- [✅] PrometheusRule с 4 алертами по SLO:
  - [✅] HighErrorRate5xx (>2.5% за 15м)
  - [✅] HighLatencyP95 (>350ms)
  - [✅] LowAvailability (<99.5%)
  - [✅] ServiceDown
- [✅] 3 дашборда Grafana (JSON):
  - [✅] Availability Dashboard
  - [✅] Latency Dashboard (P95/P99)
  - [✅] Errors Dashboard (5xx)
- [✅] Helm lint успешно выполнен
- [✅] Helm template генерирует корректные манифесты
- [✅] Успешная установка через helm install
- [✅] Демонстрация срабатывания алертов
- [✅] Скрипты установки и деплоя (.sh и .ps1)
- [✅] GitOps: установка Argo CD
- [✅] GitOps: Application манифест для автосинхронизации
- [✅] GitOps: демонстрация автоматического применения изменений
- [✅] Все labels и annotations содержат метаданные студента
- [✅] Именование ресурсов: mon-as63-220012-v8, alert-as63-220012-v8
- [✅] Namespace: app-as63-220012-v8
- [✅] Release name: as63-220012-v8-app
- [✅] ENV переменные (STU_ID, STU_GROUP, STU_VARIANT) логируются при старте
- [✅] Структура doc/ и src/ соблюдена
- [✅] Screenshots в doc/screenshots/

---

## Инструкции по воспроизведению

### Предварительные требования

- Kubernetes кластер (Minikube/Kind/Docker Desktop)
- Helm 3.x
- kubectl
- Docker (для сборки образа)

### Шаг 1: Клонирование репозитория

```bash
git clone https://github.com/brstu/RSiOT-2025.git
cd RSiOT-2025/students/KozlovskayaAnna/task_04
```

### Шаг 2: Установка kube-prometheus-stack

```bash
cd src/scripts
./install-monitoring.sh  # Linux/macOS
# или
.\install-monitoring.ps1  # Windows
```

### Шаг 3: Сборка образа приложения (опционально)

```bash
cd src/app
docker build -t monitoring-app:1.0.0 .
```

### Шаг 4: Деплой приложения через Helm

```bash
cd src/scripts
./deploy-app.sh  # Linux/macOS
# или
.\deploy-app.ps1  # Windows
```

### Шаг 5: Проверка развёртывания

```bash
# Проверка подов
kubectl get pods -n app-as63-220012-v8
kubectl get pods -n monitoring

# Проверка ServiceMonitor и PrometheusRule
kubectl get servicemonitor -n monitoring
kubectl get prometheusrule -n monitoring
```

### Шаг 6: Доступ к компонентам

**Prometheus:**

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Открыть http://localhost:9090
```

**Grafana:**

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Открыть http://localhost:3000 (admin/admin)
```

**Приложение:**

```bash
kubectl port-forward -n app-as63-220012-v8 svc/as63-220012-v8-app-monitoring-app 8080:8080
# Открыть http://localhost:8080/metrics
```

### Шаг 7: Импорт дашбордов в Grafana

1. Открыть Grafana (<http://localhost:3000>)
2. Перейти в **Dashboards** → **Import**
3. Загрузить файлы из `src/grafana-dashboards/`:
   - `availability-dashboard.json`
   - `latency-dashboard.json`
   - `errors-dashboard.json`

### Шаг 8: Тестирование алертов

```bash
cd src/scripts

# В отдельном терминале запустить port-forward
kubectl port-forward -n app-as63-220012-v8 svc/as63-220012-v8-app-monitoring-app 8080:8080

# Запустить генерацию нагрузки
./load-test.sh

# Проверить алерты в Prometheus (http://localhost:9090/alerts)
```

### Шаг 9: GitOps с Argo CD (опционально)

```bash
cd src/scripts
./install-argocd.sh  # или .\install-argocd.ps1

# Применить Application
kubectl apply -f ../argocd/application.yaml

# Проверить статус
kubectl get application -n argocd

# Доступ к UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Открыть https://localhost:8080
```

---

## Полезные команды

### Просмотр логов

```bash
# Логи приложения
kubectl logs -n app-as63-220012-v8 -l app.kubernetes.io/name=monitoring-app -f

# Логи Prometheus
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus -f

# Логи Grafana
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana -f
```

### Проверка метрик в Prometheus

```bash
# Port-forward Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Открыть http://localhost:9090/graph
# Примеры запросов:
# - app08_http_requests_total
# - rate(app08_http_requests_total[5m])
# - histogram_quantile(0.95, rate(app08_http_request_duration_seconds_bucket[5m]))
# - (sum(rate(app08_http_errors_5xx_total[15m])) / sum(rate(app08_http_requests_total[15m]))) * 100
```

### Удаление ресурсов

```bash
# Удалить приложение
helm uninstall as63-220012-v8-app -n app-as63-220012-v8
kubectl delete namespace app-as63-220012-v8

# Удалить kube-prometheus-stack
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring

# Удалить Argo CD
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

---

## Решение проблем (Troubleshooting)

### Проблема: ServiceMonitor не обнаруживается Prometheus

**Решение:**

1. Проверить labels на ServiceMonitor:

```bash
kubectl get servicemonitor -n monitoring --show-labels
```

1. Убедиться, что label `release: kube-prometheus-stack` присутствует
2. Проверить конфигурацию Prometheus Operator:

```bash
kubectl get prometheus -n monitoring kube-prometheus-stack-prometheus -o yaml
```

### Проблема: Алерты не срабатывают

**Решение:**

1. Проверить PrometheusRule:

```bash
kubectl get prometheusrule -n monitoring -o yaml
```

1. Проверить статус правил в Prometheus UI (<http://localhost:9090/rules>)
2. Убедиться, что метрики собираются (проверить Targets в Prometheus)
3. Проверить PromQL запросы алертов вручную в Prometheus

### Проблема: Метрики не отображаются в Grafana

**Решение:**

1. Проверить Data Source в Grafana (Settings → Data Sources)
2. Убедиться, что Prometheus доступен по URL: `http://kube-prometheus-stack-prometheus.monitoring.svc:9090`
3. Проверить, что метрики с префиксом `app08_` есть в Prometheus
4. Проверить PromQL запросы в дашборде

### Проблема: Argo CD не синхронизирует изменения

**Решение:**

1. Проверить статус Application:

```bash
kubectl describe application -n argocd monitoring-app-as63-220012-v8
```

1. Проверить логи Argo CD:

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f
```

1. Убедиться, что Git репозиторий доступен и путь к чарту правильный
2. Проверить RBAC права Argo CD

---

## Ссылки

- **Prometheus Documentation:** <https://prometheus.io/docs/>
- **Grafana Documentation:** <https://grafana.com/docs/>
- **Argo CD Documentation:** <https://argo-cd.readthedocs.io/>
- **Helm Documentation:** <https://helm.sh/docs/>
- **kube-prometheus-stack:** <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>
- **Prometheus Python Client:** <https://github.com/prometheus/client_python>

---

## Вывод

В ходе выполнения лабораторной работы №04 была успешно развёрнута и настроена полноценная система наблюдаемости для Kubernetes-приложения. Реализованы все базовые требования и дополнительные задания:

**Основные достижения:**

1. **Установка и настройка kube-prometheus-stack** - развёрнут полный стек мониторинга с Prometheus, Grafana и Alertmanager в namespace `monitoring`.

2. **Интеграция метрик в приложение** - разработано Flask приложение с полной интеграцией клиентской библиотеки Prometheus, экспонирующее метрики с правильным префиксом `app08_` через endpoint `/metrics`.

3. **Автоматический сбор метрик** - создан ServiceMonitor, который автоматически обнаруживается Prometheus Operator и настраивает scraping метрик каждые 30 секунд.

4. **Визуализация метрик** - разработаны 3 детальных дашборда в Grafana для мониторинга доступности, задержек (P95/P99) и ошибок 5xx, полностью соответствующих требованиям варианта 8.

5. **Настройка алертов по SLO** - создан PrometheusRule с 4 алертами, контролирующими выполнение Service Level Objectives: доступность 99.5%, latency P95 ≤ 350ms, error rate 5xx ≤ 2.5% за 15 минут, и статус работы сервиса.

6. **Helm чарт с полной параметризацией** - упаковано приложение в Helm чарт с корректными templates (Deployment, Service, Ingress, ServiceMonitor, PrometheusRule), прошедший валидацию через `helm lint` и `helm template`.

7. **GitOps с Argo CD** (дополнительно) - настроена автоматическая синхронизация Helm-чарта из Git-репозитория с помощью Argo CD, реализован принцип Infrastructure as Code и автоматическое применение изменений.

**Освоенные навыки:**

- Работа с Prometheus Operator и Custom Resource Definitions (ServiceMonitor, PrometheusRule)
- Написание PromQL запросов для анализа метрик и создания алертов
- Создание информативных дашбордов в Grafana
- Проектирование SLO и настройка алертинга
- Упаковка приложений в Helm чарты с правильной параметризацией
- Внедрение GitOps практик с использованием Argo CD
- Контейнеризация приложений с соблюдением best practices (multi-stage build, non-root user, health checks)

**Практическая ценность:**

Полученные в ходе работы знания и навыки являются критически важными для современной DevOps/SRE практики. Система наблюдаемости, построенная в рамках этой лабораторной работы, позволяет:

- Проактивно выявлять проблемы до их влияния на пользователей
- Контролировать выполнение SLO и вовремя реагировать на их нарушение
- Визуализировать ключевые метрики для принятия обоснованных решений
- Автоматизировать процесс развёртывания и обновления приложений
- Обеспечить соответствие инфраструктуры заявленному состоянию в Git (GitOps)

Все компоненты системы были протестированы, продемонстрировано срабатывание алертов, успешная работа автоматической синхронизации через Argo CD, и корректная визуализация метрик в Grafana.
