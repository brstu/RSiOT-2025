# Лабораторная работа №2: Kubernetes деплой

## Метаданные студента
- **ФИО:** Казаренко Павел Владимирович
- **Группа:** АС-63
- **StudentID:** 220008
- **Email:** as006305@g.bstu.by  
- **GitHub:** Catsker
- **Вариант:** 05
- **Дата:** 27.10.2024
- **ОС:** Windows 10
- **Docker:** 28.2.2
- **kubectl:** v1.30.0
- **Minikube:** v1.32.0

## 1. Подготовка Docker образа

```bash
# Сборка multi-stage образа
docker build -t web05:stu-220008-v05 .

# Проверка размера образа
docker images | grep web05

# Тестирование локально
docker run -d -p 8091:8091 --name web05-test web05:stu-220008-v05
curl http://localhost:8091/health
docker stop web05-test
```

## 2. Kubernetes манифесты

```text
Структура каталога k8s/:
├── 01-namespace.yaml      # Создание namespace app05
├── 02-configmap.yaml      # Конфигурация приложения
├── 03-secret.yaml         # Секреты (если нужны)
├── 04-redis-deployment.yaml # Redis Deployment
├── 05-redis-service.yaml  # Redis Service
├── 06-deployment.yaml     # Web приложение Deployment
└── 07-service.yaml        # Web приложение Service
```

## 3. Установка и настройка Minikube
### Установка (Windows)

```bash
# Установка через Chocolatey
choco install minikube kubernetes-cli

# Или скачать с официального сайта:
# https://minikube.sigs.k8s.io/docs/start/
```

### Запуск кластера

```bash
# Запуск Minikube с Docker драйвером
minikube start --driver=docker --cpus=2 --memory=4096

# Проверка статуса
minikube status

# Загрузка Docker образа в Minikube
minikube image load web05:stu-220008-v05
```

## 4. Деплой приложения

### Применение манифестов

```bash
# Все манифесты разом
kubectl apply -f k8s/

# Или по очереди
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
# ... и так далее
```

### Проверка деплоя

```bash
# Проверка всех ресурсов в namespace
kubectl get all -n app05

# Проверка подов
kubectl get pods -n app05 -w

# Проверка логов
kubectl logs -n app05 deployment/web05 -f
```

## 5. Тестирование

### Проверка endpoints

```bash
# Port forwarding
kubectl port-forward -n app05 service/web05-service 8080:8091

# В другом терминале проверяем:
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/visit

# Или через minikube service
minikube service -n app05 web05-service
```

### Проверка readiness/liveness probes

```bash
# Проверка состояния подов
kubectl describe pod -n app05 -l app=web05 | grep -A10 "Readiness"
kubectl describe pod -n app05 -l app=web05 | grep -A10 "Liveness"

# Имитация сбоя (убиваем процесс в поде)
kubectl exec -n app05 -it <pod-name> -- kill 1
# Kubernetes должен перезапустить под
```

## 6. Rolling update

### Обновление образа

```bash
# Обновление версии
docker build -t web05:stu-220008-v05-v2 .

# Загрузка в Minikube
minikube image load web05:stu-220008-v05-v2

# Обновление Deployment
kubectl set image deployment/web05 web05=web05:stu-220008-v05-v2 -n app05

# Наблюдение за rolling update
kubectl rollout status deployment/web05 -n app05
```

## 7. Очистка

```bash
# Удаление приложения
kubectl delete -f k8s/

# Или удаление namespace
kubectl delete namespace app05

# Остановка Minikube
minikube stop

# Удаление кластера
minikube delete
```

## 8. Скрипты автоматизации

### deploy.sh

```bash
#!/bin/bash
echo "Building and deploying..."
docker build -t web05:stu-220008-v05 .
minikube image load web05:stu-220008-v05
kubectl apply -f k8s/
kubectl rollout status deployment/web05 -n app05
```

### test.sh

```bash
#!/bin/bash
echo "Testing endpoints..."
kubectl port-forward -n app05 service/web05-service 8080:8091 &
sleep 5
curl -s http://localhost:8080/health | jq .
curl -s http://localhost:8080/visit | jq .
```
