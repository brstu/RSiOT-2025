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
<p align="right">Бурак И. Э.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать систему мониторинга в Kubernetes, добавить экспонирование метрик в приложение с использованием Prometheus client-библиотек.

---

### Вариант №29

**Параметры варианта:**

- Prefix метрик: `app29_`
- SLO: 99.5%
- p95 latency: 300ms
- Alert: "5xx>2% за 15м"

## Метаданные студента

- **ФИО:** Бурак Илья Эдуардович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220035
- **Email (учебный):** <as006405@g.bstu.by>
- **GitHub username:** burakillya
- **Вариант №:** 29
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

---

## Окружение и инструменты

- **Kubernetes:** Minikube
- **Мониторинг:** kube-prometheus-stack (Prometheus + Grafana)
- **Язык приложения:** Python 3.11
- **Фреймворк:** Flask
- **Библиотека метрик:** prometheus-client

---

## Структура репозитория c описанием содержимого

```
task_04/
├── src/
│   ├── app.py                    # Flask приложение с метриками
│   ├── requirements.txt          # Зависимости Python
│   ├── Dockerfile                # Образ приложения
│   └── k8s/                      # Kubernetes манифесты
│       ├── namespace.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       └── servicemonitor.yaml
└── doc/
    └── README.md                 # Документация
```

---

## Подробное описание выполнения

### 1. Установка системы мониторинга

Установка kube-prometheus-stack через Helm:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Проверка установки:

```bash
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Grafana доступна по адресу: `http://localhost:3000`

- Login: admin
- Password: prom-operator

### 2. Добавление метрик в приложение

Создано Flask-приложение с endpoint `/metrics`:

- Метрика `app29_requests_total` (Counter) - счетчик запросов
- Метрика `app29_request_duration_seconds` (Histogram) - задержка запросов
- Префикс метрик согласно варианту: `app29_`

Приложение логирует метаданные студента при старте из переменных окружения.

### 3. Сборка и публикация образа

```bash
cd src
docker build -t burakillya/task04-app:v1 .
docker push burakillya/task04-app:v1
```

### 4. Деплой приложения в Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/servicemonitor.yaml
```

Проверка деплоя:

```bash
kubectl get pods -n app-as64-220035-v29
kubectl logs -n app-as64-220035-v29 <pod-name>
```

### 5. Проверка метрик

```bash
kubectl port-forward -n app-as64-220035-v29 svc/mon-as64-220035-v29 8080:8080
curl http://localhost:8080/metrics
```

Пример вывода:

```
# HELP app29_requests_total Total requests
# TYPE app29_requests_total counter
app29_requests_total 5.0
# HELP app29_request_duration_seconds Request latency
# TYPE app29_request_duration_seconds histogram
...
```

### 6. Просмотр метрик в Prometheus

Открыть Prometheus:

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Перейти в браузере: `http://localhost:9090`

Примеры запросов:

- `app29_requests_total`
- `rate(app29_requests_total[5m])`

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с labels (org.bstu.*)
- [✅] Kubernetes манифесты (Namespace, Deployment, Service)
- [✅] ServiceMonitor для сбора метрик
- [✅] Endpoint /metrics с префиксом app29_
- [✅] Логирование STU_ID, STU_GROUP, STU_VARIANT
- [✅] Установка kube-prometheus-stack с инструкциями
- [✅] Интеграция prometheus-client в приложение

---

## Вывод

В работе выполнено внедрение системы мониторинга для Kubernetes-приложения: развернут kube-prometheus-stack, создано приложение с экспонированием метрик через endpoint `/metrics` с использованием prometheus-client, настроен ServiceMonitor для автоматического сбора метрик. Освоены навыки работы с Prometheus, интеграцией метрик в приложение и настройкой мониторинга в кластере Kubernetes.
