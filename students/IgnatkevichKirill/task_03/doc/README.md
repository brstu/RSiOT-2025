# Лабораторная работа №3

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №3</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> "Kubernetes: состояние и хранение"</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Игнаткевич К.С.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

* Обзор StatefulSet, Headless Service, PVC/PV, StorageClass, backup/restore.
* Практика: деплой stateful‑сервиса (PostgreSQL), проверка сохранности данных, резервное копирование и восстановление.

---

## Вариант №09

## Метаданные студента

| Поле | Значение |
|------|----------|
| **ФИО** |  | Игнаткевич К.С.
| **Группа** | as-64 |
| **№ студенческого (StudentID)** | 220042 |
| **GitHub username** | pyrokekw |
| **Вариант №** | 09 |
| **Дата выполнения** | 2025-12-17 |

### Slug и Labels

- **slug:** `as-64-220042-v09`
- **Namespace:** `state01`
- **Префиксы ресурсов:** `db`, `backup-pvc`, `db-backup` (CronJob)

---

## Ход выполнения работы

### 1. Архитектура хранения

**StatefulSet:**

- `db` – основной Pod с PostgreSQL 16

**Service:**

- `db` – Headless Service для стабильного DNS

**Pod (для восстановления):**

- `temp-pg-restore` – временный Pod для восстановления данных

**CronJob:**

- `db-backup` – создание резервных копий базы (расписание: `15 */2 * * *`)

**PersistentVolumeClaim (PVC):**

- Автоматическое создание через `volumeClaimTemplates` в StatefulSet (для данных)
- `backup-pvc` – диск для бэкапов (1 Gi)

**StorageClass:**

- `fast` – использует hostpath provisioner для локальной разработки

**Secret:**

- `db-secret` – учетные данные для PostgreSQL

---

### 1. Подробное описание архитектуры

#### 1.1 StatefulSet (db)

- Управляет одним экземпляром PostgreSQL 16
- Использует `volumeClaimTemplates` для автоматического создания PVC
- Хранит данные в `/var/lib/postgresql/data`
- Использует Headless Service `db` для стабильного DNS имени
- **Ресурсы:**
  - Requests: CPU 150m, Memory 128Mi
  - Limits: CPU 300m, Memory 256Mi
- **Probes:**
  - readinessProbe: `pg_isready` (initialDelaySeconds: 20, periodSeconds: 5)
  - livenessProbe: `pg_isready` (initialDelaySeconds: 20, periodSeconds: 10)
  - startupProbe: `pg_isready` (initialDelaySeconds: 20, periodSeconds: 5, failureThreshold: 12)

#### 1.2 Headless Service (db)

- `clusterIP: None` для прямого доступа к pod'ам
- DNS запись: `db-0.db.state01.svc.cluster.local`
- Используется для подключения из CronJob
- Port: 5432

#### 1.3 Secret (db-secret)

- Безопасное хранение учетных данных PostgreSQL:
  - POSTGRES_PASSWORD: `examplepass`
- Используется StatefulSet'ом и CronJob'ом

#### 1.4 CronJob (db-backup)

- Расписание: `15 */2 * * *` (в 15 минут каждые 2 часа)
- Выполняет `pg_dump` для создания дампа базы данных PostgreSQL
- Сохраняет дамп в PVC для бэкапов (`backup-pvc`)
- Имя файла: `db-YYYYMMDDHHMM.sql`
- Использует образ `postgres:16` для запуска утилит

#### 1.5 PersistentVolumeClaim

- **Автоматическое (из StatefulSet):** создается через `volumeClaimTemplates` с именем `data`
- **Для бэкапов (backup-pvc):**
  - Размер: 1 Gi
  - AccessMode: ReadWriteOnce
  - StorageClass: `fast`

#### 1.6 StorageClass (fast)

- Provisioner: `hostpath.csi.k8s.io` (для локальной разработки Kind/Minikube)
- reclaimPolicy: Delete для автоматической очистки
- volumeBindingMode: Immediate

---

## 2 Пошаговое выполнение

### 2.1 Создание Namespace

