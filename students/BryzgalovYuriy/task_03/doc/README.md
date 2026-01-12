# Лабораторная работа №03

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №03</strong></p>
<p align="center"><strong>По дисциплине:</strong> “Распределенные системы и облачные технологии”</p>
<p align="center"><strong>Тема:</strong> Kubernetes: состояние и хранение (StatefulSet, PVC/PV, Headless Service, backup/restore)</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Брызгалов Ю. Н.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Развернуть stateful-приложение PostgreSQL в Kubernetes: применить StatefulSet, настроить постоянное хранилище через PVC/PV, создать Headless Service для стабильных DNS-имён подов, добавить периодический backup (CronJob) и Job для восстановления данных, проверить сохранность данных при перезапуске пода.

---

### Вариант №02

## Метаданные студента

- **ФИО:** Брызгалов Юрий Николаевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220032
- **Email (учебный):** <as006402@g.bstu.by>
- **GitHub username:** Gena_Cidarmyan
- **Вариант №:** 02
- **ОС и версия:** Windows 11, Docker Desktop v4.53.0

---

## Структура файлов

backup-cronjob.yaml      – CronJob для резервного копирования Redis
backup-pvc.yaml         – PVC для хранения резервных копий
headless-service.yaml   – Headless Service для Redis
namespace.yaml          – Namespace
restore-job.yaml        – Job для восстановления данных
secret.yaml             – Secret с паролем Redis
statefulset.yaml        – StatefulSet Redis
storageclass.yaml       – StorageClass

## Описание реализации

1. Namespace

Создан отдельный namespace:

apiVersion: v1
kind: Namespace
metadata:
  name: state01

Он используется для логической изоляции ресурсов лабораторной работы.

1. Secret

Для хранения пароля Redis используется Secret:

REDIS_PASSWORD: "redispass"

Пароль передаётся в контейнер через переменную окружения.

1. Хранилище данных (PVC + StorageClass)

Создан StorageClass:

provisioner: rancher.io/local-path

Для Redis используется PVC:

storage: 2Gi
accessModes: ReadWriteOnce

Данные Redis сохраняются в каталоге:

/data
4. Headless Service

Создан Headless Service:

clusterIP: None

Он обеспечивает стабильное DNS-имя для пода Redis:

db-redis-0.db-redis
5. StatefulSet

Redis разворачивается через StatefulSet:

replicas: 1

Используется пароль

Подключён PVC

Порт: 6379

Команда запуска:

redis-server --requirepass $(REDIS_PASSWORD)
6. Резервное копирование (CronJob)

CronJob запускается каждый час:

```yaml

schedule: "0 * * * *"

```

Он выполняет:

redis-cli -a redispass SAVE
cp /data/dump.rdb /backup/dump-<час>.rdb

Резервные копии сохраняются в PVC backup-pvc.

1. Восстановление данных (Job)

Job restore-redis копирует backup обратно:

cp /backup/dump-*.rdb /data/dump.rdb

После запуска Job Redis получает восстановленные данные.

## Команды для запуска

kubectl apply -f storageclass.yaml
kubectl apply -f namespace.yaml
kubectl apply -f secret.yaml
kubectl apply -f headless-service.yaml
kubectl apply -f statefulset.yaml
kubectl apply -f backup-pvc.yaml
kubectl apply -f backup-cronjob.yaml
kubectl apply -f restore-job.yaml

Проверка пода:

kubectl get pods -n state-feis-41-123456-v3

## Контрольный список

[✅] Namespace
[✅] Secret
[✅] StorageClass
[✅] PVC
[✅] StatefulSet
[✅] Headless Service
[✅] CronJob (backup)
[✅] Job (restore)
[✅] Сохранение данных

## Вывод

В ходе лабораторной работы было развернуто stateful-приложение Redis в Kubernetes.
Реализованы:
Постоянное хранилище данных
Стабильные DNS-имена
Резервное копирование
Восстановление данных
Данные Redis сохраняются при перезапуске пода, что подтверждает корректность использования StatefulSet и PVC.
