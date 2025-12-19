# Лабораторная работа №04

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №04</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Наблюдаемость и метрики</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Филипчук Д. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться добавлять экспонирование метрик в приложение с использованием client-библиотек Prometheus и создавать ServiceMonitor для автоматического сбора метрик.

---

### Вариант №22

**Параметры варианта:**

- prefix = `app22_`
- slo = 99.0%
- p95 = 250ms
- alert = "5xx>1.5% за 5м"

## Метаданные студента

- **ФИО:** Филипчук Дмитрий Васильевич
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220027
- **Email (учебный):** <as006327@g.bstu.by>
- **GitHub username:** kuddel11
- **Вариант №:** 22
- **ОС и версия:** Windows 11 24H2, Docker Desktop v4.53.0

---

## Окружение и инструменты

- **ОС:** Windows 11 24H2
- **Docker Desktop:** v4.53.0
- **Python:** 3.11
- **Flask:** 3.0.0
- **prometheus-client:** 0.19.0
- **Kubernetes:** Minikube
- **Helm:** v3.x
- **kube-prometheus-stack:** для мониторинга

## Структура репозитория c описанием содержимого

```
task_04/
├── src/                          # Исходный код
│   ├── app/
│   │   ├── main.py              # Flask приложение с метриками
│   │   └── requirements.txt     # Python зависимости
│   ├── k8s/                     # Kubernetes манифесты
│   │   ├── namespace.yaml       # Namespace для приложения
│   │   ├── deployment.yaml      # Deployment с метаданными
│   │   ├── service.yaml         # Service для приложения
│   │   └── servicemonitor.yaml  # ServiceMonitor для Prometheus
│   └── Dockerfile               # Образ приложения
└── doc/
    └── README.md                # Документация
```

## Подробное описание выполнения

### 1. Создание приложения с метриками

Создано Flask приложение с endpoint `/metrics` и префиксом метрик `app22_`:

**Реализованные метрики:**

- `app22_http_requests_total` - счетчик HTTP запросов (Counter)
- `app22_http_request_duration_seconds` - гистограмма задержек запросов (Histogram)
- `app22_service_status` - статус сервиса (Gauge)

Приложение логирует переменные окружения при старте:

```
[STARTUP] Student ID: 220027, Group: АС-63, Variant: 22
```

### 2. Подготовка Docker образа

Dockerfile содержит все необходимые метаданные студента:

```dockerfile
LABEL org.bstu.student.fullname="Филипчук Дмитрий Васильевич"
LABEL org.bstu.student.id="220027"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="22"
```

**Сборка и публикация:**

```bash
cd src
docker build -t kuddel11/app22-metrics:latest .
docker push kuddel11/app22-metrics:latest
```

### 3. Установка kube-prometheus-stack

Добавление Helm репозитория и установка:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```

Проверка установки:

```bash
kubectl get pods -n monitoring
```

### 4. Развертывание приложения в Kubernetes

Создание namespace и развертывание:

```bash
kubectl apply -f src/k8s/namespace.yaml
kubectl apply -f src/k8s/deployment.yaml
kubectl apply -f src/k8s/service.yaml
kubectl apply -f src/k8s/servicemonitor.yaml
```

Проверка работы:

```bash
kubectl get pods -n app-as63-220027-v22
kubectl port-forward -n app-as63-220027-v22 svc/mon-as63-220027-v22-svc 8080:8080
```

Проверка метрик:

```bash
curl http://localhost:8080/metrics
```

### 5. Настройка ServiceMonitor

ServiceMonitor настроен для автоматического обнаружения метрик Prometheus. Он скрейпит endpoint `/metrics` каждые 30 секунд.

Проверка в Prometheus UI:

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-prometheus 9090:9090
```

В Prometheus можно проверить метрики:

- `app22_http_requests_total`
- `app22_http_request_duration_seconds`
- `app22_service_status`

### 6. Доступ к Grafana

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

Логин: admin
Пароль можно получить:

```bash
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d
```

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с метаданными (labels)
- [✅] Kubernetes манифесты (namespace, deployment, service)
- [✅] ServiceMonitor для сбора метрик
- [✅] Приложение с endpoint /metrics и префиксом app22_
- [✅] Базовые метрики: Counter, Histogram, Gauge
- [✅] Health проверки (liveness, readiness)
- [✅] Переменные окружения STU_ID, STU_GROUP, STU_VARIANT

---

## Вывод

В ходе работы было создано простое Flask приложение с интеграцией Prometheus метрик. Реализован endpoint `/metrics` с префиксом `app22_` согласно варианту. Настроен ServiceMonitor для автоматического сбора метрик в Prometheus.

Приложение успешно развернуто в Kubernetes с использованием стандартных манифестов. Все метаданные студента корректно добавлены в labels и переменные окружения.

**Освоенные навыки:**

- Интеграция Prometheus client библиотеки в Python приложение
- Создание и экспонирование метрик (Counter, Histogram, Gauge)
- Развертывание kube-prometheus-stack в Kubernetes
- Настройка ServiceMonitor для автоматического обнаружения метрик
- Работа с метаданными в Kubernetes манифестах

**Дополнительные возможности для улучшения:**

- Создание Helm чарта для упрощения развертывания
- Настройка готовых дашбордов в Grafana
- Добавление PrometheusRule для алертов по SLO
- Интеграция GitOps подхода
