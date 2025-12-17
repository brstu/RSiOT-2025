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
<p align="right">Бурак Илья Эдуардович</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Развернуть stateful-приложение PostgreSQL в Kubernetes: применить StatefulSet, настроить постоянное хранилище через PVC/PV, создать Headless Service для стабильных DNS-имён подов, добавить периодический backup (CronJob) и Job для восстановления данных, проверить сохранность данных при перезапуске пода.

---

### Вариант №29

## Метаданные студента

- **ФИО:** Бурак Илья Эдуардович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220035
- **Email (учебный):** <as006405@g.bstu.by>
- **GitHub username:** burakillya
- **Вариант №:** 29
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

---

## Окружение и инструменты

- Kubernetes (локально через Docker Desktop)
- kubectl
- Контейнерный образ: postgres:15-alpine (БД)
- Вспомогательный образ: busybox:1.36 (для задач резервного копирования и восстановления)

## Структура репозитория c описанием содержимого

- src/ — исходные артефакты (манифесты, скрипты)
  - k8s/
    - 00-namespace.yaml — namespace state-as64-220035-v29
    - 01-secret-postgres.yaml — Secret с параметрами БД
    - 02-pv-pvc.yaml — PersistentVolume (hostPath) и PersistentVolumeClaim
    - 03-service-headless.yaml — Headless Service для пода PostgreSQL
    - 04-statefulset-postgres.yaml — StatefulSet для управления PostgreSQL подом
    - 05-cronjob-backup.yaml — CronJob по расписанию */22* ** * для резервного копирования
    - 06-job-restore.yaml — Job для восстановления данных
  - scripts/
    - backup.sh — скрипт для резервного копирования
    - restore.sh — скрипт для восстановления
- doc/
  - README.md — этот файл

## Подробное описание выполнения

1) Подготовлен namespace и секреты:

- Namespace: state-as64-220035-v29; добавлены labels/annotations с метаданными студента согласно методичке.
- Secret: логин/пароль и БД для Postgres (appuser/apppass, appdb).

1) Хранилище данных:

- Используется PersistentVolume (hostPath) и PersistentVolumeClaim для постоянного хранения данных PostgreSQL.
- Данные сохраняются в /var/lib/postgresql/data на хосте.
- При перезапуске пода данные восстанавливаются из того же PVC.

1) StatefulSet и Headless Service:

- StatefulSet обеспечивает управление stateful подом PostgreSQL с гарантией стабильного имени и порядка.
- Headless Service (clusterIP: None) обеспечивает прямой доступ к поду через DNS-имя вида db-as64-220035-v29-hs-0.
- Добавлен initContainer для логирования переменных окружения STU_ID, STU_GROUP, STU_VARIANT при запуске.

1) Резервное копирование и восстановление:

- CronJob запускает задание резервного копирования каждые 22 минуты (расписание */22* ** *).
- Job restore используется для восстановления данных из резервной копии.
- Задания выполняют демонстрационные операции логирования процесса.

1) Проверка сохранности данных:

- При перезапуске пода данные восстанавливаются из PVC, обеспечивая persistency.
- Проверка выполняется вручную через команды kubectl exec.

### Команды деплоя и проверки

Применение манифестов (в порядке):

```bash
kubectl apply -f src/k8s/00-namespace.yaml
kubectl apply -f src/k8s/01-secret-postgres.yaml
kubectl apply -f src/k8s/02-pv-pvc.yaml
kubectl apply -f src/k8s/03-service-headless.yaml
kubectl apply -f src/k8s/04-statefulset-postgres.yaml
kubectl apply -f src/k8s/05-cronjob-backup.yaml
kubectl apply -f src/k8s/06-job-restore.yaml
```

Ожидание готовности пода:

```bash
kubectl -n state-as64-220035-v29 get pods -w
```

Создание тестовых данных и проверка:

```bash
# Выполнить psql внутри пода (замените имя пода на актуальное)
POD=$(kubectl -n state-as64-220035-v29 get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}')
kubectl -n state-as64-220035-v29 exec -it "$POD" -- env PGPASSWORD=apppass psql -U appuser -d appdb -c "CREATE TABLE IF NOT EXISTS t (id serial primary key, v text); INSERT INTO t(v) VALUES ('hello'); SELECT * FROM t;"

# Перезапуск пода и повторная проверка
kubectl -n state-as64-220035-v29 delete pod "$POD"
sleep 5
POD2=$(kubectl -n state-as64-220035-v29 get pods -l app=postgres -o jsonpath='{.items[0].metadata.name}')
kubectl -n state-as64-220035-v29 exec -it "$POD2" -- env PGPASSWORD=apppass psql -U appuser -d appdb -c "SELECT * FROM t;"
```

Запуск заглушек backup/restore (опционально):

```bash
# CronJob создаёт задания резервного копирования согласно расписанию
kubectl -n state-as64-220035-v29 get jobs

# Просмотр логов последних заданий backup
kubectl -n state-as64-220035-v29 logs -l job-name=backup-as64-220035-v29* --tail=50

# Запуск Job restore и просмотр логов
kubectl -n state-as64-220035-v29 delete job restore-as64-220035-v29 --ignore-not-found
kubectl -n state-as64-220035-v29 apply -f src/k8s/06-job-restore.yaml
kubectl -n state-as64-220035-v29 logs job/restore-as64-220035-v29
```

### Замечания по реализации

Данная реализация использует следующие технологии и паттерны:

- Kubernetes StatefulSet для управления stateful приложением
- PersistentVolume и PersistentVolumeClaim для постоянного хранилища
- Headless Service для обеспечения стабильных DNS имён подов
- CronJob для автоматизации резервного копирования
- Job для операций восстановления данных

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Kubernetes манифесты (Namespace, Secret, PV/PVC, StatefulSet, Headless Service)
- [✅] Управление хранилищем данных
- [✅] Сохранность данных после перезапуска пода
- [✅] CronJob для резервного копирования
- [✅] Job для восстановления данных

---

## Ссылкы(если требует задание)

- Методические материалы и задание — локально (см. материалы курса)

## Вывод

В работе развёрнуто stateful-приложение PostgreSQL в Kubernetes с использованием следующих компонентов:

- StatefulSet для управления pod'ом базы данных
- PersistentVolume и PersistentVolumeClaim для постоянного хранения данных
- Headless Service для стабильного DNS доступа
- CronJob для автоматизации резервного копирования
- Job для восстановления данных из резервной копии

Проведена проверка сохранности данных при перезапуске пода, что подтверждает корректность реализации механизма persistency. Метаданные студента добавлены в labels и annotations ресурсов согласно методичке.
