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
<p align="right">Брызгалов Ю. Н.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать систему мониторинга в Kubernetes, добавить экспонирование метрик в приложение с использованием Prometheus client-библиотек.

---

### Вариант №02

**Параметры варианта:**

- Prefix метрик: `app02_`
- SLO: 99.5%
- p95 latency: 250ms
- Alert: "5xx > 1.5% за 10м"

## Метаданные студента

- **ФИО:** Брызгалов Юрий Николаевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220032
- **Email (учебный):** <as006402@g.bstu.by>
- **GitHub username:** Gena-Cidarmyan
- **Вариант №:** 02
- **ОС и версия:** Windows 11, Docker Desktop v4.53.0

---

## Окружение и инструменты

- Kubernetes
- Helm
- Prometheus Operator
- Python 3.12
- Flask
- prometheus-client
- Docker (multi-stage)

## Структура репозитория

app/
  app.py
  requirements.txt
helm/web02/
  Chart.yaml
  values.yaml
  deployment.yaml
  service.yaml
  servicemonitor.yaml
  prometheusrule.yaml
Dockerfile

## Подробное описание выполнения

1. Добавление метрик в приложение

Во Flask-приложение интегрирована библиотека prometheus-client.

Реализованы следующие метрики:

app02_http_requests_total — Counter

app02_http_request_latency_seconds — Histogram

app02_service_up — Gauge

Эндпоинты приложения:

/ — основной

/healthz — проверка состояния

/error — генерация ошибки 5xx

/metrics — экспорт метрик

Метаданные студента логируются при запуске:

STU_ID, STU_GROUP, STU_VARIANT

1. Экспорт метрик

Метрики доступны по адресу:

/metrics

Формат — совместим с Prometheus.

1. Docker-образ

Используется multi-stage Dockerfile:

Stage 1 — установка зависимостей

Stage 2 — минимальный runtime

Контейнер запускается от непривилегированного пользователя:

USER 10001

Добавлены labels:

org.bstu.student.fullname
org.bstu.student.id
org.bstu.group
org.bstu.variant
org.bstu.course

1. Helm Chart

Создан Helm-чарт web02:
Chart.yaml — описание
values.yaml — параметры
deployment.yaml — шаблон Deployment
service.yaml — Service
servicemonitor.yaml — сбор метрик
prometheusrule.yaml — алерты

Основные параметры:

namespace: app-feis-41-123456-v4
replicas: 3
image: flask-app:stu-123456-v4
port: 8082

1. Развёртывание приложения
helm install web02 helm/web02

Проверка:
kubectl get pods -n app-feis-41-123456-v4
kubectl get svc -n app-feis-41-123456-v4

1. ServiceMonitor

ServiceMonitor подключает приложение к Prometheus:
Namespace: monitoring
Path: /metrics
Сбор метрик с сервиса web02

1. Alerting (PrometheusRule)

Реализованы два алерта:
1. High5xxErrorRate
Срабатывает, если:
5xx > 1.5% за 10 минут

2. HighLatencyP95
Срабатывает, если:
p95 > 0.25 сек

Severity:
critical
warning

## Контрольный список (checklist)

[✅] Flask-приложение
[✅] Метрики Prometheus
[✅] Endpoint /metrics
[✅] Multi-stage Dockerfile
[✅] Non-root пользователь
[✅] Helm Chart
[✅] Service
[✅] ServiceMonitor
[✅] PrometheusRule (Alerting)
[✅] Логирование STU_ID / STU_GROUP / STU_VARIANT

## Вывод

В лабораторной работе реализована система наблюдаемости для Kubernetes-приложения.
Приложение экспортирует метрики в формате Prometheus, настроен их сбор через ServiceMonitor, а также реализованы алерты для контроля ошибок и задержек. Использование Helm упростило деплой и конфигурацию приложения. Получены практические навыки мониторинга и анализа состояния сервисов в Kubernetes.