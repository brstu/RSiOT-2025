# Описание

HTTP-сервис на Node.js с эндпоинтами для Kubernetes (/healthz, /ready), stateless-приложение без хранения состояния.
Проект упакован в Docker-контейнер с multi-stage build и развернут в Kubernetes кластере с использованием Deployment, Service, Ingress.
Сервер поддерживает graceful shutdown, liveness/readiness probes и ресурсные ограничения.
Параметризация манифестов выполнена с помощью Kustomize для варианта 34.

## Структура проекта

```structrure
textrsiot-lab02/
├── k8s/                         # Kubernetes манифесты
│   ├── base/                    # Базовые манифесты
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── kustomization.yaml
│   └── overlays/variant34/      # Оверлей для варианта 34
│       ├── namespace.yaml
│       ├── deployment-patch.yaml
│       ├── service-patch.yaml
│       ├── ingress-patch.yaml
│       └── kustomization.yaml
├── src/
│   └── server.js                # Код сервера
├── Dockerfile                   # Multi-stage build
├── package.json                 # Зависимости Node.js
├── README.md                    # Документация
└── Варианты.md                  # Варианты заданий (из методички)
```

## Требования

Docker (для сборки образа)
Kubernetes кластер (Minikube или Kind)
kubectl
Kustomize (встроен в kubectl v1.14+)

## Быстрый запуск

Локально с Docker
Bash# Собрать образ

```bash
docker build -t ghcr.io/kashpirdr/rsiot-lab02:v34 .
```

## Запустить контейнер

```bash
docker run -p 8012:8012 -e STU_ID=12345678 -e STU_GROUP=АС-64 -e STU_VARIANT=34 ghcr.io/kashpirdr/rsiot-lab02:v34
```

Сервер доступен: <http://localhost:8012>
В Kubernetes с Minikube
Bash# Запустить кластер
minikube start

## Включить Ingress

```bash
minikube addons enable ingress
```

## Собрать и загрузить образ (опционально, если не из реестра)

```bash
docker build -t ghcr.io/kashpirdr/rsiot-lab02:v34 .
minikube image load ghcr.io/kashpirdr/rsiot-lab02:v34
```

## Деплой приложения через Kustomize

```bash
kubectl apply -k k8s/overlays/variant34/
```

## Проверить статус

```bash
kubectl get all -n app34
```

## Узнайте IP Minikube

```bash
minikube ip  # Например, 192.168.49.2
```

Добавьте в /etc/hosts: 192.168.49.2 web34.local

## Доступ

curl <http://web34.local/>
Endpoints

GET / - информация о сервисе, студенте, группе и варианте
GET /healthz - проверка работоспособности (liveness/readiness probe для Kubernetes)
GET /ready - проверка готовности (адаптирована для stateless, без зависимости от БД)

## Конфигурация Kubernetes

### Deployment

Replicas: 3
Strategy: RollingUpdate (maxSurge: 1, maxUnavailable: 0)
Resources: requests: 200m CPU/192Mi RAM, limits: 400m CPU/384Mi RAM
Liveness probe:/healthz (initialDelay: 10s, period: 10s)
Readiness probe:/healthz (initialDelay: 5s, period: 5s)
Image: ghcr.io/kashpirdr/rsiot-lab02:v34
Port: 8012
Env: STU_ID, STU_GROUP, STU_VARIANT

### Service

Type: ClusterIP (port: 80, targetPort: 8012)
Namespace: app34

### Ingress

Class: nginx
Host: web34.local
Path: /

## Особенности реализации

Multi-stage Docker build (финальный образ ~150MB, на базе distroless/nodejs)
Non-root пользователь в контейнере (UID 10001)
Graceful shutdown с логированием для Kubernetes (обработка SIGTERM/SIGINT)
Liveness/Readiness probes на /healthz (адаптировано для stateless, без проверки PostgreSQL)
Resource limits согласно варианту (CPU: 200m, Memory: 192Mi)
Structured logging с метаданными студента при старте
RollingUpdate strategy для бесшовных обновлений без простоя
Kustomize для параметризации (namespace: app34, name: web34, replicas: 3, port: 8012, resources)
ENV-переменные для метаданных студента, логируемые при запуске

## Проверка деплоя

Bash# Статус подов

```bash
kubectl get pods -n app34 -o wide
```

## Логи приложения

```bash
kubectl logs -n app34 -l app=web34 --tail=10
```

## Описание deployment

```bash
kubectl describe deployment web34-web -n app34
```

## Smoke-тест

```bash
minikube service web34-web -n app34 --url  # Или используйте Ingress
curl <http://web34.local/healthz>
curl <http://web34.local/ready>
curl <http://web34.local/>
```

## Rolling update

Измените image в deployment-patch.yaml на :v34.1, соберите/загрузите новый образ

```bash
kubectl apply -k k8s/overlays/variant34/
kubectl get pods -n app34 -w  # Наблюдайте обновление без простоя
```

## Student Metadata

```meta
Full Name: Кашпир Дмитрий Русланович
Group: АС-64
Student ID: 220043
Email (Academic): (укажите учебный email)
GitHub Username: kashpirdr
Variant №: 34
K8s Namespace: app34
Deployment: web34-web
Service Port: 8012
Operating System: Ubuntu 22.04 (или актуальная)
Docker Version: Docker Engine 24.0.5
Kubernetes: Minikube v1.31.2
Date Performed: December 06, 2025
```

## Метки в Kubernetes

Все ресурсы содержат метки:

```meta
org.bstu.course: RSIOT
org.bstu.variant: "34"
org.bstu.student.id: "220043"
org.bstu.group: as-64
org.bstu.owner: kashpirdr
org.bstu.student.slug: as-64-220043-v34
org.bstu.student.fullname: kashpir-dmitriy-ruslanovich
```
