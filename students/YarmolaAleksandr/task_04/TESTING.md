# Инструкции по проверке Lab 04

## ✅ Статус установки

Все компоненты успешно установлены и работают:

- ✅ Minikube запущен
- ✅ kube-prometheus-stack установлен в namespace `monitoring`
- ✅ monitoring-app установлен в namespace `monitoring-app` (2 реплики)
- ✅ ServiceMonitor создан и собирает метрики каждые 30 секунд
- ✅ PrometheusRule создан с 3 алертами
- ✅ Метрики `app23_*` экспортируются успешно

## 🔐 Доступ к Grafana

**URL:** http://localhost:3000
**Login:** admin
**Password:** s5jn5b37lzXKU7LUBfheMovpdEvQJWXyoIESsN5C

Команда для port-forward:
```powershell
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

## 📊 Доступ к Prometheus

**URL:** http://localhost:9090

Команда для port-forward:
```powershell
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
```

## 🧪 Генерация тестового трафика

### 1. Нормальная нагрузка (background)

Запустите в отдельном терминале:

```powershell
kubectl port-forward svc/monitoring-app 8080:80 -n monitoring-app
```

Затем в другом терминале:

```powershell
# Нормальные запросы к /api/data (задержка 10-250ms)
while ($true) {
    try {
        Invoke-WebRequest -Uri http://localhost:8080/api/data -UseBasicParsing | Out-Null
        Start-Sleep -Milliseconds 200
    } catch {}
}
```

### 2. Триггер алерта HighLatencyP95 (p95 > 200ms)

Запросы к /api/slow (задержка 200-400ms):

```powershell
while ($true) {
    try {
        Invoke-WebRequest -Uri http://localhost:8080/api/slow -UseBasicParsing | Out-Null
        Start-Sleep -Milliseconds 100
    } catch {}
}
```

### 3. Триггер алерта HighErrorRate5xx (5xx > 1%)

Запросы к /api/error (50% вероятность 500 ошибки):

```powershell
while ($true) {
    try {
        Invoke-WebRequest -Uri http://localhost:8080/api/error -UseBasicParsing | Out-Null
    } catch {}
    Start-Sleep -Milliseconds 100
}
```

## 📈 Проверка метрик в Prometheus

1. Откройте Prometheus UI: http://localhost:9090
2. Проверьте Status → Targets
3. Найдите target `monitoring-app/monitoring-app-monitoring-app`
4. Убедитесь, что Status = UP

### Тестовые запросы в Prometheus:

#### Rate запросов

```promql
rate(app23_http_requests_total[5m])
```

#### Доступность (SLO 99.5%)

```promql
(sum(rate(app23_http_requests_total{status!~"5.."}[5m])) / sum(rate(app23_http_requests_total[5m]))) * 100
```

#### p95 latency (SLO ≤200ms)

```promql
histogram_quantile(0.95, sum(rate(app23_http_request_duration_seconds_bucket[5m])) by (le))
```

#### Error rate 5xx

```promql
(sum(rate(app23_http_requests_total{status=~"5.."}[5m])) / sum(rate(app23_http_requests_total[5m]))) * 100
```

## 🚨 Проверка алертов

1. Откройте Prometheus Alerts: http://localhost:9090/alerts
2. Проверьте наличие алертов:
   - **LowAvailability** (critical)
   - **HighErrorRate5xx** (warning)
   - **HighLatencyP95** (warning)

Алерты должны иметь состояние:
- **Inactive** - условие не выполняется (нормально)
- **Pending** - условие выполняется менее 5 минут
- **Firing** - условие выполняется более 5 минут

## 📊 Создание дашбордов в Grafana

### Dashboard 1: Availability

1. Откройте Grafana → Create → Dashboard
2. Add visualization
3. Query:
   ```promql
   (sum(rate(app23_http_requests_total{status!~"5.."}[5m])) / sum(rate(app23_http_requests_total[5m]))) * 100
   ```
4. Title: "Availability (SLO 99.5%)"
5. Add threshold: Value = 99.5, Mode = Base

### Dashboard 2: Latency p95

1. Add new panel
2. Query:
   ```promql
   histogram_quantile(0.95, sum(rate(app23_http_request_duration_seconds_bucket[5m])) by (le))
   ```
3. Title: "p95 Latency (SLO ≤200ms)"
4. Unit: seconds (s)
5. Add threshold: Value = 0.2, Mode = Base

### Dashboard 3: Error Rate

1. Add new panel
2. Query:
   ```promql
   (sum(rate(app23_http_requests_total{status=~"5.."}[5m])) / sum(rate(app23_http_requests_total[5m]))) * 100
   ```
3. Title: "5xx Error Rate (Alert >1%)"
4. Unit: percent (0-100)
5. Add threshold: Value = 1, Mode = Base

## ✅ Чек-лист для сдачи

- [ ] Minikube запущен
- [ ] kube-prometheus-stack установлен и работает
- [ ] monitoring-app деплоится с 2 репликами
- [ ] Метрики app23_* доступны на /metrics
- [ ] ServiceMonitor собирает метрики (проверить в Prometheus Targets)
- [ ] PrometheusRule создан с 3 алертами
- [ ] Grafana доступен (admin / s5jn5b37lzXKU7LUBfheMovpdEvQJWXyoIESsN5C)
- [ ] Созданы 3 дашборда: Availability, Latency, Error Rate
- [ ] Алерты срабатывают при генерации соответствующего трафика
- [ ] Документация заполнена в doc/README.md
- [ ] Скриншоты добавлены (Grafana dashboards, Prometheus targets, firing alerts)

## 🔧 Полезные команды

```powershell
# Проверка статуса
kubectl get all -n monitoring-app
kubectl get servicemonitor,prometheusrule -n monitoring-app

# Логи приложения
kubectl logs -f -l app=monitoring-app -n monitoring-app

# Перезапуск приложения
kubectl rollout restart deployment/monitoring-app -n monitoring-app

# Проверка метрик напрямую
kubectl port-forward svc/monitoring-app 8080:80 -n monitoring-app
Invoke-WebRequest http://localhost:8080/metrics -UseBasicParsing

# Очистка (если нужно переустановить)
$env:Path = "$env:LOCALAPPDATA\helm;$env:Path"
helm uninstall monitoring-app -n monitoring-app
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring monitoring-app
```

## 📌 Параметры варианта 23

- **Префикс метрик:** app23_
- **SLO Availability:** 99.5%
- **SLO p95 Latency:** ≤200ms
- **Alert условие:** 5xx > 1% за 5 минут

## 🎯 Ожидаемые результаты

При нормальной нагрузке:
- Availability: ~100%
- p95 latency: 50-150ms
- Error rate: ~0%
- Алерты: Inactive

При триггере /api/slow:
- p95 latency: >200ms
- Alert HighLatencyP95: Pending → Firing (через 5 минут)

При триггере /api/error:
- Error rate: ~50%
- Alert HighErrorRate5xx: Pending → Firing (через 5 минут)
