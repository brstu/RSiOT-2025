# Лабораторная работа 04: Наблюдаемость и метрики

***Вариант №16: Галерея мемов***

**Параметры задания:**

- **Префикс метрик:** `memes_gallery_`
- **SLO доступность:** `99.9%`
- **P95 латенси:** `1 секунда`
- **Алерт по ошибкам:** `5xx > 0.1% за 5 минут`

---

## Метаданные студента

- **ФИО:** Никифоров Александр Иванович
- **Группа:** AS-63
- **StudentID:** 220020
- **Вариант:** 16
- **Namespace приложения:** `app-memes-gallery`

---

## Установка системы мониторинга

### 1. Установка kube-prometheus-stack

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword="admin" \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### 2. Доступ к интерфейсам

```bash
# Grafana
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-stack-prometheus 9090:9090

# Alertmanager
kubectl port-forward -n monitoring svc/prometheus-stack-alertmanager 9093:9093
```

**Grafana:** <http://localhost:3000> (admin/admin)

---

## Развертывание приложения

### 1. Сборка Docker образа

```bash
cd task_04
docker build -t [ваш-username]/memes-gallery:v1.0.0 -f src/app/Dockerfile src/app/
docker push [ваш-username]/memes-gallery:v1.0.0
```

### 2. Установка через Helm

```bash
kubectl create namespace app-memes-gallery

helm install memes-gallery ./helm/monitoring-app \
  --namespace app-memes-gallery \
  --set image.repository="[ваш-username]/memes-gallery" \
  --set image.tag="v1.0.0" \
  --set metadata.studentId="220020" \
  --set metadata.group="AS-63" \
  --set metadata.variant="16"
```

### 3. Проверка установки

```bash
kubectl get pods,svc,servicemonitor,prometheusrules -n app-memes-gallery
```

---

## Описание приложения

### Метрики (префикс `memes_gallery_`)

1. **`memes_gallery_http_requests_total`** - счетчик HTTP запросов
2. **`memes_gallery_http_request_duration_seconds`** - гистограмма времени выполнения
3. **`memes_gallery_active_users`** - gauge активных пользователей
4. **`memes_gallery_errors_total`** - счетчик ошибок 5xx

### Endpoints приложения

- `GET /` - главная страница
- `GET /metrics` - метрики Prometheus
- `GET /health` - health check
- `GET /memes` - получение мемов
- `GET /error` - тестовый endpoint для ошибок

---

## Конфигурация мониторинга

### ServiceMonitor

```yaml
spec:
  selector:
    matchLabels:
      app: memes-gallery
  endpoints:
  - port: http
    path: /metrics
    interval: 15s
  namespaceSelector:
    matchNames:
    - app-memes-gallery
```

### Prometheus Rules (Алерты)

1. **MemesGalleryHighErrorRate** - ошибки 5xx > 0.1% за 5 минут
2. **MemesGalleryHighLatency** - P95 латенси > 1 секунда
3. **MemesGalleryLowAvailability** - сервис недоступен

---

## Дашборды Grafana

### Доступные дашборды

1. **Memes Gallery - Обзор** - общая статистика
2. **Memes Gallery - Производительность** - P95 латенси, SLO
3. **Memes Gallery - Ошибки** - процент ошибок 5xx

### PromQL запросы

**Доступность:**

```promql
100 * (1 - rate(memes_gallery_http_requests_total{status=~"5.."}[5m]) / rate(memes_gallery_http_requests_total[5m]))
```

**P95 латенси:**

```promql
histogram_quantile(0.95, rate(memes_gallery_http_request_duration_seconds_bucket[5m]))
```

---

## Тестирование

### Проверка метрик

```bash
kubectl port-forward -n app-memes-gallery svc/memes-gallery 8080:5000
curl http://localhost:8080/metrics | grep memes_gallery_
```

### Проверка алертов

```bash
# Генерация ошибок для тестирования
for i in {1..50}; do curl http://localhost:8080/error; done

# Проверить алерты в Prometheus UI
# http://localhost:9090/alerts
```

---

## Метаданные

Все ресурсы содержат метки:

```yaml
labels:
  org.bstu.course: RSIOT
  org.bstu.variant: "16"
  org.bstu.student.fullname: "Никифоров Александр Иванович"
  org.bstu.student.id: "220020"
  org.bstu.group: "AS-63"
  slug: as-63--v16
```

Проверка:

```bash
kubectl get all -n app-memes-gallery --show-labels | grep org.bstu
```

---

## Удаление

```bash
helm uninstall memes-gallery -n app-memes-gallery
kubectl delete namespace app-memes-gallery

helm uninstall prometheus-stack -n monitoring
kubectl delete namespace monitoring
```

---

## Вывод

Развернута система мониторинга для приложения "Галерея мемов" (вариант 16). Приложение экспортирует метрики с префиксом `memes_gallery_`, настроены алерты по SLO (доступность 99.9%, P95 < 1s, ошибки >0.1%). Все компоненты упакованы в Helm-чарт с метаданными.
