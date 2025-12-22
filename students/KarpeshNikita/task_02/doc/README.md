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
<p align="right">Карпеш Н.П.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса.

---

### Вариант №37

## Метаданные студента

- **ФИО:** Карпеш Никита Петрович
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220009
- **Email (учебный):** <as006311@g.bstu.by>
- **GitHub username:** Frosyka
- **Вариант №:** 6
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

---

## Окружение и инструменты

- Python 3.11
- Docker
- Kubernetes (minikube)

## Структура репозитория

```text
src/
  app/
    server.py          # HTTP-сервер
  k8s/
    deployment.yaml    # Deployment манифест
    service.yaml       # Service манифест
  Dockerfile           # Dockerfile для образа
doc/
  README.md            # Документация
```

## Подробное описание выполнения

1. Создан простой HTTP-сервер на Python
2. Написан Dockerfile
3. Созданы манифесты Deployment и Service

### Запуск

```bash
# Сборка образа
cd src
docker build -t web37:latest .

# Применение манифестов
kubectl create namespace app37
kubectl apply -f k8s/
```

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [❌] Dockerfile (multi-stage, non-root, labels) - не реализовано
- [❌] Health/Liveness/Readiness probes - не реализовано
- [❌] ConfigMap/Secret - не реализовано
- [✅] Kubernetes манифесты (базовые)
- [❌] Graceful shutdown - не реализовано

---

## Вывод

Выполнена базовая часть лабораторной работы: создан HTTP-сервер и манифесты для Kubernetes.
