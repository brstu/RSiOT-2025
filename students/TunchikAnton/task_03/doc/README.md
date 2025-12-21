# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br>
<p align="center"><strong>Лабораторная работа №3</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> "Kubernetes: состояние и хранение"</p>
<br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Тунчик А.Д.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Вариант №21

**Параметры:**
- База данных: **PostgreSQL**
- PVC: **2Gi**
- StorageClass: **fast**
- Расписание backup: **"20 */5 * * *"**

---

## Архитектура решения

```

┌─────────────────────────────────────┐
│      Namespace: postgres-stateful   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────┐    ┌─────────────┐ │
│  │ StatefulSet │    │   CronJob   │ │
│  │  PostgreSQL │    │    Backup   │ │
│  └──────┬──────┘    └──────┬──────┘ │
│         │                  │         │
│  ┌──────▼──────┐    ┌──────▼──────┐ │
│  │ Headless    │    │    PVC      │ │
│  │  Service    │    │   Backup    │ │
│  └─────────────┘    └──────┬──────┘ │
│                             │         │
│  ┌──────▼──────────────────▼──────┐ │
│  │     StorageClass: fast         │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌─────────────┐                    │
│  │   Secret    │                    │
│  │ (пароли)    │                    │
│  └─────────────┘                    │
└─────────────────────────────────────┘

```

---

## Выполнение работы

### 1. Развертывание компонентов

```bash
# Применение всех манифестов
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/storageclass.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/statefulset.yaml
kubectl apply -f k8s/backup-cronjob.yaml
```

### 2. Проверка развертывания

```bash
# Проверить все ресурсы
kubectl get all,pvc -n postgres-stateful

# Проверить DNS Headless Service
kubectl run -n postgres-stateful -it --rm --image=alpine:3.18 test -- ash -c "nslookup postgres-0.postgres.postgres-stateful.svc.cluster.local"
```

### 3. Тестирование сохранности данных

```bash
# Создать тестовые данные
kubectl -n postgres-stateful exec -it postgres-0 -- psql -U postgres -d testdb -c "
CREATE TABLE test_data (id SERIAL PRIMARY KEY, name VARCHAR(50));
INSERT INTO test_data (name) VALUES ('test1'), ('test2');
SELECT * FROM test_data;"

# Удалить под
kubectl -n postgres-stateful delete pod postgres-0

# Проверить сохранность данных после перезапуска
kubectl -n postgres-stateful exec -it postgres-0 -- psql -U postgres -d testdb -c "SELECT * FROM test_data;"
```

### 4. Резервное копирование

```bash
# Ручной запуск backup
kubectl -n postgres-stateful create job --from=cronjob/postgres-backup manual-backup

# Проверить логи
kubectl -n postgres-stateful logs job/manual-backup

# Проверить файлы бэкапа
kubectl -n postgres-stateful exec -it postgres-0 -- ls -la /backup/
```

### 5. Восстановление данных

```bash
# Удалить данные
kubectl -n postgres-stateful exec -it postgres-0 -- psql -U postgres -d testdb -c "DELETE FROM test_data;"

# Запустить восстановление
kubectl apply -f k8s/restore-job.yaml

# Проверить восстановление
kubectl -n postgres-stateful logs job/postgres-restore
kubectl -n postgres-stateful exec -it postgres-0 -- psql -U postgres -d testdb -c "SELECT * FROM test_data;"
```

---

## Проверка метаданных

Все ресурсы содержат required labels:

```bash
# Проверить labels
kubectl -n postgres-stateful describe statefulset postgres | grep -A5 "Labels:"
```

**Labels на всех ресурсах:**
- `org.bstu.student.fullname: Tunchik Anton Dmitrievich`
- `org.bstu.student.id: 006326`
- `org.bstu.group: AC-63`
- `org.bstu.variant: 21`
- `org.bstu.course: RSIOT`
- `slug: ac-63--v21`

## Вывод

Развернут stateful PostgreSQL в Kubernetes с использованием:
- StatefulSet для управления подами
- Headless Service для стабильных DNS имен
- PVC 2Gi с StorageClass fast
- Автоматическое резервное копирование каждые 5 часов (CronJob)
- Возможность восстановления данных (Job)
