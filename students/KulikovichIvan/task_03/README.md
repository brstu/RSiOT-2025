# Лабараторная работа 03

<p align="center">
Министерство образования Республики Беларусь<br>
Учреждение образования<br>
"Брестский Государственный технический университет"<br>
Кафедра ИИТ
</p>

<br><br><br><br><br>

<p align="center">
<strong>Лабораторная работа №3</strong><br>
<strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"<br>
<strong>Тема:</strong> "Kubernetes: состояние и хранение"
</p>

<br><br><br><br><br>

<p align="right">
<strong>Выполнил:</strong><br>
Студент 4 курса<br>
Группы АС-63<br>
Куликович И.С.<br><br>
<strong>Проверил:</strong><br>
Несюк А.Н.
</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

- Обзор StatefulSet, Headless Service, PVC/PV, StorageClass, backup/restore.
- Практика: деплой stateful-сервиса (PostgreSQL), проверка сохранности данных, резервное копирование и восстановление.
- Настройка механизма резервного копирования и восстановления данных в Kubernetes.

---

## Вариант №11

## Метаданные студента

ФИО: Куликович Иван Сергеевич

Группа: AS-63

StudentID: 220015

Email: `AS006312@g.bstu.by`

GitHub username: teenage717

Вариант: 11

ОС: Windows 10 Pro

Docker version: 28.3.2

kubectl version: v1.32.2

Minikube version: v1.37.0

---

## Параметры варианта

| Параметр          | Значение                     |
|-------------------|------------------------------|
| **База данных**   | PostgreSQL                   |
| **Размер PVC**    | 1Gi                          |
| **StorageClass**  | premium                      |
| **Распис backup** | `0 */3 * * *` (каждые 3 часа)|

---

## Архитектура решения

### 1. Компоненты системы

| Компонент               | Описание                                                                 |
|-------------------------|--------------------------------------------------------------------------|
| **StatefulSet**         | `postgres` — основной Pod с PostgreSQL 16                                |
| **Service**             | `postgres` — Headless Service для стабильного DNS                        |
| **CronJob**             | `postgres-backup` — создание резервных копий базы                        |
| **Job**                 | `postgres-restore` — восстановление данных из бэкапа                     |
| **PersistenVolumeClaim**| `data-postgres-0` — автоматическое создание                              |
| **PersisteVolumeClaim** | `backup-pvc` — диск для хранения бэкапов (5Gi)                           |
| **StorageClass**        | `premium` — кастомный StorageClass для production-среды                  |
| **Secret**              | `postgres-secret` — учетные данные для PostgreSQL                        |

---

### 2. Подробное описание архитектуры

#### 2.1 StatefulSet (postgres)

- Управляет одним экземпляром PostgreSQL 16 Alpine.
- Использует `volumeClaimTemplates` для автоматического создания PVC.
- Хранит данные в `/var/lib/postgresql/data`.
- Использует Headless Service `postgres` для стабильного DNS имени.
- **Ресурсы:**
  - Requests: CPU 100m, Memory 256Mi
  - Limits: CPU 500m, Memory 512Mi
- **Probes:**
  - `readinessProbe`: `pg_isready` (initialDelaySeconds: 5, periodSeconds: 5)
  - `livenessProbe`: TCP socket check (initialDelaySeconds: 30, periodSeconds: 10)

#### 2.2 Headless Service (postgres)

- `clusterIP: None` для прямого доступа к pod'ам.
- DNS запись: `postgres-0.postgres.stateful-lab.svc.cluster.local`.
- Используется для подключения из CronJob и Job.
- Port: 5432.

#### 2.3 Secret (postgres-secret)

- Хранит учетные данные PostgreSQL:
  - `POSTGRES_PASSWORD`: `SuperSecret123!`
  - `PGPASSWORD`: `SuperSecret123!`
- Используется StatefulSet'ом, CronJob'ом и Job'ом.

#### 2.4 CronJob (postgres-backup)

- **Расписание:** `0 */3 * * *` (каждые 3 часа).
- Выполняет `pg_dump` для создания дампа базы данных PostgreSQL.
- Сохраняет дамп в PVC для бэкапов (`backup-pvc`).
- Имя файла: `backup-YYYYMMDD-HHMMSS.sql`.
- Логирование в `/backup/backup.log`.
- Использует образ `postgres:16-alpine`.

#### 2.5 Job (postgres-restore)

- Восстанавливает данные из последнего доступного бэкапа.
- Использует `psql` для загрузки SQL-дампа.
- Подключается к работающему экземпляру PostgreSQL.
- Удаляется после успешного выполнения.

#### 2.6 PersistentVolumeClaim

- **Автоматическое (из StatefulSet):** создаётся через `volumeClaimTemplates` с именем `data`.
- **Для бэкапов (backup-pvc):**
  - Размер: 5 Gi
  - AccessMode: ReadWriteOnce
  - StorageClass: `premium`

#### 2.7 StorageClass (premium)

- Provisioner: `kubernetes.io/no-provisioner` (для ручного управления PV).
- `volumeBindingMode`: `WaitForFirstConsumer`.
- `allowVolumeExpansion`: `true`.

---

## Ход выполнения работы

### 1. Подготовка кластера Kubernetes

