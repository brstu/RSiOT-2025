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
<p align="right">Грицук П. Э.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса, настроить проверки работоспособности и подготовить конфигурацию для локального запуска кластера.

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

---

## Окружение и инструменты

- Python 3.11
- Flask 3.0.0
- Docker Desktop 4.54.0
- Kubernetes (Minikube или Kind)

---

## Структура репозитория c описанием содержимого

```text
src/
  app.py              # Flask приложение
  requirements.txt    # Python зависимости
  Dockerfile          # Образ контейнера
  k8s/
    namespace.yaml    # Namespace app04
    deployment.yaml   # Deployment с 3 репликами
    service.yaml      # Service типа NodePort
doc/
  README.md          # Документация
```

---

## Подробное описание выполнения

### 1. Создание HTTP-сервиса

Реализован простой Flask-сервис с эндпоинтами:

- `/` - главная страница с информацией о студенте
- `/health` - health check эндпоинт
- `/api/data` - тестовый API эндпоинт

### 2. Dockerfile

Создан Dockerfile на базе Python 3.11 с установкой зависимостей и запуском приложения.

### 3. Kubernetes манифесты

Созданы базовые манифесты:

- **namespace.yaml** - создание namespace app04
- **deployment.yaml** - Deployment с 3 репликами, liveness probe
- **service.yaml** - Service типа NodePort на порту 30084

---

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [✅] Dockerfile
- [✅] Kubernetes манифесты (Namespace, Deployment, Service)
- [✅] Liveness probe

---

## Команды для запуска

```bash
# Сборка образа
cd src
docker build -t momo-kitsune/web04:latest .

# Создание кластера (Minikube)
minikube start

# Применение манифестов
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Проверка статуса
kubectl get pods -n app04
kubectl get svc -n app04

# Тестирование (через NodePort)
minikube service net-as63-220007-v04 -n app04
```

---

## Вывод

В данной работе был создан базовый HTTP-сервис на Flask и выполнен его деплой в Kubernetes. Были освоены навыки создания манифестов Deployment и Service, настройки liveness probe. Проект выполнен в минимальном объёме для демонстрации базового функционала.
