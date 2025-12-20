<p align="center">
Министерство образования Республики Беларусь<br>
Учреждение образования<br>
"Брестский Государственный технический университет"<br>
Кафедра ИИТ
</p>

<br><br><br>

<p align="center">
<strong>Лабораторная работа №4</strong><br>
<strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"<br>
<strong>Тема:</strong> "Наблюдаемость и метрики"
</p>

<br><br><br>

<p align="right">
<strong>Выполнил:</strong><br>
Студент 4 курса<br>
Группы АС-63<br>
Куликович И.C.<br><br>
<strong>Проверил:</strong><br>
Несюк А.Н.
</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Метаданные

| Поле               | Значение                     |
|--------------------|------------------------------|
| **ФИО**            | Куликович Иван Сергеевич     |
| **Группа**         | АС-63                        |
| **StudentID**      | 220015                       |
| **Email**          |`AS006312@g.bstu.by`          |
| **GitHub**         | ваш-username                 |
| **Вариант**        | 11                           |
| **Дата**           | 11-29-2025                   |
| **ОС**             | Ubuntu 22.04 / Windows 10 pro|
| **Docker**         | 28.3.2                       |
| **Kubernetes**     | v1.37.0 (minikube)           |
| **Helm**           | v3.12.2                      |

---

## Архитектура мониторинга

```mermaid
graph LR
    Application[Application<br>(app:8080)<br>/metrics] --> Prometheus[Prometheus<br>(Scrape)<br>+ Rules]
    Prometheus --> Grafana[Grafana<br>(Dashboards)]
    Prometheus --> Alertmanager[Alertmanager<br>(Notifications)]
```

---

## Инструкция по установке

### 1. Подготовка кластера

```bash
minikube start --memory=4096 --cpus=4
kubectl create namespace monitoring
kubectl create namespace app-monitoring
```

### 2. Установка `kube-prometheus-stack`

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f monitoring-setup/kube-prometheus-values.yaml
```

### 3. Сборка и публикация образа приложения

```bash
cd app
docker build -t kulikovich/app11-app:v1.0.0 .
docker push kulikovich/app11-app:v1.0.0
```

### 4. Установка приложения через Helm

```bash
cd helm/app11-monitoring
helm lint .
helm template . --debug
helm install app11-app . -n app-monitoring
```

### 5. Проверка установки

```bash
# Проверка подов
kubectl get pods -n app-monitoring
kubectl get pods -n monitoring

# Доступ к Grafana
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring &
# Логин: admin / admin123

# Доступ к Prometheus
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring &

# Проверка метрик
kubectl port-forward svc/app11-monitoring 8080:8080 -n app-monitoring &
curl http://localhost:8080/metrics
```

---

## Метрики приложения

Приложение экспортирует метрики с префиксом `app11_`:

| Метрика                                      | Тип         | Описание                                      |
|----------------------------------------------|-------------|-----------------------------------------------|
| `app11_http_requests_total`                  | Counter     | Счетчик HTTP запросов                         |
| `app11_http_request_duration_seconds`        | Histogram   | Гистограмма задержек                          |
| `app11_active_connections`                   | Gauge       | Количество активных соединений                |
| `app11_http_5xx_errors_total`                | Counter     | Счетчик 5xx ошибок                            |

---

## Дашборды Grafana

Созданы 3 дашборда:

1. **Availability Dashboard** — доступность сервиса (SLO: 99.5%)
2. **Latency Dashboard** — задержка P95 (SLO: 200ms)
3. **Error Rate Dashboard** — частота 5xx ошибок (Alert: >1% за 5м)

---

## Алерты PrometheusRule

Настроены алерты согласно варианту:

| Алерт                          | Условие                                      |
|--------------------------------|----------------------------------------------|
| `App11HighErrorRate`           | Срабатывает при 5xx > 1% за 5 минут          |
| `App11HighLatency`             | Срабатывает при P95 > 200ms                  |
| `App11LowAvailability`         | Срабатывает при доступности < 99.5%          |

---

## Тестирование алертов

```bash
# Генерация нагрузки для теста алертов
for i in {1..100}; do
  curl http://localhost:8080/slow &
  curl http://localhost:8080/ &
done

# Проверка алертов в Prometheus
# Откройте http://localhost:9090/alerts
```

---

## GitOps с Argo CD (опционально)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f gitops/app11-application.yaml

# Доступ к Argo CD
kubectl port-forward svc/argocd-server 8081:443 -n argocd
# Пароль: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Выводы

В ходе выполнения лабораторной работы были реализованы:

1. **Мониторинг приложения** с использованием `Prometheus` и `Grafana`.
2. **Экспорт метрик** с префиксом `app11_`.
3. **Настройка алертов** для контроля SLO.
4. **Дашборды Grafana** для визуализации метрик.
5. **GitOps** с использованием `Argo CD` (опционально).

Все компоненты работают корректно, алерты срабатывают при нарушении SLO, а метрики доступны для анализа.
