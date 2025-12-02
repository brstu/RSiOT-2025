# Лабораторная работа №02

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №02</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Kubernetes: базовый деплой</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Немирович Д. А.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса (Deployment + Service), настроить liveness/readiness probes и политику обновления (rolling update), подготовить конфигурацию через ConfigMap и научиться запускать кластер локально для проверки корректности деплоя.

---

### Вариант №37

## Метаданные студента

- **ФИО:** Немирович Дмитрий Александрович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220050
- **Email (учебный):** <as006415@g.bstu.by>
- **GitHub username:** goryachiy-ugolek
- **Вариант №:** 37
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

---

## Окружение и инструменты

- **Python 3.11** - для реализации HTTP-сервиса
- **Docker Desktop v4.53.0** - для контейнеризации приложения
- **Kubernetes (Minikube/Kind)** - для локального тестирования
- **kubectl** - для управления Kubernetes-ресурсами

---

## Структура репозитория c описанием содержимого

```text
task_02/
├── src/
│   ├── app.py                    # Основной код HTTP-сервиса
│   ├── requirements.txt          # Зависимости Python (пустой файл)
│   ├── Dockerfile                # Multi-stage Dockerfile
│   └── k8s/                      # Kubernetes манифесты
│       ├── namespace.yaml        # Namespace app37
│       ├── configmap.yaml        # ConfigMap с переменными окружения
│       ├── deployment.yaml       # Deployment с 2 репликами
│       └── service.yaml          # Service (ClusterIP)
└── doc/
    └── README.md                 # Документация и инструкции
```

---

## Подробное описание выполнения

### 1. Подготовка HTTP-сервиса

Создан минимальный веб-сервис на Python с использованием стандартной библиотеки `http.server`. Сервис имеет два эндпоинта:

- `/` - главная страница с информацией о студенте и варианте
- `/health` - health check для Kubernetes probes

Сервис логирует запуск, остановку и корректно обрабатывает сигнал SIGTERM для graceful shutdown.

### 2. Создание Dockerfile

Dockerfile использует multi-stage build (формально - 2 стадии) и запускает приложение от непривилегированного пользователя `appuser`. Добавлены LABEL с метаданными студента. Финальный образ на базе `python:3.11-slim`.

**Команды для сборки образа:**

```bash
cd src
docker build -t web37:latest .
```

### 3. Подготовка Kubernetes-манифестов

Созданы следующие манифесты:

- **namespace.yaml** - создает namespace `app37`
- **configmap.yaml** - содержит переменные окружения (STU_ID, STU_GROUP, STU_VARIANT, PORT)
- **deployment.yaml** - Deployment с 2 репликами, стратегией RollingUpdate, ресурсными лимитами (cpu: 150m, mem: 128Mi), liveness и readiness probes
- **service.yaml** - Service типа ClusterIP для доступа к приложению внутри кластера

### 4. Локальное тестирование

**Запуск Minikube:**

```bash
minikube start
```

**Применение манифестов:**

```bash
kubectl apply -f src/k8s/namespace.yaml
kubectl apply -f src/k8s/configmap.yaml
kubectl apply -f src/k8s/deployment.yaml
kubectl apply -f src/k8s/service.yaml
```

**Проверка статусов:**

```bash
kubectl get pods -n app37
kubectl get svc -n app37
kubectl get deployment -n app37
```

**Проверка работы сервиса:**

```bash
kubectl port-forward -n app37 svc/net-as64-220050-v37 8001:8001
```

Затем открыть в браузере: `http://localhost:8001` и `http://localhost:8001/health`

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile (multi-stage, non-root, labels)
- [✅] Kubernetes манифесты (Namespace, ConfigMap, Deployment, Service)
- [✅] Health/Liveness/Readiness probes
- [✅] Старт/остановка: логирование и graceful shutdown
- [❌] PersistentVolumeClaim (не требуется для варианта)
- [❌] Helm chart / Kustomize (не реализовано)
- [❌] Автоматизация (Makefile/скрипты)

---

## Вывод

В ходе выполнения лабораторной работы был создан базовый HTTP-сервис и выполнен его деплой в Kubernetes. Освоены следующие навыки:

- Создание Kubernetes-манифестов (Deployment, Service, ConfigMap, Namespace)
- Настройка liveness и readiness probes для контроля состояния подов
- Использование стратегии RollingUpdate для обновления приложения
- Работа с ресурсными лимитами и запросами
- Контейнеризация приложения с использованием multi-stage build и непривилегированного пользователя
- Локальное тестирование Kubernetes-кластера

Реализованный проект соответствует минимальным требованиям задания и демонстрирует базовые навыки работы с Kubernetes.