```bash
# Запуск Minikube кластера
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Проверка доступности StorageClass
kubectl get storageclass

# Создание ручного PersistentVolume
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: manual-pv-premium
  labels:
    type: local
    storage-class: premium
spec:
  storageClassName: premium
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data/premium"
EOF
```

### 2. Развертывание приложения

```bash
# Создание всех ресурсов
kubectl apply -f k8s/

# Проверка состояния развертывания
kubectl get all,pvc,storageclass -n stateful-lab

# Мониторинг запуска пода
kubectl get pods -n stateful-lab -w
```

### 3. Проверка работоспособности

```bash
# Проверка статуса StatefulSet
kubectl get statefulset -n stateful-lab

# Проверка PVC
kubectl get pvc -n stateful-lab

# Проверка логов PostgreSQL
kubectl logs -n stateful-lab -l app=postgres --tail=50
```

### 4. Создание тестовых данных

```bash
# Подключение к PostgreSQL и создание тестовых данных
kubectl exec -it postgres-0 -n stateful-lab -- psql -U postgres -d mydb

-- Внутри psql:
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    salary DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO employees (name, position, salary) VALUES
    ('Иван Иванов', 'Разработчик', 2500.00),
    ('Мария Петрова', 'Аналитик', 2200.00),
    ('Алексей Сидоров', 'Менеджер', 3000.00);

SELECT * FROM employees;
```

### 5. Проверка сохранности данных после перезапуска

```bash
# Удаление пода для проверки сохранности данных
kubectl delete pod postgres-0 -n stateful-lab

# Ожидание восстановления пода
kubectl wait --for=condition=ready pod/postgres-0 -n stateful-lab --timeout=300s

# Проверка сохранности данных
kubectl exec -it postgres-0 -n stateful-lab -- psql -U postgres -d mydb -c "SELECT * FROM employees;"
```

### 6. Тестирование резервного копирования

```bash
# Ручной запуск бэкапа
kubectl create job --from=cronjob/postgres-backup manual-backup -n stateful-lab

# Мониторинг выполнения
kubectl get jobs -n stateful-lab --watch

# Проверка логов бэкапа
kubectl logs -n stateful-lab -l job-name=manual-backup

# Проверка созданных файлов бэкапа
kubectl exec -it postgres-0 -n stateful-lab -- sh -c "ls -lh /backup/"
kubectl exec -it postgres-0 -n stateful-lab -- sh -c "tail -n 10 /backup/backup.log"
```

### 7. Восстановление данных

```bash
# Удаление тестовых данных для демонстрации восстановления
kubectl exec -it postgres-0 -n stateful-lab -- psql -U postgres -d mydb -c "DELETE FROM employees;"
kubectl exec -it postgres-0 -n stateful-lab -- psql -U postgres -d mydb -c "SELECT COUNT(*) FROM employees;"

# Восстановление данных из бэкапа
kubectl apply -f k8s/08-job-restore.yaml

# Проверка выполнения Job
kubectl get jobs -n stateful-lab

# Проверка восстановленных данных
kubectl exec -it postgres-0 -n stateful-lab -- psql -U postgres -d mydb -c "SELECT * FROM employees;"
```

### 8. Проверка автоматического бэкапа

```bash
# Проверка статуса CronJob
kubectl get cronjob -n stateful-lab

# Просмотр расписания
kubectl describe cronjob postgres-backup -n stateful-lab | grep Schedule

# Принудительный запуск следующего бэкапа
kubectl create job --from=cronjob/postgres-backup test-backup -n stateful-lab
```

## Структура проекта

kubernetes-stateful-lab/
├── k8s/
│   ├── namespace.yaml          # Namespace stateful-lab
│   ├── secret.yaml             # Secret с паролями
│   ├── storageclass.yaml       # StorageClass premium
│   ├── pvc-backup.yaml         # PVC для бэкапов (5Gi)
│   ├── service.yaml            # Headless Service
│   ├── statefulset.yaml        # StatefulSet PostgreSQL
│   ├── cronjob-backup.yaml     # CronJob для бэкапов
│   └── job-restore.yaml        # Job для восстановления
├── README.md                   # Документация

## Вывод

В ходе выполнения лабораторной работы №3 были успешно реализованы и протестированы следующие компоненты:

1. **StatefulSet PostgreSQL** с автоматическим созданием PVC через `volumeClaimTemplates`, обеспечивающий сохранность данных при перезапуске подов.
2. **Headless Service** со стабильным DNS именем `postgres-0.postgres.stateful-lab.svc.cluster.local`, используемым для доступа из CronJob и Job.
3. **StorageClass `premium`** с ручным провижинингом, соответствующий требованиям production-среды.
4. **Механизм резервного копирования** через CronJob с расписанием `0 */3 * * *`, создающий SQL-дампы базы данных и сохраняющий их в отдельном PVC.
5. **Процедура восстановления** через Job, который автоматически находит последний бэкап и восстанавливает данные в работающую базу.
6. **Полная проверка сохранности данных** при перезапуске подов, удалении и восстановлении данных.

Все компоненты системы работают корректно, данные сохраняются при перезапусках, резервные копии создаются по расписанию, а восстановление выполняется успешно. Система готова к использованию в production-среде.

**Студент:** Куликович Иван Сергеевич
**Группа:** АС-63
**StudentID:** 220015
**Вариант:** 11
**slug**  as-63-220015-v11
