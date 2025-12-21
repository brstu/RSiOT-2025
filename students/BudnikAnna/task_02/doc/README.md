# Go net/http Service with Redis

## Description

**ЛР02 (Kubernetes):** выполнен деплой минимального HTTP-сервиса из ЛР01 в Kubernetes с соблюдением требований: **multi-stage build**, финальный образ ≤ 150 MB, запуск **не от root** (UID **65532**), корректные **EXPOSE**, health endpoints, логирование старта/остановки и **graceful shutdown** по **SIGTERM**.

Сервис реализован на **Go net/http** и работает на порту **8083**. Для хранения состояния используется **Redis** (счётчик запросов). Реализованы HTTP-эндпоинты для проверок:
- `GET /live` — **liveness** (контейнер жив, процесс отвечает)
- `GET /ready` — **readiness** (сервис готов принимать трафик)
- `GET /` — основной эндпоинт (hello + counter)

Kubernetes-параметры по варианту:
- **Namespace:** `app03`
- **Name:** `web03`
- **Replicas:** `2`
- **Port:** `8083`
- **IngressClass:** `nginx`
- **Resources requests:** `cpu=150m`, `memory=128Mi` (limits заданы)
- Стратегия обновлений: **RollingUpdate** (`maxUnavailable: 0`, `maxSurge: 1`) — обновление без простоя
- Доступ: **Service ClusterIP** + **Ingress** по HTTP
- Конфигурация: **ConfigMap + Secret**
- Пробы: **HTTP liveness/readiness** и проверка их корректной работы

Version: **lab02**

---

## Метаданные студента

- ФИО: Будник Анна  
- Группа: АС-64  
- № студенческого (StudentID): 220033  
- Email (учебный):  
- GitHub username: annettebb  
- Вариант №: №3  
- Дата выполнения: 18.12.2025  
- ОС (версия): сборка ОС 19045.6456  
- Версия Docker Desktop/Engine:  

---

## Цель работы

1) Подготовить контейнерный образ приложения (multi-stage, non-root, healthcheck, graceful shutdown).  
2) Описать Kubernetes-манифесты (Namespace, Deployment, Service, Ingress, ConfigMap/Secret).  
3) Настроить **readiness/liveness probes** и убедиться, что они работают.  
4) Выполнить деплой в локальный кластер (Minikube/Kind) и провести smoke-тест.  
5) Выполнить **rolling update** без простоя.

---

## Артефакты (что сдаём)

- `Dockerfile` — multi-stage сборка, non-root, EXPOSE/HEALTHCHECK  
- Каталог `manifests/` с Kubernetes-манифестами:
  - `namespace.yaml`
  - `configmap.yaml`
  - `secret.yaml`
  - `deployment.yaml`
  - `service.yaml`
  - `ingress.yaml`
  - `kustomization.yaml`
- `README.md` — команды сборки/деплоя/проверок и краткое описание выполненного

---

## Docker (контейнерный образ)

### Требования и реализация
- **multi-stage build**: сборка бинарника в builder-stage, запуск в минимальном runtime-stage  
- запуск **не от root**: пользователь **UID 65532**  
- `EXPOSE 8083`  
- `HEALTHCHECK` (проверка `GET /live`)  
- обработка `SIGTERM` и корректное завершение (graceful shutdown), логирование старта/остановки

### Сборка образа
```bash
docker build -t <registry>/<user>/web03:<tag> .
