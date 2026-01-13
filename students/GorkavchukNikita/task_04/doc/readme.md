# Лабораторная работа 04

## 1) Описание

В рамках ЛР04 развернута система мониторинга Kubernetes-приложения с использованием kube-prometheus-stack (Prometheus, Grafana, Alertmanager). Приложение — простейший HTTP-сервис на Go (root handler + `/metrics`), инструментировано клиентской библиотекой Prometheus и экспонирует endpoint `/metrics`. Метрики автоматически собираются через ServiceMonitor, для которых в Helm-чарте включены `serviceMonitor` и `prometheusRule`. В Grafana ожидаются дашборды по availability/latency/errors. Настроены алерты в `PrometheusRule` и проверено их срабатывание локальными нагрузочными запросами.

## 2) Метаданные

- **ФИО:** Горкавчук Никита Михайлович
- **Группа:** АС-64
- **StudentID:** 220038
- **GitHub:** Exage
- **Вариант:** 6

## 3) Метрики приложения

Endpoint: `GET /metrics` (Prometheus exposition via promhttp)

Экспортируемые метрики (с префиксом `app31_`):
- Counter: `app31_http_requests_total{code,method,path}`
- Histogram: `app31_http_request_duration_seconds_bucket{path,method}` (+ `_sum`, `_count`)

Дополнительно:
- Приложение логирует задержки и коды ответов.

Health/endpoints & тестовые маршруты:
- **GET /** — основной handler, имитирует задержку (rand 0..500ms)
- **?fail=1** — принудительно возвращает HTTP 500 (удобно для генерации 5xx)

## 4) Установка и проверка

Поднять окружение (minikube / k8s cluster):

```bash
minikube start

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Установить приложение (локально из каталога `chart`):

```bash
helm install app31 ./chart -n app31 --create-namespace
kubectl get pods -n app31
```

Проверить, что `ServiceMonitor` и `PrometheusRule` созданы в `monitoring` namespace и что Prometheus видит метрики:

```bash
kubectl get servicemonitors -n monitoring
kubectl get prometheusrules -n monitoring
# В Prometheus: проверка expression и targets
```

Откройте Grafana (через minikube или port-forward), создайте/импортируйте дашборды по availability/latency и проверьте визуализацию и историю срабатываний алертов.

## 5) Примечания

- Префикс метрик, пороги алертов и окно агрегации заданы в `chart/values.yaml` и `chart/templates/prometheusrule.yaml`.
- Для воспроизведения критерия `5xx > 2%` удобно отправлять отдельные запросы с `?fail=1` либо смешивать нормальные и фейловые запросы в скриптах нагрузки.
