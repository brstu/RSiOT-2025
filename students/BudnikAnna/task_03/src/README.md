# ЛР-03 Kubernetes: StatefulSet + PVC + Headless Service + Backup/Restore (Postgres)

## Метаданные студента
- ФИО: <ФИО полностью>
- Группа: <Группа>
- № студенческого (StudentID): <StudentID>
- Email (учебный): <email>
- GitHub username: <username>
- Вариант №: <номер>
- Дата выполнения: <дата>
- ОС (версия): <...>
- Версия Docker Desktop/Engine: <...>
- Версия kubectl: <...>
- Кластер: minikube/kind (версия): <...>

## Параметры варианта
- Service: Postgres (postgres:16)
- PVC (data): 2Gi
- StorageClass: fast
- Backup schedule: "30 * * * *" (каждый час в :30)
- Namespace: state01

## Архитектура
- StatefulSet `db` (1 реплика) с `volumeClaimTemplates` для данных Postgres.
- Headless Service `db` (clusterIP: None) для стабильных DNS:
  `db-0.db.state01.svc.cluster.local`
- Secret `db-secret` хранит пароль Postgres.
- Отдельный PVC `backup-pvc` для хранения дампов.
- CronJob `db-backup` делает `pg_dump` по расписанию и кладёт файл в `/backup`.
- Job `db-restore` восстанавливает данные из последнего дампа (чистит schema public и применяет SQL).

## Деплой
Из каталога `tasks/task_03`:

```bash
kubectl apply -f manifests/00-namespace.yaml
kubectl apply -f manifests/01-storageclass-fast.yaml
kubectl apply -f manifests/02-secret.yaml
kubectl apply -f manifests/03-service-headless.yaml
kubectl apply -f manifests/04-statefulset-postgres.yaml
kubectl apply -f manifests/05-backup-pvc.yaml
kubectl apply -f manifests/06-scripts-configmap.yaml
kubectl apply -f manifests/07-cronjob-backup.yaml
