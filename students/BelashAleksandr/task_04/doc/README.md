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
<p align="right">Белаш А. О.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавить экспонирование метрик в приложение и создать базовые дашборды для визуализации метрик.

---

### Вариант №25

**Параметры варианта:**

- Префикс метрик: `app25_`
- SLO: 99.0%
- p95 latency: 300ms
- Alert условие: "5xx>2% за 10м"

## Метаданные студента

- **ФИО:** Белаш Александр Олегович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220031
- **Email (учебный):** <as006401@g.bstu.by>
- **GitHub username:** went2smoke
- **Вариант №:** 25
- **ОС и версия:** Windows 10 1891, Docker Desktop v4.52.0

---

## Окружение и инструменты

В данной лабораторной работе использовались следующие инструменты:

- **Docker Desktop:** v4.52.0
- **Kubernetes:** через Minikube/Docker Desktop
- **Helm:** v3.x
- **Python:** 3.11
- **Flask:** для создания веб-приложения
- **prometheus-client:** библиотека для экспонирования метрик
- **kube-prometheus-stack:** для развертывания Prometheus и Grafana

## Структура репозитория c описанием содержимого

```
task_04/
├── doc/
│   └── README.md                      # Документация
├── src/
    ├── app/
    │   ├── app.py                     # Flask приложение с метриками
    │   └── requirements.txt           # Зависимости Python
    ├── Dockerfile                     # Образ приложения
    ├── helm/                          # Helm чарт
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/
    │       ├── namespace.yaml
    │       ├── deployment.yaml
    │       └── service.yaml
    └── k8s/
        ├── prometheus-install.md      # Инструкция по установке Prometheus
        ├── servicemonitor.yaml        # ServiceMonitor для сбора метрик
        └── dashboard-basic.json       # Базовый дашборд Grafana
```

## Подробное описание выполнения

### 1. Установка системы мониторинга

Для установки kube-prometheus-stack использовался Helm:

```bash
# Добавление репозитория
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Установка в namespace monitoring
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

Проверка установки:

```bash
kubectl get pods -n monitoring
```

Доступ к Grafana через port-forward:

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
```

Логин: `admin`, пароль можно получить командой:

```bash
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### 2. Добавление метрик в приложение

Создано Flask приложение с endpoint `/metrics` и метриками с префиксом `app25_`:

- `app25_requests_total` - счетчик запросов
- `app25_request_duration_seconds` - гистограмма задержек
- `app25_status` - gauge для статуса приложения

Приложение логирует метаданные студента при старте (STU_ID, STU_GROUP, STU_VARIANT).

### 3. Сборка Docker образа

```bash
cd src
docker build -t lab04-app:latest .
```

### 4. Упаковка в Helm чарт

Создан базовый Helm чарт с минимальной параметризацией:

```bash
cd src/helm
helm lint .
helm template . > rendered.yaml
```

Установка через Helm:

```bash
helm install as64-220031-v25-app ./helm
```

### 5. Создание ServiceMonitor

Создан ServiceMonitor для автоматического обнаружения метрик приложения:

```bash
kubectl apply -f src/k8s/servicemonitor.yaml
```

### 6. Создание дашборда в Grafana

Импортирован базовый дашборд из `src/k8s/dashboard-basic.json`, который отображает общее количество запросов.

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с labels метаданных студента
- [✅] Helm чарт приложения
- [✅] Инструкция по установке kube-prometheus-stack
- [✅] Приложение с endpoint /metrics
- [✅] Метрики с префиксом app25_
- [✅] ServiceMonitor для сбора метрик
- [✅] Базовый дашборд Grafana
- [❌] PrometheusRule с алертами
- [❌] Расширенная параметризация Helm чарта
- [❌] Ingress
- [❌] Resources limits/requests

---

## Вывод

В ходе выполнения лабораторной работы была развернута базовая система мониторинга с использованием kube-prometheus-stack. Создано простое Flask приложение с экспонированием метрик Prometheus с префиксом согласно варианту (app25_). Реализован минимальный Helm чарт для развертывания приложения в Kubernetes с базовыми метаданными студента. Создан ServiceMonitor для автоматического сбора метрик и простой дашборд в Grafana.

**Освоенные навыки:**

- Установка Prometheus и Grafana через Helm
- Интеграция prometheus-client в Python приложение
- Создание Helm чарта с templates
- Работа с ServiceMonitor
- Основы создания дашбордов в Grafana

**Возможные направления для дальнейшего развития:**

- Настройка алертов по SLO (PrometheusRule)
- Расширенная параметризация Helm чарта
- Создание дополнительных дашбордов (availability, latency p95/p99, error rate)
- Настройка Ingress для внешнего доступа
- Внедрение GitOps подхода с Argo CD/Flux
