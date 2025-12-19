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
<p align="right">Грицук П. Э.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes, добавить экспонирование метрик в приложение, создать ServiceMonitor для автоматического сбора метрик.

---

### Вариант №4

## Метаданные студента

- **ФИО:** Грицук Павел Эдуардович
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220007
- **Email (учебный):** <as006304@g.bstu.by>
- **GitHub username:** momo-kitsune
- **Вариант №:** 4
- **ОС и версия:** Windows 11 22H2, Docker Desktop v4.54.0

**Параметры варианта:**

- Префикс метрик: `app04_`
- SLO: 99.0%
- p95 latency: 350ms
- Alert: "5xx>2.5% за 10м"

---

## Окружение и инструменты

- **Python 3.11** - для разработки приложения
- **Flask 3.0.0** - веб-фреймворк
- **Docker Desktop 4.54.0** - контейнеризация
- **Kubernetes (Minikube)** - оркестрация контейнеров
- **Prometheus** - сбор метрик
- **Grafana** - визуализация метрик

## Структура репозитория c описанием содержимого

```
doc/
  README.md              # документация (этот файл)
src/
  app.py                 # Flask приложение с endpoint /metrics
  requirements.txt       # зависимости Python
  Dockerfile             # образ контейнера с метаданными
  k8s/
    namespace.yaml       # namespace для приложения
    deployment.yaml      # deployment с labels студента
    service.yaml         # service для доступа к приложению
    servicemonitor.yaml  # ServiceMonitor для Prometheus
```

---

## Подробное описание выполнения

### 1. Создание приложения с метриками

Реализовано Flask приложение с базовым endpoint `/metrics`, который возвращает метрики в формате Prometheus. Использован префикс `app04_` согласно варианту.

Метрики:

- `app04_requests_total` - счетчик запросов
- `app04_errors_total` - счетчик ошибок
- `app04_up` - статус доступности сервиса

При запуске контейнера логируются переменные окружения: STU_ID, STU_GROUP, STU_VARIANT.

### 2. Dockerfile с метаданными

Создан Dockerfile с LABEL метаданными студента согласно требованиям:

- org.bstu.student.fullname
- org.bstu.student.id
- org.bstu.group
- org.bstu.variant
- org.bstu.course
- org.bstu.owner
- org.bstu.student.slug

### 3. Kubernetes манифесты

Созданы базовые манифесты:

- **namespace.yaml** - уникальный namespace `app-as63-220007-v04`
- **deployment.yaml** - деплоймент с префиксом `mon-as63-220007-v04` и labels
- **service.yaml** - сервис для доступа к приложению
- **servicemonitor.yaml** - манифест для автоматического сбора метрик Prometheus

### 4. ServiceMonitor

Создан ServiceMonitor для интеграции с Prometheus. Определяет endpoint `/metrics` и интервал сбора 30 секунд для автоматического обнаружения и сбора метрик приложения.

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с labels студента
- [✅] Flask приложение с endpoint /metrics
- [✅] Метрики с префиксом app04_
- [✅] Логирование ENV переменных при старте
- [✅] Kubernetes namespace (app-as63-220007-v04)
- [✅] Deployment с labels
- [✅] Service для приложения
- [✅] ServiceMonitor для Prometheus
- [❌] Полная установка kube-prometheus-stack
- [❌] Дашборды в Grafana
- [❌] PrometheusRule с алертами
- [❌] Helm-чарт приложения
- [❌] GitOps (Argo CD/Flux)

---

## Инструкции по сборке и запуску

### Сборка образа

```bash
cd src
docker build -t mon-as63-220007-v04:latest .
```

### Запуск в Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Применение ServiceMonitor

```bash
kubectl apply -f k8s/servicemonitor.yaml
```

### Проверка метрик

```bash
kubectl port-forward -n app-as63-220007-v04 svc/mon-as63-220007-v04 8080:8080
```

Открыть в браузере: `http://localhost:8080/metrics`

---

## Вывод

В рамках лабораторной работы было создано приложение с экспонированием метрик в формате Prometheus. Реализован endpoint `/metrics` с префиксом `app04_` согласно варианту. Созданы Kubernetes манифесты с корректными метаданными студента и ServiceMonitor для автоматического обнаружения метрик. Освоены навыки работы с системой мониторинга Prometheus и интеграции метрик в приложение.
