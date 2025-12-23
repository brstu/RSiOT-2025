# Лабораторная работа 04: Наблюдаемость и метрики

**Студент:** Соколова Маргарита Александровна  
**Группа:** АС-63  
**Вариант:** 19

## Параметры варианта

- **Префикс метрик:** `app19_`
- **SLO доступность:** 99.0%
- **p95 latency:** ≤400ms
- **Alert:** 5xx>3% за 10м

## Быстрый старт

```powershell
# 1. Запустить Minikube
minikube start --cpus=4 --memory=8192

# 2. Установить monitoring stack
$env:Path = "$env:LOCALAPPDATA\helm;$env:Path"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack `
  --namespace monitoring --create-namespace `
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

# 3. Собрать образ приложения
minikube docker-env --shell powershell | Invoke-Expression
docker build -t monitoring-app:latest src/app/

# 4. Установить приложение
helm install monitoring-app ./src/helm/monitoring-app `
  --namespace monitoring-app --create-namespace

# 5. Доступ к UI
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```

## Метрики

- `app19_http_requests_total` - Counter запросов
- `app19_http_request_duration_seconds` - Histogram задержки

## Алерты

1. **LowAvailability** - доступность < 99.0%
2. **HighErrorRate5xx** - 5xx ошибок > 3% за 10м
3. **HighLatencyP95** - p95 latency > 400ms

## Helm параметризация

Все параметры настраиваются через `values.yaml`:

- `replicaCount` - количество реплик (по умолчанию: 2)
- `image.repository`, `image.tag`, `image.pullPolicy` - параметры образа
- `namespace` - namespace для развертывания
- `student.*` - метаданные студента (id, group, variant, fullname, etc.)
- `metrics.*` - настройки метрик (prefix, port, path, SLO)
- `service.*` - параметры Service (type, port)
- `resources.*` - ресурсы CPU/Memory
- `livenessProbe.*`, `readinessProbe.*` - настройки проб
- `serviceMonitor.*` - параметры ServiceMonitor
- `prometheusRule.*` - правила алертов

## Метки org.bstu.*

Все ресурсы содержат метки:

- `org.bstu.student.id` - ID студента
- `org.bstu.student.group` - группа студента
- `org.bstu.variant` - номер варианта
- `org.bstu.course` - курс (RSIOT)
- `org.bstu.owner` - владелец
- `org.bstu.student.slug` - уникальный slug
- `org.bstu.student.fullname` - полное имя (в annotations)

## Документация

Полная документация в [doc/README.md](doc/README.md)

## Структура

```
task_04/
├── README.md              # Этот файл
├── doc/
│   └── README.md          # Полный отчет
└── src/
    ├── app/               # Flask приложение
    ├── k8s/               # Kubernetes манифесты
    └── helm/              # Helm chart
```
