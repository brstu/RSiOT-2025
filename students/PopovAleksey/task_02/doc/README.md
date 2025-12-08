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
<p align="right">Попов А. С.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса.

---

### Вариант №38

## Метаданные студента

- **ФИО:** Попов Алексей Сергеевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220051
- **Email (учебный):** <as006416@g.bstu.by>
- **GitHub username:** LexusxdsD
- **Вариант №:** 38
- **ОС и версия:** Windows 11 21H2, Docker Desktop v4.52.0

---

## Окружение и инструменты

- Docker Desktop v4.52.0
- Python 3.11

## Структура репозитория

```text
src/
  app.py              # HTTP-сервис
  Dockerfile          # сборка образа
  k8s/
    deployment.yaml   # Deployment
    service.yaml      # Service
doc/
  README.md           # документация
```

## Подробное описание выполнения

1. Создан простой HTTP-сервер на Python
2. Написан Dockerfile для сборки образа
3. Созданы Kubernetes манифесты

### Сборка образа

```bash
cd src
docker build -t web38:latest .
```

### Деплой в Kubernetes

```bash
kubectl create namespace app38
kubectl apply -f k8s/
```

### Проверка

```bash
kubectl get pods -n app38
kubectl get svc -n app38
```

## Контрольный список

- [✅] README с метаданными студента
- [✅] Dockerfile с labels
- [❌] docker-compose.yml
- [✅] Kubernetes манифесты (Deployment, Service)
- [❌] Health/Liveness/Readiness probes
- [❌] Graceful shutdown
- [❌] ConfigMap/Secret
- [❌] Multi-stage build
- [❌] Non-root пользователь

---

## Вывод

В ходе работы был создан базовый HTTP-сервис и развёрнут в Kubernetes с использованием Deployment и Service.
