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
<p align="right">Кульбеда К. А.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Нёсюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавить экспонирование метрик в приложение с использованием client-библиотек Prometheus, упаковать приложение в Helm-чарт.

---

### Вариант №12

**Параметры варианта:**

- Префикс метрик: `app12_`
- SLO: 99.9%
- p95 latency: 350ms
- Alert: "5xx>2.5% за 10м"

## Метаданные студента

- **ФИО:** Кульбеда Кирилл Александрович
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220016
- **Email (учебный):** <as006313@g.bstu.by>
- **GitHub username:** fr0ogi
- **Вариант №:** 12
- **ОС и версия:** Windows 11 23H2

---

## Окружение и инструменты

- **Docker Desktop:** v4.52.0
- **Python:** 3.11
- **Flask:** 3.0.0
- **prometheus-client:** 0.19.0
- **Kubernetes:** (для разворачивания через Minikube/Kind)
- **Helm:** 3.x (для упаковки приложения в чарт)

---

## Структура репозитория c описанием содержимого

```
task_04/
├── src/                           # Исходный код приложения
│   ├── app.py                     # Flask приложение с метриками
│   ├── requirements.txt           # Python зависимости
│   ├── Dockerfile                 # Образ приложения с метаданными
│   ├── install-prometheus.sh      # Скрипт установки kube-prometheus-stack
│   ├── helm/                      # Helm чарт приложения
│   │   ├── Chart.yaml             # Описание чарта
│   │   ├── values.yaml            # Значения по умолчанию
│   │   └── templates/
│   │       ├── deployment.yaml    # Deployment с метаданными
│   │       └── service.yaml       # Service
│   └── k8s/                       # Kubernetes манифесты
│       ├── namespace.yaml         # Namespace для приложения
│       └── servicemonitor.yaml    # ServiceMonitor для Prometheus
└── doc/
    └── README.md                  # Документация (этот файл)
```

---

## Подробное описание выполнения

### 1. Создание приложения с метриками

Разработано Flask приложение с endpoint `/metrics` для экспонирования метрик Prometheus. Приложение содержит:

- Счетчик запросов (`app12_requests_total`)
- Гистограмму задержек (`app12_request_duration_seconds`)
- Gauge для активных запросов (`app12_active_requests`)

Все метрики используют префикс `app12_` согласно варианту.

**Файл:** [src/app.py](../src/app.py)

### 2. Dockerfile с метаданными

Создан Dockerfile для сборки образа приложения. В него добавлены labels с метаданными студента:

- `org.bstu.student.fullname`
- `org.bstu.student.id`
- `org.bstu.group`
- `org.bstu.variant`
- `org.bstu.course`
- `org.bstu.owner`
- `org.bstu.student.slug`

**Файл:** [src/Dockerfile](../src/Dockerfile)

### 3. Helm чарт приложения

Создан Helm чарт с параметризацией:

- `Chart.yaml` - метаданные чарта
- `values.yaml` - значения по умолчанию (replicas, image, namespace, метаданные студента)
- `templates/deployment.yaml` - Deployment с labels метаданных
- `templates/service.yaml` - Service для доступа к приложению

**Каталог:** [src/helm/](../src/helm/)

### 4. ServiceMonitor для сбора метрик

Создан манифест ServiceMonitor для автоматического обнаружения и сбора метрик Prometheus:

- Selector по label `app: mon-as63-220016-v12`
- Endpoint `/metrics` на порту `http`
- Интервал сбора: 30 секунд

**Файл:** [src/k8s/servicemonitor.yaml](../src/k8s/servicemonitor.yaml)

### 5. Инструкции по установке kube-prometheus-stack

Подготовлен скрипт с командами для установки системы мониторинга:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
```

**Файл:** [src/install-prometheus.sh](../src/install-prometheus.sh)

---

## Контрольный список (checklist)

- [ ✅ ] README с полными метаданными студента
- [ ✅ ] Flask приложение с endpoint /metrics
- [ ✅ ] Метрики с префиксом app12_ (Counter, Histogram, Gauge)
- [ ✅ ] Dockerfile с labels метаданных
- [ ✅ ] Helm чарт с параметризацией
- [ ✅ ] ServiceMonitor для автоматического сбора метрик
- [ ✅ ] Namespace с уникальным именем (app-as63-220016-v12)
- [ ✅ ] Именование ресурсов с префиксом mon-<slug>
- [ ✅ ] ENV переменные (STU_ID, STU_GROUP, STU_VARIANT) логируются при старте
- [ ❌ ] Установка и настройка Grafana (не выполнено)
- [ ❌ ] Создание дашбордов в Grafana (не выполнено)
- [ ❌ ] Настройка PrometheusRule с алертами (не выполнено)
- [ ❌ ] GitOps (Argo CD/Flux) (не выполнено)

---

## Вывод

В ходе лабораторной работы была выполнена интеграция системы мониторинга для Kubernetes-приложения:

1. Создано Flask приложение с endpoint `/metrics` и метриками Prometheus (счетчик запросов, гистограмма задержек, gauge активных запросов).
2. Разработан Dockerfile с полными метаданными студента в labels.
3. Упаковано приложение в Helm чарт с параметризацией.
4. Создан ServiceMonitor для автоматического обнаружения и сбора метрик.
5. Подготовлены инструкции по установке kube-prometheus-stack.

Освоены навыки работы с Prometheus client библиотеками, Helm charts и ServiceMonitor для сбора метрик в Kubernetes.
