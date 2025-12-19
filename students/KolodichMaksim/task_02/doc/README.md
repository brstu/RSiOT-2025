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
<p align="right">Группы as-63</p>
<p align="right">Колодич Максим Павлович</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться готовить Kubernetes-манифесты для простого HTTP-сервиса (Deployment + Service), настроить liveness/readiness/startup probes и политику обновления (rolling update), подготовить конфигурацию через ConfigMap/Secret, при необходимости смонтировать volume, запустить кластер локально (Kind/Minikube) и проверить корректность деплоя.

---

### Вариант №09

```text
ns=app09, name=web09, replicas=2, port=8071, ingressClass=nginx, cpuRequests=150m, cpuLimits=300m, memRequests=128Mi, memLimits=256Mi
```

## Метаданные студента

| Поле | Значение |
|------|----------|
| **ФИО** | Колодич Максим Павлович |
| **Группа** | as-63 |
| **№ студенческого (StudentID)** | 220013 |
| **Email (учебный)** | (не указан) |
| **GitHub username** | proxladno |
| **Вариант №** | 09 |
| **Дата выполнения** | 2025-11-28 |
| **ОС и версия** | (указывается локально) |

### Slug и Labels

- **slug:** `as-63-220013-v09`
- **Префиксы ресурсов:** `app-<slug>`, `data-<slug>`, `net-<slug>`

### Labels/Annotations в манифестах (примеры)

```yaml
labels:
  org.bstu.owner: proxladno
  org.bstu.student.slug: as-63-220013-v09
  org.bstu.course: RSIOT
  org.bstu.student.id: "220013"
  org.bstu.group: "as-63"
  org.bstu.variant: "09"
  org.bstu.student.fullname: "Kolodich Maksim Pavlovich"

annotations:
  org.bstu.student.fullname: "Kolodich Maksim Pavlovich"
  org.bstu.description: "Go HTTP service for Kubernetes lab (variant 09)"
```

---

## Окружение и инструменты

| Инструмент | Версия | Назначение |
|------------|--------|------------|
| Docker / Buildx | - | Сборка контейнера (multi-stage Go) |
| kubectl | - | CLI для Kubernetes |
| Kind / Minikube | - | Локальный Kubernetes |
| Go | 1.25 | Язык приложения |
| Redis (опционально) | 7.x | Кеш (опционально) |

---

## Структура репозитория с описанием содержимого

```text
task_02/
├── doc/
│   └── README.md               # Документация (этот файл)
└── src/
    ├── Dockerfile              # Multi-stage Dockerfile (Go)
    ├── docker-compose.yml      # Для локального запуска с Redis
    ├── go.mod
    ├── go.sum
    └── src/
        └── server.go           # HTTP-сервис на Go
    └── k8s/
        ├── namespace.yaml
        ├── configmap.yaml
        ├── secret.yaml
        ├── deployment.yaml
        ├── service.yaml
        └── ingress.yaml
```

---

## Подробное описание выполнения

### 1. Подготовка HTTP-сервиса и контейнерного образа

Проект реализован на Go (файл `src/server.go`). Сервер предоставляет endpoints:

- `/` — простая главная страница с информацией о варианте и группе
- `/healthz` — health endpoint для liveness/readiness
- `/ready` — readiness endpoint

Dockerfile использует multi-stage сборку: сборка бинарника в образе `golang:1.25-alpine`, затем копирование в минимальный `alpine:3.20` образ. В Dockerfile заданы метаданные (labels) и non-root пользователь `appuser` (UID 10001). Порт по умолчанию: `8071`.

Пример команд для сборки и запуска локально:

```powershell
cd students/KolodichMaksim/task_02/src
docker build -t proxladno/lab02-web09:stu-220013-v09 .
docker run -d -p 8071:8071 --name test-web09 proxladno/lab02-web09:stu-220013-v09
curl http://localhost:8071/healthz
docker logs test-web09
docker stop test-web09; docker rm test-web09
```

---

### 2. Kubernetes-манифесты (ключевые моменты)

- Namespace: `app09`
- Deployment: `app-web09` — `replicas: 2`, image `frosyka/lab02-web09:latest` (замените на собранный образ), порт `8071`.
- Service: `net-web09` — `ClusterIP`, port 80 → `targetPort: 8071`.
- Ingress: `ingress-web09` с `ingressClass: nginx`, host `web09.local`.
- ConfigMap: `config-web09` содержит `PORT=8071`, `STU_ID=220013`, `STU_GROUP=as-63`, `STU_VARIANT=09`.
- Secret: `secret-web09` содержит `REDIS_PASSWORD` (может быть пустым).

Deployment включает `startupProbe`, `readinessProbe` и `livenessProbe` для корректного старта и восстановления. Ресурсы назначены:

```yaml
requests:
  cpu: 150m
  memory: 128Mi
limits:
  cpu: 300m
  memory: 256Mi
```

---

## Инструкции для локального тестирования

### Развёртывание в Kind

```powershell
# Создание кластера
kind create cluster --name lab2

# Сборка и загрузка образа в Kind
cd students/KolodichMaksim/task_02/src
docker build -t frosyka/lab02-web09:latest .
kind load docker-image frosyka/lab02-web09:latest --name lab2

# Применение манифестов
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```

## Проверки и отладка

- Просмотр ресурсов: `kubectl get all -n app09`
- Логи: `kubectl logs -n app09 -l app=web09` или `kubectl logs pod/<pod-name> -n app09`
- Описание пода: `kubectl describe pod -n app09 -l app=web09`
- Наблюдение за rollout: `kubectl rollout status deployment/app-web09 -n app09`

---

## Вывод

1. Создан лёгкий Go HTTP-сервис с health/readiness endpoints.
2. Подготовлены Kubernetes-манифесты: Namespace, Deployment, Service, Ingress, ConfigMap и Secret.
3. Добавлены `startupProbe`, `readinessProbe` и `livenessProbe` для надёжного старта.
4. Ресурсы заданы согласно варианту: CPU/Memory requests и limits.

---

## Контрольный список (кратко)

| Требование | Статус |
|------------|--------|
| Dockerfile (multi-stage, non-root) | ✅ |
| Health endpoints (`/healthz`, `/ready`) | ✅ |
| Deployment с `replicas=2` и RollingUpdate | ✅ |
| Startup/readiness/liveness probes | ✅ |
| ConfigMap + Secret | ✅ |
| Ingress (nginx) | ✅ |
