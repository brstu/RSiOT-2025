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
<p align="right">Группы АС-63</p>
<p align="right">Кульбеда К. А.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса (Deployment + Service), настроить liveness/readiness probes и политику обновления, запускать кластер локально и проверять корректность деплоя.

---

### Вариант №12

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

- Docker Desktop v4.52.0
- kubectl
- Kind/Minikube
- Python 3.11
- Flask 3.0.0

Параметры варианта: `ns=app12, name=web12, replicas=3, port=8074, cpu=200m, mem=256Mi`

---

## Структура репозитория c описанием содержимого

```text
doc/
  README.md              # документация с метаданными
src/
  app.py                 # HTTP-сервис на Flask
  requirements.txt       # зависимости Python
  Dockerfile             # образ контейнера
  k8s/
    namespace.yaml       # namespace app12
    deployment.yaml      # Deployment с 3 репликами
    service.yaml         # Service типа NodePort
```

---

## Подробное описание выполнения

### 1. Создан простой HTTP-сервис на Flask

Сервис имеет два эндпоинта:

- `/` - возвращает информацию о сервисе
- `/health` - health check для probes

При старте логируются переменные окружения `STU_ID`, `STU_GROUP`, `STU_VARIANT`.

### 2. Создан Dockerfile

Образ на базе `python:3.11-slim`, содержит необходимые labels с метаданными студента.

### 3. Подготовлены Kubernetes-манифесты

- **namespace.yaml** - создание namespace `app12`
- **deployment.yaml** - Deployment с 3 репликами, RollingUpdate стратегией, liveness/readiness probes
- **service.yaml** - Service типа NodePort на порту 30074

### 4. Тестирование

Для локального запуска:

```bash
# Сборка образа
cd src
docker build -t web12:latest .

# Создание кластера (Kind)
kind create cluster

# Загрузка образа в Kind
kind load docker-image web12:latest

# Применение манифестов
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Проверка статусов
kubectl get pods -n app12
kubectl get svc -n app12

# Проверка доступности (port-forward)
kubectl port-forward -n app12 svc/net-as63-220016-v12 8074:8074
```

---

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [✅] Dockerfile с labels
- [✅] Kubernetes манифесты (Deployment, Service, Namespace)
- [✅] Liveness/Readiness probes
- [❌] ConfigMap/Secret не используются
- [❌] Graceful shutdown не реализован
- [❌] Multi-stage build не используется
- [❌] Non-root пользователь не настроен

---

## Вывод

В работе создан минимальный HTTP-сервис на Flask и подготовлены базовые Kubernetes-манифесты для его деплоя. Настроены health checks и RollingUpdate стратегия. Проект выполнен в упрощенном варианте без использования ConfigMap/Secret, без multi-stage сборки и graceful shutdown.
