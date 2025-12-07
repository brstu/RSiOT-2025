# Лабораторная работа №3: StatefulSet с Postgres

## Метаданные студента

- **ФИО:** Казаренко Павел Владимирович
- **Группа:** АС-63
- **StudentID:** 220008
- **Email:** as006305@g.bstu.by
- **GitHub:** Catsker
- **Вариант:** 05
- **Дата:** 27.10.2024

## Вариант 5

- **БД:** Postgres
- **Размер PVC:** 1Gi
- **StorageClass:** premium
- **Расписание бэкапа:** */10 * * * *

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
kubectl create namespace state05

# Применяем все манифесты
kubectl apply -f k8s/

# Проверяем состояние
kubectl get all -n state05
kubectl get pvc -n state05
```

## 3. Проверка работы Postgres

### Подключение к базе

```bash
# Получаем пароль из secret
kubectl get secret -n state05 postgres-secret -o jsonpath='{.data.postgres-password}' | base64 -d

# Port forwarding
kubectl port-forward -n state05 svc/postgres 5432:5432

# Подключение через psql
psql -h localhost -U postgres -d app_220008_v05
```

### Создание тестовых данных

```commandline
-- В psql:
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    student_id VARCHAR(20),
    variant INTEGER
);

INSERT INTO students (name, student_id, variant) 
VALUES ('Казаренко Павел Владимирович', '220008', 5);

SELECT * FROM students;
```

## 4. Проверка сохранности данных

### Рестарт пода

```bash
# Запоминаем текущий под
kubectl get pods -n state05

# Удаляем под
kubectl delete pod -n state05 postgres-0

# Ждем восстановления
kubectl get pods -n state05 -w

# Проверяем данные
kubectl exec -n state05 -it postgres-0 -- psql -U postgres -d app_220008_v05 -c "SELECT * FROM students;"
```

## 5. Бэкап и восстановление

### Проверка работы CronJob

```bash
# Смотрим CronJob
kubectl get cronjob -n state05

# Смотрим созданные Job
kubectl get jobs -n state05

# Проверяем логи бэкапа
kubectl logs -n state05 -l job-name=postgres-backup-<timestamp>

# Проверяем файлы бэкапа
kubectl exec -n state05 -it postgres-0 -- ls -la /backup/
```

### Восстановление из бэкапа

```bash
# Запускаем Job восстановления
kubectl apply -f k8s/07-restore-job.yaml

# Проверяем логи
kubectl logs -n state05 -l job-name=postgres-restore
```

## 6. Архитектура

```text
┌─────────────────────────────────────────┐
│            StatefulSet: postgres        │
│  ┌───────────────────────────────────┐  │
│  │ Pod: postgres-0                   │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │ Container: postgres:16      │  │  │
│  │  │ • Port: 5432                │  │  │
│  │  │ • Volume Mount: /var/lib/   │  │  │
│  │  │   postgresql/data           │  │  │
│  │  └─────────────────────────────┘  │  │
│  │  PVC: postgres-data-postgres-0    │  │
│  │  Storage: 1Gi (premium)           │  │
│  └───────────────────────────────────┘  │
│  Headless Service: postgres             │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│            CronJob: backup              │
│  Schedule: */10 * * * *                 │
│  Job → Pod → pg_dump → PVC backup       │
└─────────────────────────────────────────┘
```

## 7. Очистка

```bash
# Удаление всех ресурсов
kubectl delete -f k8s/

# Или удаление namespace
kubectl delete namespace state05

# Остановка Minikube
minikube stop
```
