# Go net/http Service with Redis

## Description

Лабораторная работа №3
**stateful-приложения Postgres** в **Kubernetes** с использованием:
- **StatefulSet** (стабильные имена pod’ов `db-0`, упорядоченный запуск/перезапуск)
- **PVC/StorageClass** для постоянного хранения данных
- **Headless Service** (`clusterIP: None`) для стабильного DNS-доступа к pod’у
- **CronJob** для регулярного **backup** (pg_dump) по расписанию варианта
- **Job** для **restore** из последнего бэкапа

Версия: **v2**

---

## Метаданные студента

- ФИО: Будник Анна
- Группа: АС-64
- № студенческого (StudentID): 220033
- Email (учебный): 
- GitHub username: annettebb
- Вариант №: №3
- Дата выполнения: 18.12.2025
- ОС (версия): сборка ОС 19045.6456
- Версия Docker Desktop/Engine: 

---

## Параметры варианта

- **db:** Postgres
- **PVC (data):** `2Gi`
- **StorageClass:** `fast`
- **backup schedule:** `"30 * * * *"` (каждый час в :30)
- Namespace: `state01`
- Каталог манифестов: `k8s/`

---

## Architecture (Kubernetes objects)

- `Namespace` **state01**
- `Secret` **db-secret** — пароль Postgres
- `Service` **db** (Headless, `clusterIP: None`) — DNS вида:  
  `db-0.db.state01.svc.cluster.local`
- `StatefulSet` **db** — Postgres + `volumeClaimTemplates` (данные БД)
- `PVC` **backup-pvc** — отдельное хранилище для бэкапов
- `CronJob` **db-backup** — делает `pg_dump` и пишет файлы в `/backup`
- `Job` **db-restore** — восстанавливает из последнего `.sql` в `/backup`

---

## Deploy & Verify

### 1) Применить манифесты
Из корня папки `tasks/task_03`:

```bash
kubectl apply -f k8s/
