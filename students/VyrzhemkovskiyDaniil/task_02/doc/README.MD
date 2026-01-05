# Лабораторная работа №2 - Деплой HTTP-сервиса в Kubernetes

## Метаданные студента

- **ФИО:** Выржемковский Даниил Иванович
- **Группа:** AC-63
- **№ студенческого:** 006305
- **Email:** [danikv0305@gmail.com]
- **GitHub username:** romb123
- **Номер варианта:** 2
- **ОС:** Windows 11
- **Docker:** 24.0+
- **kubectl:** 1.28+
- **Minikube/Kind:** v0.20+

## Описание проекта

Деплой простого HTTP-сервиса `web02` в Kubernetes кластере с использованием современных практик DevOps. Сервис разработан на Python с использованием стандартных библиотек, что обеспечивает минимальный размер контейнера и быстрый запуск.

## Архитектура решения

### Компоненты Kubernetes

1. **Namespace** (`app02`) - изоляция окружения
2. **ConfigMap** (`web02-config`) - конфигурация приложения
3. **Secret** (`web02-secret`) - чувствительные данные
4. **Deployment** (`web02-deployment`) - управление подами
5. **Service** (`web02-service`) - сетевой доступ к приложению
6. **Ingress** (`web02-ingress`) - доступ извне кластера (опционально)

## Конфигурация приложения

### ConfigMap (web02-config)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web02-config
  namespace: app02
  labels:
    app: web02
    org.bstu.student.fullname: "Выржемковский Даниил Иванович"
    org.bstu.student.id: "006305"
    org.bstu.group: "AC-63"
    org.bstu.variant: "2"
    org.bstu.course: "RSIOT"
    org.bstu.owner: "romb123" 
    org.bstu.student.slug: "ac-63-006305-v02"
data:
  PORT: "8082"
  APP_NAME: "web02"
  APP_VERSION: "1.0.0"
  ENVIRONMENT: "production"
  LOG_LEVEL: "INFO"
  HOST: "0.0.0.0"
  STU_ID: "006305"
  STU_GROUP: "AC-63"
  STU_VARIANT: "2"
  STU_FULLNAME: "Выржемковский Даниил Иванович"
```

### Secret (web02-secret)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: web02-secret
  namespace: app02
  labels:
    app: web02
    org.bstu.course: "RSIOT"
    org.bstu.student.slug: "ac-63-006305-v02"
type: Opaque
stringData:
  API_KEY: "supersecretapikey123"
  SECRET_TOKEN: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
```

## Быстрый старт

### Предварительные требования

```bash
# Установите необходимые инструменты
# 1. Docker Desktop или Docker Engine
# 2. kubectl
# 3. Minikube или Kind

# Проверка установки
docker --version
kubectl version --client
minikube version  # или kind version
```

### Шаг 1: Сборка Docker образа

```bash
# Клонируйте репозиторий (если нужно)
git clone <repository-url>
cd task_02

# Сборка multi-stage образа
docker build -t web02:latest -t web02:v1.0.0 .

# Проверка размера образа (должен быть ≤ 150MB)
docker images web02:latest

# Тестирование образа локально
docker run -d -p 8082:8082 --name web02-test \
  -e PORT=8082 -e APP_NAME=web02 \
  web02:latest

# Проверка работоспособности
curl http://localhost:8082/
curl http://localhost:8082/health
curl http://localhost:8082/ready

# Остановка тестового контейнера
docker stop web02-test && docker rm web02-test
```

### Шаг 2: Настройка Minikube кластера

```bash
# Запуск Minikube с достаточными ресурсами
minikube start \
  --cpus=2 \
  --memory=4096 \
  --disk-size=20gb \
  --driver=docker

# Включение необходимых аддонов
minikube addons enable metrics-server
minikube addons enable ingress

# Настройка использования Docker daemon Minikube
eval $(minikube docker-env)

# Пересборка образа в среде Minikube
docker build -t web02:latest .
```

### Шаг 3: Деплой в Kubernetes

```bash
# Создание namespace и всех ресурсов
kubectl apply -f k8s/

# Альтернативно, можно применять файлы по отдельности:
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-secret.yaml
kubectl apply -f k8s/04-deployment.yaml
kubectl apply -f k8s/05-service.yaml
# kubectl apply -f k8s/06-ingress.yaml  # опционально

# Проверка созданных ресурсов
kubectl get all -n app02
kubectl get configmap,secret -n app02
```

### Шаг 4: Проверка деплоя

```bash
# Ожидание запуска всех подов
kubectl wait --for=condition=ready pod -n app02 --all --timeout=120s

# Просмотр статуса подов
kubectl get pods -n app02 -o wide

# Просмотр логов приложения
kubectl logs -n app02 deployment/web02-deployment --tail=10 -f

# Проверка Service
kubectl describe svc -n app02 web02-service

# Проверка событий namespace
kubectl get events -n app02 --sort-by='.lastTimestamp'
```

### Шаг 5: Smoke тестирование

```bash
# Вариант 1: Port-forward для локального доступа
kubectl port-forward -n app02 svc/web02-service 8080:80 &
PORT_FORWARD_PID=$!

curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/ready

kill $PORT_FORWARD_PID

# Вариант 2: Использование временного пода для тестирования
kubectl run -n app02 test-$RANDOM \
  --rm -it --image=curlimages/curl --restart=Never -- sh

# Внутри контейнера:
curl http://web02-service.app02.svc.cluster.local/
curl http://web02-service.app02.svc.cluster.local/health
exit
