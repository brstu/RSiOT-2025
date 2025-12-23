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
<p align="right">Крагель А.М.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Нёсюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавить экспонирование метрик в приложение с использованием client-библиотек Prometheus, упаковать приложение в Helm-чарт.

---

### Вариант №10

**Параметры варианта:**

- Префикс метрик: `app12_`
- SLO: 99.9%
- p95 latency: 350ms
- Alert: "5xx>2.5% за 10м"

## Метаданные студента

- **ФИО:** Крагель Алина Максимовна
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220046
- **Email (учебный):** <as006427@g.bstu.by>
- **GitHub username:** Alina529
- **Вариант №:** 10
- **ОС и версия:** Windows 10

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
├── src/                           
│   ├── prometheus-values.yaml   
│   ├── helm/                      
│   │   ├── Chart.yaml             
│   │   ├── values.yaml            
│   │   └── templates/
│   │       ├── configmap.yaml
│   │       ├── deployment.yaml  
│   │       ├── grafana-dashboards.yaml  
│   │       ├── hpa.yaml  
│   │       ├── ingress.yaml  
│   │       ├── namespace.yaml
│   │       ├── NOTES.txt
│   │       ├── prometheusrule.yaml
│   │       ├── service.yaml
│   │       ├── servicemonitor.yaml              
└── doc/
    └── README.md                  # Документация (этот файл)
```

---

## Подробное описание выполнения

### 1. Создание приложения с метриками

Разработано Express приложение с endpoint `/metrics` для экспонирования метрик Prometheus. Приложение содержит:
- Счетчик запросов (`app10_http_requests_total`)
- Гистограмму задержек (`app10_http_request_duration_seconds`)
- Счетчик ошибок (`app10_http_errors_total`)
Все метрики используют префикс `app10_` согласно варианту. Код приложения монтируется через ConfigMap.
**Файл:** [src/templates/configmap.yaml](../src/templates/configmap.yaml) (содержит app.js и package.json)

### 2. Dockerfile с метаданными

В проекте используется базовый образ `node:20-alpine` без кастомного Dockerfile, так как код приложения загружается через ConfigMap. Метаданные студента добавлены в Deployment как labels/annotations (адаптировано под вариант: org.bstu.student.fullname, org.bstu.student.id и т.д.).
**Файл:** [src/templates/deployment.yaml](../src/templates/deployment.yaml)

### 3. Helm чарт приложения

Создан Helm чарт с параметризацией:
- `Chart.yaml` - метаданные чарта
- `values.yaml` - значения по умолчанию (replicas, image, namespace, метаданные студента, autoscaling, probes, metricsPrefix)
- `templates/deployment.yaml` - Deployment с labels метаданных и аннотациями для Prometheus scrape
- `templates/service.yaml` - Service для доступа к приложению
- Дополнительно: Ingress, HPA, PrometheusRule, Grafana dashboards
**Каталог:** [src/helm/](../src/helm/)

### 4. ServiceMonitor для сбора метрик

Создан манифест ServiceMonitor для автоматического обнаружения и сбора метрик Prometheus:
- Selector по label `app: app10`
- Endpoint `/metrics` на порту `http`
- Интервал сбора: 30s
- Scrape timeout: 10s
**Файл:** [src/templates/servicemonitor.yaml](../src/templates/servicemonitor.yaml)

### 5. Инструкции по установке kube-prometheus-stack

Подготовлены values для установки системы мониторинга через Helm:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring -f prometheus-values.yaml

**Файл:** [src/prometheus-values.yaml](../src/prometheus-values.yaml)

---

## Контрольный список (checklist)

- [ ✅ ] README с полными метаданными студента
- [ ✅ ] Express приложение с endpoint /metrics
- [ ✅ ] Метрики с префиксом app10_ (Counter, Histogram, Counter for errors)
- [ ✅ ] Labels с метаданными в Deployment (адаптировано без Dockerfile)
- [ ✅ ] Helm чарт с параметризацией
- [ ✅ ] ServiceMonitor для автоматического сбора метрик
- [ ✅ ] Namespace с уникальным именем (app10)
- [ ✅ ] Именование ресурсов с префиксом app10_
- [ ✅ ] ENV переменные (METRICS_PREFIX) логируются при старте
- [ ✅ ] Установка и настройка Grafana
- [ ✅ ] Создание дашбордов в Grafana
- [ ✅ ] Настройка PrometheusRule с алертами
- [ ❌ ] GitOps (Argo CD/Flux) (не выполнено)

---

## Вывод

В ходе лабораторной работы была выполнена интеграция системы мониторинга для Kubernetes-приложения:
1. Создано Node.js приложение с endpoint `/metrics` и метриками Prometheus (счетчик запросов, гистограмма задержек, счетчик ошибок).
2. Разработан Helm чарт с использованием базового образа Node.js и кодом через ConfigMap, метаданными студента в labels.
3. Упаковано приложение в Helm чарт с параметризацией, включая Ingress, HPA, probes.
4. Создан ServiceMonitor для автоматического обнаружения и сбора метрик.
5. Подготовлены values для установки kube-prometheus-stack, дашборды Grafana и правила алертов Prometheus.
Освоены навыки работы с Prometheus client библиотеками, Helm charts, ServiceMonitor, Grafana dashboards и алертами для сбора метрик в Kubernetes.

---
