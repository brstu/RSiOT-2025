# Лабораторная работа 04: Наблюдаемость и метрики

**Студент:** Ярмола Александр Олегович  
**Группа:** АС-63  
**Вариант:** 23

## Параметры варианта

- **Префикс метрик:** `app23_`
- **SLO доступность:** 99.5%
- **p95 latency:** ≤200ms
- **Alert:** 5xx>1% за 5м

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

- `app23_http_requests_total` - Counter запросов
- `app23_http_request_duration_seconds` - Histogram задержки

## Алерты

1. **LowAvailability** - доступность < 99.5%
2. **HighErrorRate5xx** - 5xx ошибок > 1% за 5м
3. **HighLatencyP95** - p95 latency > 200ms

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
