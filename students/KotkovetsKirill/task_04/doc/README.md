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
<p align="right">Группы АС-64</p>
<p align="right">Котковец К. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавить экспонирование метрик в приложение и настроить базовые алерты.

---

### Вариант №35

**Параметры варианта:**

- Prefix метрик: `app35_`
- SLO: 99.5%
- P95: 200ms
- Alert: "5xx>1% за 5м"

## Метаданные студента

- **ФИО:** Котковец Кирилл Викторович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220044
- **Email (учебный):** <as006412@g.bstu.by>
- **GitHub username:** Kirill-Kotkovets
- **Вариант №:** 35
- **ОС и версия:** Windows 11 21H3
- **Docker Desktop:** v4.53.0
- **kubectl:** v1.29.0
- **Helm:** v3.14.0
- **Minikube:** v1.32.0

---

## Окружение и инструменты

- **Python 3.11** - язык программирования для приложения
- **Flask** - веб-фреймворк
- **prometheus-client** - библиотека для экспонирования метрик
- **Docker** - контейнеризация приложения
- **Kubernetes (Minikube)** - оркестрация контейнеров
- **Prometheus** - система мониторинга и сбора метрик
- **Grafana** - визуализация метрик
- **kube-prometheus-stack** - Helm-чарт для развертывания стека мониторинга

## Структура репозитория c описанием содержимого

```
task_04/
├── src/                          # Исходный код и манифесты
│   ├── app.py                    # Flask приложение с метриками
│   ├── requirements.txt          # Python зависимости
│   ├── Dockerfile                # Образ приложения с метаданными
│   ├── namespace.yaml            # Namespace для приложения
│   ├── deployment.yaml           # Deployment с labels
│   ├── service.yaml              # Service для доступа к приложению
│   └── prometheus-rule.yaml      # PrometheusRule с алертом
└── doc/
    └── README.md                 # Документация
```

---

## Подробное описание выполнения

### 1. Установка системы мониторинга

#### 1.1. Добавление Helm-репозитория и установка kube-prometheus-stack

```bash
# Добавляем репозиторий prometheus-community
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Создаем namespace для мониторинга
kubectl create namespace monitoring

# Устанавливаем kube-prometheus-stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

#### 1.2. Проверка установки

```bash
# Проверяем поды в namespace monitoring
kubectl get pods -n monitoring

# Проверяем сервисы
kubectl get svc -n monitoring
```

#### 1.3. Доступ к Grafana

```bash
# Port-forward для доступа к Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

**Учетные данные Grafana:**

- URL: <http://localhost:3000>
- Username: admin
- Password: prom-operator (по умолчанию)

### 2. Добавление метрик в приложение

#### 2.1. Структура приложения

Приложение реализовано на Flask с использованием библиотеки `prometheus-client`. Основные компоненты:

**Метрики с префиксом app35_:**

- `app35_requests_total` - счетчик запросов (Counter) с labels: method, endpoint, status
- `app35_request_duration_seconds` - гистограмма задержек запросов (Histogram)
- `app35_active_connections` - текущее количество активных соединений (Gauge)

**Endpoints:**

- `/` - главная страница приложения
- `/metrics` - Prometheus метрики
- `/health` - health check для probes
- `/error` - endpoint для симуляции 5xx ошибок

#### 2.2. Логирование метаданных при старте

При запуске контейнер логирует метаданные:

```
STU_ID: 220044
STU_GROUP: АС-64
STU_VARIANT: 35
```

### 3. Развертывание приложения в Kubernetes

#### 3.1. Сборка и публикация Docker образа

```bash
# Переход в директорию с исходниками
cd src

# Сборка образа
docker build -t kirill-kotkovets/app35:latest .

# Публикация в Docker Hub (опционально)
docker push kirill-kotkovets/app35:latest
```

#### 3.2. Применение манифестов

```bash
# Создаем namespace
kubectl apply -f namespace.yaml

# Применяем deployment и service
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Проверяем развертывание
kubectl get pods -n app-as64-220044-v35
kubectl get svc -n app-as64-220044-v35
```

