# Лабораторная работа №03

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №03</strong></p>
<p align="center"><strong>По дисциплине:</strong> “Распределенные системы и облачные технологии”</p>
<p align="center"><strong>Тема:</strong> Kubernetes: состояние и хранение</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Белаш А. О.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Развернуть stateful-приложение Postgres в Kubernetes с использованием StatefulSet, постоянного хранилища (PVC/PV), Headless Service, резервного копирования и восстановления данных через CronJob и Job.

---

### Вариант №25

## Метаданные студента

- **ФИО:** Белаш Александр Олегович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220031
- **Email (учебный):** <as006401@g.bstu.by>
- **GitHub username:** went2smoke
- **Вариант №:** 25
- **ОС и версия:** Windows 10 1891, Docker Desktop v4.52.0

---

## Окружение и инструменты

- Kubernetes (локальный кластер, 1 нода)
- `kubectl` (команды ниже)
- Официальный образ `postgres:16-alpine`
- StorageClass с статическим провижинингом (hostPath)

## Структура репозитория c описанием содержимого

```
src/                   # все исходные артефакты
  k8s/                 # Kubernetes-манифесты
    postgres.yaml      # Namespace, StorageClass, PV, PVC, Secret, Headless Service, StatefulSet
    backup-restore.yaml# CronJob (backup), Job (restore)
doc/
  README.md            # единственная документация (этот файл)
```

## Подробное описание выполнения

1. Создан Namespace `state-as64-220031-v25` и заданы метки/аннотации `org.bstu.*`.
2. Настроен `StorageClass` с `kubernetes.io/no-provisioner` и два `PersistentVolume` (статические) для данных и бэкапа (по 1Gi).
3. Добавлен `Secret` с учётными данными `POSTGRES_USER=user25`, `POSTGRES_PASSWORD=pass25`.
4. Развёрнут `StatefulSet` (реплика 1) для Postgres с `volumeClaimTemplates` (1Gi, `standard`). Логируются `STU_ID`, `STU_GROUP`, `STU_VARIANT` при старте.
5. Создан `Headless Service` для стабильных DNS имён подов.
6. Настроен `CronJob` (каждые 18 минут) выполняющий `pg_dump` в PVC бэкапа.
7. Добавлен `Job` для восстановления из последней резервной копии.

### Команды деплоя и проверки

```bash
kubectl apply -f src/k8s/postgres.yaml
kubectl apply -f src/k8s/backup-restore.yaml

# Проверить
kubectl -n state-as64-220031-v25 get pods,svc,pvc,pv

# Создать тестовые данные (пример)
kubectl -n state-as64-220031-v25 exec -it statefulset/db-as64-220031-v25 -- \
  sh -c "psql -U user25 -d postgres -c 'CREATE TABLE t(i int); INSERT INTO t VALUES (25);'"

# Принудительно перезапустить под
kubectl -n state-as64-220031-v25 delete pod db-as64-220031-v25-0

# Проверить сохранность
kubectl -n state-as64-220031-v25 exec -it statefulset/db-as64-220031-v25 -- \
  sh -c "psql -U user25 -d postgres -c 'SELECT * FROM t'"

# Запустить разово backup (ожидать выполнения CronJob или запустить Job из CronJob вручную)
kubectl -n state-as64-220031-v25 create job --from=cronjob/backup-as64-220031-v25 backup-once-$(date +%s)

# Просмотреть файлы бэкапа
kubectl -n state-as64-220031-v25 exec -it statefulset/db-as64-220031-v25 -- ls -l /var/lib/postgresql/data
kubectl -n state-as64-220031-v25 get pvc backup-as64-220031-v25-pvc
```

### Восстановление

```bash
# Очистить данные (демо)
kubectl -n state-as64-220031-v25 exec -it statefulset/db-as64-220031-v25 -- \
  sh -c "psql -U user25 -d postgres -c 'DROP TABLE IF EXISTS t'"

# Запустить Job восстановления
kubectl apply -f src/k8s/backup-restore.yaml  # (если ещё не применён)
kubectl -n state-as64-220031-v25 create job --from=cronjob/backup-as64-220031-v25 backup-once-restore-prep
kubectl -n state-as64-220031-v25 apply -f src/k8s/backup-restore.yaml  # восстановление job уже присутствует
kubectl -n state-as64-220031-v25 logs job/restore-as64-220031-v25

# Проверить
kubectl -n state-as64-220031-v25 exec -it statefulset/db-as64-220031-v25 -- \
  sh -c "psql -U user25 -d postgres -c 'SELECT * FROM t'"
```

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Kubernetes манифесты: StatefulSet, Headless Service, Secret, PV/PVC
- [✅] CronJob для backup по расписанию
- [✅] Job для restore (восстановление из последнего файла)
- [✅] StorageClass и провизионирование хранилища
- [✅] Проверка сохранности данных после перезапуска подов

---

## Ссылкы(если требует задание)

—

## Вывод

Успешно реализовано stateful-приложение Postgres в Kubernetes со стабильными DNS имена подов через Headless Service, постоянным хранилищем данных на PersistentVolume, периодическим резервным копированием через CronJob и восстановлением из backup через Job. Демонстрирована сохранность данных после перезапуска подов и работоспособность механизма backup/restore.