```bash
kubectl apply -f namespace.yaml
```

### 2.2 Создание StorageClass

```bash
kubectl apply -f storageclass.yaml
```

### 2.3 Создание Secret с учетными данными PostgreSQL

```bash
kubectl apply -f secret.yaml
```

### 2.4 Создание Headless Service

```bash
kubectl apply -f service.yaml
```

### 2.5 Создание StatefulSet PostgreSQL

```bash
kubectl apply -f statefulset.yaml
```

### 2.6 Создание PVC для бэкапов

```bash
kubectl apply -f backup-pvc.yaml
```

### 2.7 Настройка автоматического бэкапа

```bash
kubectl apply -f cronjob.yaml
```

### 2.8 Проверка развертывания

Проверить все ресурсы:

```bash
kubectl get all -n state01
```

Проверить PVC:

```bash
kubectl get pvc -n state01
```

Проверить StatefulSet:

```bash
kubectl get statefulset -n state01 -o wide
```

Проверить Pod PostgreSQL:

```bash
kubectl get pod -n state01 -l app=db -o wide
```

### 2.9 Тестирование бэкапа (ручной запуск)

Запустить бэкап вручную:

```bash
kubectl create job --from=cronjob/db-backup manual-backup -n state01
```

Проверить логи бэкапа:

```bash
kubectl logs -n state01 -l job-name=manual-backup --tail=50
```

Дождаться завершения:

```bash
kubectl wait --for=condition=complete job/manual-backup -n state01 --timeout=60s
```

### 2.10 Восстановление данных из бэкапа

**Запустить временный Pod для восстановления:**

```bash
kubectl apply -f inspect.yaml
```

**Найти последний бэкап:**

```bash
kubectl exec -it temp-pg-restore -n state01 -- ls -lt /backup/
```

**Очистить текущую БД перед восстановлением:**

```bash
kubectl exec -it temp-pg-restore -n state01 -- \
  PGPASSWORD=examplepass psql -h db-0.db.state01.svc.cluster.local \
       -U postgres \
       -d postgres \
       -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
```

**Выполнить восстановление из выбранного бэкапа:**

Пример файла: `db-202512171445.sql`

```bash
kubectl exec -it temp-pg-restore -n state01 -- \
  PGPASSWORD=examplepass psql -h db-0.db.state01.svc.cluster.local \
       -U postgres \
       -d postgres \
       -f /backup/db-202512171445.sql
```

**Удалить временный Pod:**

```bash
kubectl delete pod temp-pg-restore -n state01
```

### 2.11 Проверка восстановления

**Проверить базы данных в PostgreSQL:**

```bash
kubectl exec -it db-0 -n state01 -- \
  PGPASSWORD=examplepass psql -U postgres -c "\l"
```

**Проверить таблицы:**

```bash
kubectl exec -it db-0 -n state01 -- \
  PGPASSWORD=examplepass psql -U postgres -d postgres -c "\dt"
```

**Проверить содержимое таблицы (если есть):**

```bash
kubectl exec -it db-0 -n state01 -- \
  PGPASSWORD=examplepass psql -U postgres -d postgres -c "SELECT * FROM your_table LIMIT 10;"
```

### 2.12 Просмотр логов и статусов

**Логи StatefulSet Pod:**

```bash
kubectl logs -n state01 -l app=db --tail=100 -f
```

**Описание StatefulSet:**

```bash
kubectl describe statefulset db -n state01
```

**Описание Pod:**

```bash
kubectl describe pod db-0 -n state01
```

**Расписание CronJob:**

```bash
kubectl describe cronjob db-backup -n state01 | grep Schedule
```

Должно быть: `Schedule: 15 */2 * * *`

### 2.13 Валидация работы системы

**Проверить, что PostgreSQL работает:**

```bash
kubectl exec -it db-0 -n state01 -- \
  PGPASSWORD=examplepass psql -U postgres -c "SELECT 1;"
```

**Проверить расписание CronJob:**

```bash
kubectl get cronjob -n state01
```

**Проверить наличие бэкапов:**

```bash
kubectl exec -it temp-pg-restore -n state01 -- ls /backup/ | wc -l
```

