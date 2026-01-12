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
<p align="right">Брызгалов Ю. Н.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса.

---

### Вариант №02

## Метаданные студента

- **ФИО:** Брызгалов Юрий Николаевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220032
- **Email (учебный):** <as006402@g.bstu.by>
- **GitHub username:** Gena_Cidarmyan
- **Вариант №:** 2
- **ОС и версия:** Windows 11, Docker Desktop v4.53.0, Minikube.

---

## Окружение и инструменты

- Python 3.11
- Docker
- Kubernetes (Minikube)

## Структура репозитория

```text
src/
  app.py              # HTTP-сервер
  Dockerfile          # Сборка образа
  k8s/
    deployment-app.yaml # Deployment 
    configmap.yaml # ConfigMap 
    secret.yaml # Secret
    namespace.yaml # Namespace

doc/
  README.md           # Документация
```

## Подробное описание выполнения

1. Flask-приложение

Реализован HTTP-сервис с эндпоинтами:

/ — главная страница

/healthz — проверка состояния

Используются переменные окружения:

STU_ID

STU_GROUP

STU_VARIANT

Добавлена обработка сигнала SIGTERM для корректного завершения работы (graceful shutdown).

2. Dockerfile

Контейнерный образ собран с использованием multi-stage build.
Особенности:

Запуск не от root-пользователя (UID 10001)

Добавлены LABEL с метаданными

Добавлен HEALTHCHECK

Открыт порт 8082

3. ConfigMap и Secret

Созданы ресурсы:

ConfigMap — для передачи STU_ID, STU_GROUP, STU_VARIANT

Secret — для хранения конфиденциальных данных

Переменные окружения автоматически подставляются в контейнер.

4. Kubernetes Deployment

Deployment настроен со следующими параметрами:

replicas: 3

Стратегия: RollingUpdate

Настроены CPU и memory limits

Добавлены liveness и readiness probes

Используется ConfigMap и Secret

Сборка образа
docker build -t flask-app:as-64-220032-v02 .
Деплой в Kubernetes
kubectl create namespace app02
kubectl apply -f k8s/ -n app02
Проверка
kubectl get pods -n app02
kubectl describe pod <pod-name> -n app02

Проверка health-эндпоинта:

kubectl port-forward pod/<pod-name> 8082:8082 -n app02
http://localhost:8082/healthz
Контрольный список (checklist)

[ ✅ ] README с метаданными студента
[ ✅ ] Dockerfile (multi-stage build)
[ ✅ ] Non-root пользователь
[ ✅ ] Flask-приложение с /healthz
[ ✅ ] Graceful shutdown
[ ✅ ] Kubernetes Deployment
[ ✅ ] RollingUpdate стратегия
[ ✅ ] Resource requests/limits
[ ✅ ] Liveness / Readiness probes
[ ✅ ] ConfigMap
[ ✅ ] Secret
[ ❌ ] Service
[ ❌ ] Ingress
[ ❌ ] Smoke-test доступа через Service

---

## Вывод

Выполнена базовая настройка Kubernetes деплоя. Создан HTTP-сервис и манифесты для его развертывания.