#### 3.3. Проверка метрик

```bash
# Port-forward для доступа к приложению
kubectl port-forward -n app-as64-220044-v35 svc/mon-as64-220044-v35-service 8080:8080

# Проверка endpoint метрик
curl http://localhost:8080/metrics
```

Пример вывода метрик:

```
# HELP app35_requests_total Total requests
# TYPE app35_requests_total counter
app35_requests_total{endpoint="/",method="GET",status="200"} 5.0
# HELP app35_request_duration_seconds Request duration
# TYPE app35_request_duration_seconds histogram
app35_request_duration_seconds_bucket{le="0.005"} 0.0
app35_request_duration_seconds_bucket{le="+Inf"} 5.0
# HELP app35_active_connections Active connections
# TYPE app35_active_connections gauge
app35_active_connections 0.0
```

### 4. Настройка алертов по SLO

#### 4.1. Применение PrometheusRule

```bash
# Применяем правило алерта
kubectl apply -f prometheus-rule.yaml

# Проверяем создание правила
kubectl get prometheusrules -n monitoring
```

#### 4.2. Описание алерта

**Alert:** High5xxErrorRate

- **Условие:** Частота 5xx ошибок > 1% в течение 5 минут
- **Severity:** warning
- **Описание:** Соответствует требованиям варианта 35

#### 4.3. Симуляция ошибок для тестирования алерта

```bash
# Генерируем 5xx ошибки
for i in {1..100}; do curl http://localhost:8080/error; done
```

### 5. Создание дашборда в Grafana

Для визуализации метрик рекомендуется создать дашборд в Grafana:

1. Открыть Grafana (<http://localhost:3000>)
2. Войти под учетными данными (admin/prom-operator)
3. Создать новый Dashboard
4. Добавить панель с запросом: `rate(app35_requests_total[5m])` для отслеживания частоты запросов
5. Добавить панель для метрики ошибок: `app35_requests_total{status="500"}`

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с LABEL метаданными
- [✅] Flask приложение с endpoint /metrics
- [✅] Метрики с префиксом app35_ (Counter, Histogram, Gauge)
- [✅] Kubernetes манифесты (Namespace, Deployment, Service)
- [✅] Health/Liveness/Readiness probes
- [✅] PrometheusRule с алертом по 5xx ошибкам
- [✅] Логирование STU_ID, STU_GROUP, STU_VARIANT при старте
- [✅] Именование ресурсов с префиксом mon- и slug
- [✅] Система мониторинга kube-prometheus-stack

---

## Инструкции по запуску

### Полный цикл развертывания

1. **Запуск Minikube:**

```bash
minikube start
```

1. **Установка kube-prometheus-stack:**

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
```

1. **Развертывание приложения:**

```bash
cd src
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f prometheus-rule.yaml
```

1. **Проверка работы:**

```bash
# Проверка подов
kubectl get pods -n app-as64-220044-v35

# Доступ к метрикам
kubectl port-forward -n app-as64-220044-v35 svc/mon-as64-220044-v35-service 8080:8080
curl http://localhost:8080/metrics

# Доступ к Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

---

## Вывод

В ходе лабораторной работы было реализовано приложение для системы мониторинга в Kubernetes. Получены практические навыки в следующих областях:

1. **Flask приложение с метриками** - успешно реализован endpoint `/metrics` и базовые метрики счетчика, гистограммы и gauge с префиксом `app35_`
2. **Kubernetes развертывание** - настроено развертывание приложения через Deployment и Service с корректными labels и проверками здоровья (liveness/readiness)
3. **Метаданные и организация** - добавлены метаданные студента в Dockerfile и все манифесты согласно требованиям
4. **Система алертирования** - создана PrometheusRule для отслеживания критических метрик по 5xx ошибкам в соответствии с параметрами варианта
5. **Документирование** - подготовлены подробные инструкции по развертыванию и использованию kube-prometheus-stack

Работа демонстрирует понимание основных концепций наблюдаемости систем в контексте облачных технологий и Kubernetes-приложений.
