# PostgreSQL StatefulSet Helm Chart

Helm chart для развертывания PostgreSQL с автоматическим резервным копированием в Kubernetes.

## Описание

Этот Helm chart развертывает PostgreSQL в виде StatefulSet с:
- Динамическим хранилищем через PVC/PV
- Headless Service для стабильных DNS-имён
- Автоматическим резервным копированием через CronJob
- Job для восстановления данных

## Параметры варианта 23

- **База данных**: PostgreSQL 15-alpine
- **Размер PVC**: 1Gi
- **StorageClass**: premium-storage (Retain policy)
- **Расписание backup**: `50 * * * *` (каждый час в 50 минут)
- **Backup retention**: 5 последних копий

## Установка

### Базовая установка

```bash
helm install postgres-lab03 ./helm/postgres-stateful --create-namespace
```

### Установка с кастомными значениями

```bash
helm install postgres-lab03 ./helm/postgres-stateful \
  --set postgres.replicas=2 \
  --set storage.data.size=2Gi \
  --create-namespace
```

### Установка из values файла

```bash
helm install postgres-lab03 ./helm/postgres-stateful \
  -f custom-values.yaml \
  --create-namespace
```

## Обновление

```bash
helm upgrade postgres-lab03 ./helm/postgres-stateful
```

## Удаление

```bash
helm uninstall postgres-lab03 -n state-as63-220028-v23
kubectl delete storageclass premium-storage
```

## Проверка перед установкой

### Линтинг chart

```bash
helm lint ./helm/postgres-stateful
```

### Просмотр шаблонов

```bash
helm template postgres-lab03 ./helm/postgres-stateful
```

### Dry-run установки

```bash
helm install postgres-lab03 ./helm/postgres-stateful --dry-run --debug
```

## Основные параметры values.yaml

### Метаданные студента

```yaml
student:
  id: "220028"
  fullname: "Ярмола Александр Олегович"
  group: "АС-63"
  variant: "23"
```

### PostgreSQL конфигурация

```yaml
postgres:
  image:
    repository: postgres
    tag: "15-alpine"
  replicas: 1
  port: 5432
  credentials:
    username: admin
    password: SecurePass123!
    database: testdb
```

### Storage

```yaml
storage:
  data:
    size: 1Gi
    storageClass: premium-storage
    accessMode: ReadWriteOnce
  backup:
    size: 1Gi
    storageClass: standard
    accessMode: ReadWriteMany
```

### Backup

```yaml
backup:
  enabled: true
  schedule: "50 * * * *"
  retention: 5
```

## Команды для работы

### Статус release

```bash
helm status postgres-lab03 -n state-as63-220028-v23
```

### Просмотр значений

```bash
helm get values postgres-lab03 -n state-as63-220028-v23
```

### История версий

```bash
helm history postgres-lab03 -n state-as63-220028-v23
```

### Откат на предыдущую версию

```bash
helm rollback postgres-lab03 -n state-as63-220028-v23
```

## Использование через Makefile

```bash
# Установка через Helm
make helm-install

# Обновление
make helm-upgrade

# Статус
make helm-status

# Удаление
make helm-uninstall

# Линтинг
make helm-lint

# Просмотр шаблонов
make helm-template
```

## Создание тестовых данных

После установки:

```bash
make test-data
```

Или вручную:

```bash
kubectl exec -n state-as63-220028-v23 db-postgres-as63-220028-v23-0 -- \
  psql -U admin -d testdb -c "CREATE TABLE students (id SERIAL PRIMARY KEY, student_id VARCHAR(10), fullname VARCHAR(100));"
```

## Backup и Restore

### Ручной запуск backup

```bash
make backup-now
```

### Восстановление из backup

```bash
make restore
```

## Структура chart

```
helm/postgres-stateful/
├── Chart.yaml                           # Метаданные chart
├── values.yaml                          # Значения по умолчанию
├── .helmignore                          # Игнорируемые файлы
├── README.md                            # Документация (этот файл)
└── templates/                           # Шаблоны манифестов
    ├── _helpers.tpl                     # Helper функции
    ├── namespace.yaml                   # Namespace
    ├── secret.yaml                      # Secret с учетными данными
    ├── storageclass.yaml                # StorageClass
    ├── service.yaml                     # Headless Service
    ├── statefulset.yaml                 # StatefulSet с PostgreSQL
    ├── backup-pvc.yaml                  # PVC для backup
    ├── configmap-scripts.yaml           # Скрипты backup/restore
    ├── cronjob-backup.yaml              # CronJob для backup
    └── job-restore.yaml                 # Job для restore
```

## Метаданные BSTU

Все ресурсы содержат labels и annotations с метаданными:

```yaml
labels:
  org.bstu.course: "RSIOT"
  org.bstu.student.id: "220028"
  org.bstu.group: "AS-63"
  org.bstu.variant: "23"
  org.bstu.owner: "alexsandro007"
  org.bstu.student.slug: "AS63-220028-v23"

annotations:
  org.bstu.student.fullname: "Ярмола Александр Олегович"
```