Должно быть > 0

---

## 3. Команды для локального тестирования (Kind/Minikube)

### Создание кластера Kind

```powershell
kind create cluster --name lab3
```

### Применение всех манифестов

```powershell
cd students/IgantkevichKirill/task_03/src
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/storageclass.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/statefulset.yaml
kubectl apply -f k8s/backup-pvc.yaml
kubectl apply -f k8s/cronjob.yaml
```

Или, если есть `kustomization.yaml`:

```powershell
kubectl apply -k k8s/
```

### Мониторинг развертывания

```powershell
kubectl get all -n state01 --watch
```

### Тестирование данных

```powershell
# Подключиться к PostgreSQL и создать тестовые данные
kubectl exec -it db-0 -n state01 -- \
  PGPASSWORD=examplepass psql -U postgres

# Внутри psql:
# CREATE TABLE test_data (id SERIAL, name TEXT);
# INSERT INTO test_data (name) VALUES ('test1'), ('test2');
# SELECT * FROM test_data;

```

### Удаление ресурсов

```powershell
kubectl delete namespace state01
kind delete cluster --name lab3
```

---

## 4. Скриншоты проверки (примеры)

При выполнении работы в локальном окружении (Kind/Minikube) получаются следующие статусы:

- Все ресурсы созданы: StatefulSet (Ready), Pod (Running), PVC (Bound), CronJob (Active)
- PostgreSQL отвечает на pg_isready: все probes GREEN
- CronJob запускается по расписанию
- Успешный запуск бэкапа (Job Completed)
- Файлы бэкапа существуют в PVC `/backup/`
- Данные успешно восстановлены

---

## Таблица критериев

| Критерий                                                                | Баллы |  Выполнено |
|-------------------------------------------------------------------------|-------|------------|
| StatefulSet и PVC (автоматическое создание через volumeClaimTemplates) | 20    |  ✅        |
| Headless Service для стабильного DNS                                   | 20    |  ✅        |
| Безопасность и конфигурация (Secret)                                    | 20    |  ✅        |
| Автоматическое резервное копирование (CronJob)                          | 20    |  ✅        |
| Восстановление данных из бэкапа                                         | 10    |  ✅        |
| Документация и отчетность                                               | 10    |  ✅        |

---

## Вывод

В ходе выполнения лабораторной работы №3 были закреплены навыки работы с stateful компонентами в Kubernetes:

1. **StatefulSet PostgreSQL** развернут с сохранением данных через volumeClaimTemplates.

2. **Headless Service** обеспечивает стабильный DNS для подключения из CronJob.

3. **StorageClass `fast`** использует hostpath provisioner для локальной разработки.

4. **CronJob `db-backup`** запускается каждые 2 часа (в 15 минут) и создает резервные копии.

5. **Восстановление данных** выполняется через временный Pod с использованием pg_dump/psql.

6. **Все компоненты работают корректно** с валидацией через probes и логи.

Система готова к использованию и демонстрирует полный цикл: запуск, резервное копирование и восстановление данных в Kubernetes.

---

## Структура файлов в репозитории

```
task_03/
├── doc/
│   └── README.md               # Документация (этот файл)
└── src/
    ├── Dockerfile              # Для сборки образа приложения (если нужен)
    ├── docker-compose.yml      # Для локального запуска с Docker
    ├── go.mod / go.sum         # Зависимости Go (если приложение на Go)
    ├── src/
    │   └── server.go           # Исходный код (если приложение на Go)
    └── k8s/
        ├── namespace.yaml      # Namespace state01
        ├── storageclass.yaml   # StorageClass fast
        ├── secret.yaml         # Secret db-secret
        ├── service.yaml        # Headless Service db
        ├── statefulset.yaml    # StatefulSet db (PostgreSQL)
        ├── backup-pvc.yaml     # PVC для бэкапов
        ├── cronjob.yaml        # CronJob для автоматических бэкапов
        └── inspect.yaml        # Pod для восстановления данных
```

---

**Контакты студента:** pyrokekw (GitHub)

**Дата завершения:** 2025-12-17
