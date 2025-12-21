# Лабораторная работа 04

## 1) Описание
В рамках ЛР04 развернута система мониторинга Kubernetes-приложения с использованием kube-prometheus-stack (Prometheus, Grafana, Alertmanager). Приложение (Go net/http + Redis) инструментировано метриками Prometheus и экспонирует endpoint `/metrics`. Метрики автоматически собираются через ServiceMonitor. В Grafana созданы дашборды для availability/latency/errors. Настроены алерты по SLO с помощью PrometheusRule и проверено их срабатывание.

## 2) Метаданные
- ФИО: Будник Анна
- Группа: АС-64
- StudentID: 220033
- GitHub: annettebb
- Вариант: 3
- Дата: 18.12.2025

## 3) Параметры варианта
- Metrics prefix: `app03_`
- SLO availability: `99.9%`
- SLO p95 latency: `200ms` (0.2s)
- Alert: `5xx > 1% за 10m`

## 4) Архитектура наблюдаемости
[web03 app] --/metrics--> [Service] --ServiceMonitor--> [Prometheus] --> [Grafana dashboards]
                                               |
                                               +--> [Alertmanager] (alerts from PrometheusRule)

## 5) Метрики приложения
Endpoint: `GET /metrics`

Экспортируются метрики (с префиксом `app03_`):
- Counter: `app03_http_requests_total{method,status}`
- Histogram: `app03_http_request_duration_seconds_bucket{method}` (+ _sum/_count)
- Gauge: `app03_active_connections`
- Дополнительно: `app03_uptime_seconds`

Health endpoints:
- `GET /live` — liveness
- `GET /ready` — readiness (включая проверку Redis)

Для демонстрации алертов:
- `GET /error` — возвращает 500 (симуляция 5xx)
- `GET /sleep?ms=250` — задержка ответа (симуляция latency)

## 6) Установка kube-prometheus-stack
```bash
minikube start

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace

kubectl get pods -n monitoring
