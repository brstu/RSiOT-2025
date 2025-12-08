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
<p align="right">Белаш А. О.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса (Deployment + Service), настроить liveness/readiness probes и политику обновления (rolling update), подготовить конфигурацию и научиться запускать кластер локально.

---

### Вариант №25

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

- Python 3.11
- Flask 3.0.0
- Docker Desktop v4.52.0
- Kubernetes (Minikube/Kind)
- kubectl

---

## Структура репозитория c описанием содержимого

```text
src/
  ├── app.py              # HTTP-сервис на Flask
  ├── requirements.txt    # Зависимости Python
  ├── Dockerfile          # Образ контейнера
  └── k8s/                # Kubernetes манифесты
      ├── namespace.yaml
      ├── deployment.yaml
      └── service.yaml
doc/
  └── README.md           # Документация
```

---

## Подробное описание выполнения

### 1. Создание HTTP-сервиса

Реализован простой Flask-сервис с эндпоинтами:

- `/` - главная страница
- `/health` - health check endpoint

Сервис логирует переменные окружения при запуске (STU_ID, STU_GROUP, STU_VARIANT).

### 2. Контейнеризация

Создан Dockerfile с:

- Базовым образом Python 3.11
- Установкой зависимостей
- Labels с метаданными студента
- Expose порта 8031

### 3. Kubernetes манифесты

**Namespace:** app25

**Deployment:**

- 2 реплики
- RollingUpdate стратегия
- Ресурсы: CPU 150m, Memory 128Mi
- Liveness probe на /health
- Readiness probe на /health
- ENV переменные для метаданных

**Service:**

- Type: NodePort
- Port: 8031
- NodePort: 30031

### 4. Команды для развертывания

```bash
# Сборка образа
cd src
docker build -t went2smoke/web25:latest .

# Запуск Minikube
minikube start

# Применение манифестов
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Проверка статусов
kubectl get pods -n app25
kubectl get svc -n app25

# Доступ к сервису
minikube service net-as64-220031-v25 -n app25
```

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Dockerfile с labels
- [✅] Kubernetes манифесты (Namespace, Deployment, Service)
- [✅] Liveness/Readiness probes
- [✅] RollingUpdate стратегия
- [✅] Логирование ENV переменных при старте

---

## Вывод

В ходе работы был создан базовый HTTP-сервис на Flask, контейнеризирован с помощью Docker и развернут в Kubernetes с использованием Deployment и Service. Настроены health проверки и политика обновления RollingUpdate. Реализовано логирование метаданных студента при запуске контейнера.
