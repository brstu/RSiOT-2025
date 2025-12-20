# Лабораторная работа №4

## Наблюдаемость и метрики (Prometheus + Grafana)

**Студент:** Ярмолович Александр Сергеевич  
**Группа:** АС-63  
**Вариант:** 24

---

## 📌 Параметры варианта

| Параметр | Значение |
|--------|---------|
| Префикс метрик | `app24_` |
| SLO доступность | 99.9% |
| SLO p95 latency | ≤ 350 ms |
| Alert | 5xx > 2.5% за 10 минут |

---

## 🧩 Описание работы

В рамках лабораторной работы разработано Flask-приложение с экспортом метрик Prometheus.  
Для приложения реализована система наблюдаемости:

- сбор метрик через **ServiceMonitor**
- контроль SLO через **PrometheusRule**
- визуализация показателей в **Grafana**

Развёртывание приложения выполнено с использованием **Helm-чарта**.

---

## 🚀 Быстрый старт

### 1️⃣ Запуск Minikube

```powershell
minikube start --cpus=4 --memory=8192
```

### 2️⃣ Установка monitoring stack

```powershell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install monitoring prometheus-community/kube-prometheus-stack `
  --namespace monitoring --create-namespace `
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### 3️⃣ Сборка образа приложения

```powershell
minikube docker-env --shell powershell | Invoke-Expression
docker build -t app24:latest src/app/
```

### 4️⃣ Установка приложения через Helm

```powershell
helm install app24 ./helm/app24 `
  --namespace app24 --create-namespace
```

### 5️⃣ Доступ к UI

```powershell
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```

## 📊 Метрики приложения

Экспортируются по endpoint `/metrics`.

| Метрика | Тип | Описание |
|------|------|---------|
| `app24_http_requests_total` | Counter | Количество HTTP-запросов |
| `app24_http_request_duration_seconds` | Histogram | Время обработки запросов |

---

## 🚨 Алерты (PrometheusRule)

### 1️⃣ LowAvailability

- **Условие:** доступность < 99.9%
- **Период:** 10 минут
- **Severity:** `critical`

```promql
(sum(rate(app24_http_requests_total{status!~"5.."}[10m])) 
/ sum(rate(app24_http_requests_total[10m]))) * 100 < 99.9
```

### 2️⃣ HighErrorRate5xx

- **Условие:** 5xx > 2.5%
- **Период:** 10 минут
- **Severity:** `warning`

```promql
(sum(rate(app24_http_requests_total{status=~"5.."}[10m])) 
/ sum(rate(app24_http_requests_total[10m]))) * 100 > 2.5
```

### 3️⃣ HighLatencyP95

- **Условие:** p95 > 350 ms
- **Период:** 10 минут
- **Severity:** `warning`

```promql
histogram_quantile(
  0.95,
  sum(rate(app24_http_request_duration_seconds_bucket[10m])) by (le)
) > 0.35
```

---

## 📁 Структура проекта

task_04/
├── README.md
├── doc/
│   └── README.md
└── src/
    ├── app/
    │   ├── app.py
    │   ├── Dockerfile
    │   └── requirements.txt
    └── helm/
        └── monitoring-app/
            ├── Chart.yaml
            ├── values.yaml
            └── templates/
                ├── deployment.yaml
                ├── service.yaml
                ├── servicemonitor.yaml
                ├── prometheusrule.yaml
                └── helpers.tpl

---

## 🧪 Генерация тестового трафика

Port-forward к приложению

```powershell
kubectl port-forward svc/app24 8080:8080 -n app24
```

### 🔹 Нормальная нагрузка

```powershell
while ($true) {
  Invoke-WebRequest http://localhost:8080/api/data -UseBasicParsing | Out-Null
  Start-Sleep -Milliseconds 300
}
```

### 🔹 Триггер HighLatencyP95

```powershell
while ($true) {
  Invoke-WebRequest http://localhost:8080/api/slow -UseBasicParsing | Out-Null
  Start-Sleep -Milliseconds 100
}
```

### 🔹 Триггер HighErrorRate5xx

```powershell
while ($true) {
  try {
    Invoke-WebRequest http://localhost:8080/api/error -UseBasicParsing | Out-Null
  } catch {}
  Start-Sleep -Milliseconds 100
}
```

## 📈 Проверка метрик в Prometheus

```promql
rate(app24_http_requests_total[5m])
```

```promql
(sum(rate(app24_http_requests_total{status!~"5.."}[10m])) 
/ sum(rate(app24_http_requests_total[10m]))) * 100
```

```promql
histogram_quantile(
  0.95,
  sum(rate(app24_http_request_duration_seconds_bucket[10m])) by (le)
)
```

## 📊 Grafana

Созданы дашборды:

- **Availability** (SLO 99.9%)
- **p95 Latency** (≤ 350 ms)
- **5xx Error Rate** (> 2.5%)

---

## ✅ Чек-лист сдачи

- Метрики `app24_*` экспортируются
- `ServiceMonitor` в статусе **UP**
- `PrometheusRule` создан
- Алерты срабатывают при нагрузке
- Grafana визуализирует данные

---

## 🎯 Итог

Реализована система наблюдаемости приложения с контролем **SLO** для **Варианта 24**.  
Все требования лабораторной работы выполнены.
