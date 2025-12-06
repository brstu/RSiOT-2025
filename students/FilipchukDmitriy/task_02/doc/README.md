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
<p align="right">Филипчук Д. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса (Deployment + Service), настроить конфигурацию через ConfigMap и научиться запускать кластер локально.

---

### Вариант №22

## Метаданные студента

- **ФИО:** Филипчук Дмитрий Васильевич
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220027
- **Email (учебный):** <as006327@g.bstu.by>
- **GitHub username:** kuddel11
- **Вариант №:** 22 (ns=app22, name=web22, replicas=3, port=8042, NodePort, cpu=200m, mem=192Mi)
- **ОС и версия:** Windows 11 24H2, Docker Desktop v4.53.0

---

## Окружение и инструменты

- Python 3.11
- Flask 3.0.0
- Docker Desktop 4.53.0
- Kubernetes (через Docker Desktop или Minikube)
- kubectl

## Структура репозитория c описанием содержимого

```text
task_02/
├── src/
│   ├── app.py              # Flask приложение
│   ├── requirements.txt    # Python зависимости
│   ├── Dockerfile          # Образ приложения
│   └── k8s/                # Kubernetes манифесты
│       ├── namespace.yaml
│       ├── configmap.yaml
│       ├── deployment.yaml
│       └── service.yaml
└── doc/
    └── README.md           # Документация
```

## Подробное описание выполнения

### 1. Создание HTTP-сервиса

Создан простой Flask-сервис с двумя эндпоинтами:

- `/` - главная страница
- `/health` - проверка здоровья

### 2. Dockerfile

Создан Dockerfile для сборки образа приложения.

```bash
cd src
docker build -t web22:latest .
```

### 3. Kubernetes манифесты

Созданы манифесты:

- `namespace.yaml` - namespace app22
- `configmap.yaml` - конфигурация приложения
- `deployment.yaml` - развертывание с 3 репликами
- `service.yaml` - NodePort сервис на порту 30042

### 4. Деплой в Kubernetes

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 5. Проверка

```bash
kubectl get pods -n app22
kubectl get svc -n app22
```

Доступ к приложению:

```text
http://localhost:30042
```

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [✅] Dockerfile с labels
- [✅] Kubernetes манифесты (namespace, configmap, deployment, service)
- [❌] Multi-stage build
- [❌] Non-root пользователь
- [❌] Health/Liveness/Readiness probes
- [❌] RollingUpdate стратегия
- [❌] Resource limits/requests
- [❌] Graceful shutdown

---

## Вывод

В ходе работы был создан минимальный HTTP-сервис и выполнен базовый деплой в Kubernetes. Созданы основные манифесты для запуска приложения. Освоены базовые команды kubectl для работы с кластером.
