# Лабораторная работа №3: StatefulSet с Postgres

## Метаданные студента

- **ФИО:** Крагель Алина Максимовна
- **Группа:** АС-63
- **StudentID:** 220046
- **Email:** as006417@g.bstu.by
- **GitHub:** Alina529
- **Вариант:** 10
- **Дата:** 21.12.2025

## Вариант 10

- **БД:** redis
- **Размер PVC:** 3Gi
- **StorageClass:** fast
- **Расписание бэкапа:** `45 * * * *`

## 1. Установка и настройка

### Запуск Minikube

```bash
minikube start --driver=docker --cpus=2 --memory=4096
minikube addons enable storage-provisioner
```

### Создание StorageClass "premium"

```bash
kubectl apply -f k8s/01-storageclass.yaml
kubectl get storageclass
```

## 2. Деплой StatefulSet

### Применение манифестов

```bash
# Создаем namespace
kubectl create namespace state10

# Применяем все манифесты
kubectl apply -f k8s/

# Проверяем состояние
kubectl get all -n state10
kubectl get pvc -n state10
```

## 3. Проверка работы Postgres

### Подключение к базе

```bash
# Port forwarding
kubectl port-forward -n state10 svc/redis 6379:6379

# Подключение через redis-cli (в отдельном терминале)
redis-cli -h localhost -p 6379
```

### Создание тестовых данных

```bash
SET student:name "Крагель Алина Максимовна"
SET student:id "220046"
SET student:variant "10"
```

## 4. Проверка сохранности данных

### Рестарт пода

```bash
# Запоминаем текущий под
kubectl get pods -n state10

# Удаляем под
kubectl delete pod -n state10 redis-0

# Ждем восстановления
kubectl get pods -n state10 -w

# Проверяем данные после рестарта
kubectl port-forward -n state10 svc/redis 6379:6379 &
redis-cli -h localhost -p 6379 GET student:Крагель Алина Максимовна
redis-cli -h localhost -p 6379 GET student:220046
redis-cli -h localhost -p 6379 GET student:10
```

## 5. Бэкап и восстановление

### Проверка работы CronJob

```bash
# Смотрим CronJob
kubectl get cronjob -n state10

# Смотрим созданные Job
kubectl get jobs -n state10

# Проверяем логи бэкапа (замените <tab> на актуальный timestamp)
kubectl logs -n state10 -l job-name=redis-backup-<tab>

# Проверяем файлы бэкапа
kubectl exec -n state10 -it redis-0 -- ls -la /data/backups/
```

### Восстановление из бэкапа

```bash
# Запускаем Job восстановления вручную
kubectl apply -f k8s/07-restore-job.yaml

# Проверяем логи восстановления
kubectl logs -n state10 -l job-name=redis-restore
```

## 6. Архитектура

```text
┌─────────────────────────────────────────┐
│           StatefulSet: redis            │
│  ┌───────────────────────────────────┐  │
│  │ Pod: redis-0                      │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │ Container: redis:7-alpine   │  │  │
│  │  │ • Port: 6379                │  │  │
│  │  │ • Volume Mount: /data       │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  PVC: data-redis-0                │  │
│  │  Storage: 3Gi (fast)              │  │
│  └───────────────────────────────────┘  │
│  Headless Service: redis                │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│           CronJob: redis-backup         │
│  Schedule: 45 * * * *                    │
│  Job → Pod → BGSAVE → копия dump.rdb    │
│              в /data/backups            │
└─────────────────────────────────────────┘
```

## 7. Очистка

```bash
# Удаление всех ресурсов
kubectl delete -f k8s/

# Или удаление namespace
kubectl delete namespace state10

# Остановка Minikube
minikube stop
```
