# Лабораторная работа №4

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №4</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Наблюдаемость и метрики</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Попов А. С.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавить экспонирование метрик в приложение, создать дашборды в Grafana для визуализации метрик и настроить алерты по SLO.

---

## Вариант №38

Параметры варианта:

- **Префикс метрик:** `app38_`
- **SLO:** 99.5%
- **p95 latency:** 250ms
- **Alert:** "5xx>1.5% за 10м"

## Метаданные студента

- **ФИО:** Попов Алексей Сергеевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220051
- **Email (учебный):** <as006416@g.bstu.by>
- **GitHub username:** LexusxdsD
- **Вариант №:** 38
- **ОС и версия:** Windows 11 21H2
- **Docker Desktop:** v4.52.0
- **kubectl:** v1.28.0
- **Helm:** v3.12.0
- **Minikube:** v1.31.0

---

## Окружение и инструменты

- **Kubernetes:** Minikube
- **Мониторинг:** kube-prometheus-stack (Prometheus + Grafana)
- **Приложение:** Python 3.11 + Flask
- **Упаковка:** Helm chart
- **Метрики:** Prometheus metrics format

---

## Структура репозитория c описанием содержимого

```
task_04/
├── src/
│   ├── app.py                      # Приложение с endpoint /metrics
│   ├── requirements.txt            # Зависимости Python
│   ├── Dockerfile                  # Docker образ
│   ├── helm/                       # Helm chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── namespace.yaml
│   │       ├── deployment.yaml
│   │       └── service.yaml
│   ├── k8s/                        # Манифесты мониторинга
│   │   ├── servicemonitor.yaml
│   │   └── prometheusrule.yaml
│   └── grafana/                    # Дашборды
│       └── dashboard-simple.json
└── doc/
    └── README.md                   # Документация
```

---

## Подробное описание выполнения

### 1. Установка kube-prometheus-stack

Установил систему мониторинга в namespace monitoring:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prom prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Проверил доступность компонентов:

```bash
kubectl get pods -n monitoring
```

### 2. Реализация метрик в приложении

Создал простое Flask-приложение с endpoint `/metrics`, которое экспонирует метрики:

- `app38_http_requests_total` - счетчик всех запросов
- `app38_http_requests_success` - счетчик успешных запросов
- `app38_http_requests_errors` - счетчик ошибок
- `app38_response_time_seconds` - средняя задержка ответа

Метрики используют префикс `app38_` согласно варианту.

### 3. Сборка и публикация образа

```bash
cd src
docker build -t mon-app-v38:latest .
```

### 4. Развертывание через Helm

Установил приложение с помощью Helm chart:

```bash
helm install as64-220051-v38-app ./src/helm
```

Проверил развертывание:

```bash
kubectl get pods -n app-as64-220051-v38
kubectl get svc -n app-as64-220051-v38
```

### 5. Настройка ServiceMonitor

Применил манифест для автоматического сбора метрик:

```bash
kubectl apply -f src/k8s/servicemonitor.yaml
```

ServiceMonitor настроен на сбор метрик с endpoint `/metrics` каждые 30 секунд.

### 6. Настройка алертов

Применил PrometheusRule с двумя алертами:

```bash
kubectl apply -f src/k8s/prometheusrule.yaml
```

Алерты:

- **HighErrorRate** - срабатывает при error rate > 1.5% в течение 10 минут
- **HighLatency** - срабатывает при задержке > 300ms в течение 5 минут

### 7. Импорт дашборда в Grafana

Открыл Grafana через port-forward:

```bash
kubectl port-forward -n monitoring svc/kube-prom-grafana 3000:80
```

Импортировал дашборд из файла `src/grafana/dashboard-simple.json`.

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с labels студента
- [✅] Helm-чарт приложения
- [✅] Endpoint /metrics с префиксом app38_
- [✅] ServiceMonitor для сбора метрик
- [✅] PrometheusRule с алертами
- [✅] Дашборд Grafana
- [✅] Метаданные в манифестах (labels)
- [❌] Полная параметризация Helm chart
- [❌] Health/Liveness/Readiness probes
- [❌] Graceful shutdown
- [❌] Несколько дашбордов (p95/p99, доступность)
- [❌] Демонстрация срабатывания алертов со скриншотами
- [❌] GitOps (Argo CD/Flux)

---

## Вывод

В работе выполнены основные задачи: создано приложение с экспонированием метрик согласно варианту, развернут kube-prometheus-stack, настроены ServiceMonitor и PrometheusRule для автоматического сбора метрик и алертинга, создан Helm chart для упаковки приложения. Освоены навыки работы с системой мониторинга Prometheus и Grafana в среде Kubernetes, изучены принципы наблюдаемости и метрик в распределенных системах.
