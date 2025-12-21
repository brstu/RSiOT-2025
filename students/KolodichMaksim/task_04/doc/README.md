# Лабораторная работа 04

## 1) Описание

В рамках ЛР04 развернута система мониторинга Kubernetes-приложения с использованием kube-prometheus-stack (Prometheus, Grafana, Alertmanager). Приложение — простейший HTTP-сервис на Go (root handler + `/metrics`), инструментировано клиентской библиотекой Prometheus и экспонирует endpoint `/metrics`. Метрики автоматически собираются через ServiceMonitor, для которых в Helm-чарте включены `serviceMonitor` и `prometheusRule`. В Grafana ожидаются дашборды по availability/latency/errors. Настроены алерты в `PrometheusRule` и проверено их срабатывание локальными нагрузочными запросами.

## 2) Метаданные

- **ФИО:** Колодич Максим Павлович
- **Группа:** АС-63
- **StudentID:** 220013
- **GitHub:** proxladno
- **Вариант:** 9
- **Дата:** 21.12.2025

## 3) Параметры варианта

- **Metrics prefix:** `app09_`
- **SLO availability:** `99.9%`
- **SLO p95 latency:** `300ms` (0.3s)
- **Alert:** `5xx > 2% за 5m`

(подтверждается файлом `tasks/task_04/Варианты.md` и `chart/templates/prometheusrule.yaml`)

## 4) Архитектура наблюдаемости

`[app09] --/metrics--> [Service] --ServiceMonitor--> [Prometheus] --> [Grafana dashboards]
                                               |
                                               +--> [Alertmanager] (alerts из PrometheusRule)

## 5) Метрики приложения

Endpoint: `GET /metrics` (Prometheus exposition via promhttp)

Экспортируемые метрики (с префиксом `app09_`):
- Counter: `app09_http_requests_total{code,method,path}`
- Histogram: `app09_http_request_duration_seconds_bucket{path,method}` (+ `_sum`, `_count`)

Дополнительно:
- Приложение логирует задержки и коды ответов.

Health/endpoints & тестовые маршруты:
- **GET /** — основной handler, имитирует задержку (rand 0..500ms)
- **?fail=1** — принудительно возвращает HTTP 500 (удобно для генерации 5xx)

Для демонстрации алертов:
- Генерация 5xx: `for i in {1..100}; do curl -s "http://<svc>:8080/?fail=1" >/dev/null; done`
- Нагрузка для повышения p95: `wrk`/`hey`/скрипт с параллельными запросами к `/` (тайминги случайно доходят до 500ms, p95 может превысить 300ms при достаточном объёме)

## 6) Установка и проверка

1. Поднять окружение (minikube / k8s cluster):

```bash
minikube start

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

1. Установить приложение (локально из каталога `chart`):

```bash
helm install app09 ./chart -n app09 --create-namespace
kubectl get pods -n app09
```

1. Проверить, что `ServiceMonitor` и `PrometheusRule` созданы в `monitoring` namespace и что Prometheus видит метрики:

```bash
kubectl get servicemonitors -n monitoring
kubectl get prometheusrules -n monitoring
# В Prometheus: проверка expression и targets
```

1. Откройте Grafana (через minikube или port-forward), создайте/импортируйте дашборды по availability/latency и проверьте визуализацию и историю срабатываний алертов.

## 7) Примечания

- Префикс метрик, пороги алертов и окно агрегации заданы в `chart/values.yaml` и `chart/templates/prometheusrule.yaml`.
- Для воспроизведения критерия `5xx > 2%` удобно отправлять отдельные запросы с `?fail=1` либо смешивать нормальные и фейловые запросы в скриптах нагрузки.
