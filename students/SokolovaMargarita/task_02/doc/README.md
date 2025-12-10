# Лабораторная работа №02

Министерство образования Республики Беларусь

Учреждение образования: "Брестский Государственный технический университет"

Кафедра: ИИТ

**По дисциплине:** "Распределенные системы и облачные технологии"  
**Тема:** Kubernetes: базовый деплой  

Вариант: 19

Выполнил(а): Соколова М. А.

Группа: АС-63

Проверил: Несюк А.Н.

Брест, 2025

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP‑сервиса (Deployment + Service), настроить liveness/readiness probes и стратегию обновления (RollingUpdate), параметризовать конфигурацию через `ConfigMap`/`Secret` и запустить локальный кластер (Minikube/Kind).

---

## Вариант №19

- **Namespace:** `app19`
- **Приложение:** `web19`
- **Реплики:** `2`
- **Порт приложения:** `8053` (контейнер)
- **Ingress class:** `nginx`
- **Ресурсы:** `cpu=150m`, `memory=128Mi`

---

## Метаданные студента

- **ФИО:** Соколова Маргарита Александровна
- **Группа:** АС-63
- **StudentID:** 220024
- **Email:** `as006321@g.bstu.by`
- **GitHub username:** Ritkas33395553
- **Вариант:** 19
- **Дата выполнения:** 04.12.2025
- **ОС:** Windows 10.0.19044.3086
- **Docker Desktop/Engine:** v28.4.0

---

## Labels

- org.bstu.student.fullname: Sokolova-Margarita-Aleksandrovna
- org.bstu.student.id: "220024"
- org.bstu.group: AS-63
- org.bstu.variant: "19"
- org.bstu.course: RSIOT
- org.bstu.owner: soko1ova
- org.bstu.student.slug: as-63-220024-v19

---

## Окружение и инструменты

- **ОС:** Windows 10.0.19044
- **Docker Desktop:** v28.4.0
- **Kubernetes:** v1.32.2 (Kustomize v5.5.0)
- **kubectl:** v1.32.2
- **Minikube:** v1.37.0
- **Язык приложения:** Node.js (образ `node:20-alpine3.18`)

---

## Структура репозитория

```text
TASK_02/
├── doc/
│   └── README.md            # Документация
├── src/
│   ├── k8s/
│   │   └── base/
│   │       ├── configmap.yaml   # ConfigMap с переменными
│   │       ├── deployment-app.yaml    # Deployment для приложения с пробами
│   │       ├── deployment-redis.yaml  # Deployment для Redis
│   │       ├── ingress.yaml           # Ingress для внешнего доступа
│   │       ├── kustomization.yaml     # Сборщик Kustomize с labels
│   │       ├── namespace.yaml   # Namespace app19
│   │       ├── pvc.yaml         # PersistentVolumeClaim для Redis
│   │       ├── service-app.yaml       # Service (ClusterIP)
│   │       └── service-redis.yaml     # Service для Redis
│   ├── src/
│   │   ├── node_modules/       # Зависимости Node.js (установленные)
│   │   ├── Dockerfile           # Multi-stage сборка образа
│   │   ├── package-lock.json    # Lock-файл зависимостей
│   │   ├── package.json         # Зависимости (express, redis)
│   │   └── server.js            # HTTP-сервис на Node/Express с Redis
│   ├── .dockerignore        # Игнор для Docker
│   ├── .gitattributes       # Атрибуты Git
│   ├── .gitignore           # Игнор для Git
│   ├── docker-compose.yaml  # Docker Compose из ЛР01 (для локального теста без K8s)
│   └── logs_startup.txt     # Пример логов старта
└── Makefile                 # Автоматизация (build, push, deploy, test, clean)
---

## Краткое описание реализации

1. HTTP‑сервис

- Простой Node/Express сервис с зависимостью от Redis.
- Маршруты: `/` (главная), `/about`, `/contact`, `/healthz` (liveness), `/ready` (readiness — проверяет подключение к Redis).
- Сервис логирует старт, метаданные студента (`STU_ID`, `STU_GROUP`, `STU_VARIANT`) и корректно завершает работу при `SIGTERM`/`SIGINT` (graceful shutdown).

2. Dockerfile

- Multi-stage сборка на `node:20-alpine3.18`.
- Запуск от non-root пользователя (UID/GID `65532`).
- `LABEL` с метаданными студента, `EXPOSE 8053`.
- `HEALTHCHECK` реализован (проверка `GET /healthz`).

Пример сборки образа (в папке `src/src`):

```powershell
cd src/src
docker build -t soko1ova/lr01-node-v19:v19 -f Dockerfile .
docker push soko1ova/lr01-node-v19:v19
```

1. Kubernetes-манифесты

- Используется `Kustomize` для параметризации и добавления `labels`.
- Ресурсы:
  - `namespace.yaml` — namespace `app19`
  - `configmap.yaml` — конфигурация приложения
  - `pvc.yaml` — `PersistentVolumeClaim` для Redis (1Gi, ReadWriteOnce)
  - `deployment-redis.yaml` + `service-redis.yaml`
  - `deployment-app.yaml` — приложение с `liveness`/`readiness` probes, `resources`, `rollingUpdate`
  - `service-app.yaml` — `ClusterIP` (порт 80 -> targetPort 8053)
  - `ingress.yaml` — Ingress для `web19.local` (`ingressClassName: nginx`)
  - `kustomization.yaml` — сборщик ресурсов

---

## Развертывание и проверка

1. Соберите образ (см. выше) или используйте `Makefile`:

```powershell
make build
make push
make deploy
make test
```

1. Деплой в локальный кластер (Minikube):

```powershell
make deploy
# или вручную
minikube kubectl -- apply -k src/k8s/base
```

1. Проверка статуса:

```powershell
minikube kubectl -- get pods -n app19
minikube kubectl -- get svc -n app19
minikube kubectl -- get ing -n app19
```

1. Доступ к приложению (предполагая host `web19.local` настроен в `/etc/hosts` или локально):

```text
http://web19.local/
```

1. Smoke‑проверки:

```powershell
curl http://web19.local/
curl http://web19.local/healthz
curl http://web19.local/ready
```

---

## Контрольный список

- [✅] README с полными метаданными студента
- [✅] Dockerfile (multi-stage, non-root, labels)
- [✅] Kubernetes манифесты (namespace, configmap, deployment, service)
- [✅] Health/Liveness/Readiness probes
- [✅] RollingUpdate стратегия
- [✅] Resource limits/requests
- [✅] Graceful shutdown

---

## Вывод

В лабораторной работе адаптирован HTTP‑сервис на Node/Express с использованием Redis, подготовлены Kubernetes‑манифесты и автоматизация для локального развертывания. Настроены `liveness`/`readiness` probes, стратегия RollingUpdate и ресурсные ограничения. Сервис успешно разворачивается в Minikube с 2 репликами, доступен через Ingress и сохраняет данные Redis на PVC.
