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
<p align="right">Тунчик А.Д.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Вариант №21

**Параметры задания:**
- **Префикс метрик:** `app21_`
- **SLO доступность:** `99.9%`
- **P95 латенси:** `300ms`
- **Алерт по ошибкам:** `5xx > 2% за 5 минут`

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
  --set grafana.adminPassword="admin" \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
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
- URL: http://localhost:3000
- Логин: `admin`
- Пароль: `admin`

---

## Развертывание приложения

### 1. Сборка Docker образа

```bash
# Перейти в директорию проекта
cd task_04

# Собрать образ приложения
docker build -t app-monitoring:v1.0.0 -f src/Dockerfile .
```

### 2. Установка через Helm

```bash
# Создать namespace для приложения
kubectl create namespace app-monitoring

# Установить Helm chart
helm install app-monitoring ./helm/app-monitoring \
  --namespace app-monitoring \
  --set image.repository=app-monitoring \
  --set image.tag=v1.0.0
```

### 3. Проверка установки

```bash
# Проверить состояние подов
kubectl get pods -n app-monitoring

# Проверить сервисы
kubectl get svc -n app-monitoring

# Проверить ServiceMonitor
kubectl get servicemonitor -n app-monitoring

# Проверить PrometheusRules
kubectl get prometheusrules -n app-monitoring
```

---

## Описание приложения

### Метрики (префикс `app21_`)

Приложение экспортирует следующие метрики Prometheus:

1. **`app21_requests_total`** - счетчик HTTP запросов
   - Labels: `method`, `endpoint`, `status_code`

2. **`app21_request_duration_seconds`** - гистограмма времени выполнения
   - Labels: `method`, `endpoint`
   - Buckets: [0.1, 0.2, 0.3, 0.5, 1.0, 2.0, 5.0]

3. **`app21_errors_total`** - счетчик ошибок 5xx
   - Labels: `method`, `endpoint`

4. **`app21_health`** - метрика здоровья приложения
5. **`app21_info`** - информационная метрика

### Endpoints приложения

- **`GET /`** - главная страница с информацией о SLO
- **`GET /metrics`** - метрики в формате Prometheus
- **`GET /health`** - health check для Kubernetes проб
- **`GET /api/data`** - тестовый API (2% вероятность ошибки)
- **`GET /api/slow`** - медленный endpoint для тестирования алертов

---

## Конфигурация мониторинга

### ServiceMonitor

ServiceMonitor автоматически настраивает Prometheus для сбора метрик:

```yaml
spec:
  selector:
    matchLabels:
      app: app-monitoring
  endpoints:
  - port: metrics
    path: /metrics
    interval: 30s
  namespaceSelector:
    matchNames:
    - app-monitoring
```

### Prometheus Rules (Алерты)

Настроены три алерта согласно требованиям варианта:

1. **App21HighErrorRate**
   - Условие: Ошибки 5xx > 2% за 5 минут
   - Severity: warning
   - For: 1m

2. **App21HighLatency**
   - Условие: P95 латенси > 300ms
   - Severity: warning
   - For: 2m

3. **App21LowAvailability**
   - Условие: Доступность < 99.9%
   - Severity: critical
   - For: 3m

### Recording Rules

Дополнительные правила для упрощения запросов:

- **`app21:error_rate:5m`** - процент ошибок за 5 минут
- **`app21:availability:5m`** - доступность за 5 минут
- **`app21:latency_p95:5m`** - P95 латенси за 5 минут

---

## Дашборды Grafana

### Доступные дашборды

1. **App21 Monitoring Overview**
   - График запросов в секунду
   - Статус доступности в реальном времени
   - Цветовая индикация по порогам SLO

2. **App21 Alerts Status**
   - Таблица активных алертов
   - График процента ошибок
   - График P95 латенси

### Импорт дашбордов

```bash
# Получить пароль Grafana
kubectl get secret -n monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

# Импортировать через UI Grafana:
# 1. Открыть http://localhost:3000
# 2. Нажать "Create" → "Import"
# 3. Загрузить JSON файлы из папки grafana/
```

---

## Тестирование

### Нагрузочное тестирование

```bash
# Запустить скрипт тестирования
./scripts/test-load.sh

# Скрипт выполняет:
# - 500 запросов к основному endpoint
# - Каждый 20-й запрос к /api/data
# - Каждый 100-й запрос к /api/slow
```

### Проверка метрик

```bash
# Проверить экспорт метрик
kubectl port-forward -n app-monitoring svc/app-monitoring 8080:8080
curl http://localhost:8080/metrics | grep app21_

# Проверить health endpoint
curl http://localhost:8080/health
```

### Проверка алертов

```bash
# Проверить статус алертов в Prometheus
# Открыть http://localhost:9090/alerts

# Проверить метрики в Prometheus UI
# Выполнить запросы:
# - app21:availability:5m
# - app21:error_rate:5m
# - app21:latency_p95:5m
```

---

## Метаданные

Все ресурсы Kubernetes содержат необходимые метаданные:

```yaml
labels:
  org.bstu.course: RSIOT
  org.bstu.variant: "21"
  org.bstu.student.fullname: Tunchik Anton Dmitrievich
  org.bstu.student.id: "006326"
  org.bstu.group: AC-63
  slug: ac-63--v21
```

Проверка метаданных:

```bash
kubectl get deployments,services -n app-monitoring --show-labels | grep org.bstu
```

---

## Удаление

```bash
# Удалить приложение
helm uninstall app-monitoring -n app-monitoring
kubectl delete namespace app-monitoring

# Удалить систему мониторинга
helm uninstall kube-prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

## Вывод

Развернута полная система мониторинга для приложения согласно варианту №21. Приложение экспортирует метрики с префиксом `app21_`, настроены алерты по SLO (доступность 99.9%, P95 латенси 300ms, ошибки >2% за 5 минут). Система включает Prometheus для сбора метрик, Grafana для визуализации и Alertmanager для уведомлений. Все компоненты упакованы в Helm-чарт с полной параметризацией и содержат требуемые метаданные.
