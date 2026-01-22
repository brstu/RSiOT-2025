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
<p align="right">Выржемковский Д. И.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Вариант №2

**Параметры:**

- База данных: **Redis**
- PVC: **2Gi**
- StorageClass: **standard**
- Расписание backup: **"0 * * * *"** (каждый час в 0 минут)

---

## Архитектура решения

```bash

┌─────────────────────────────────────────────┐
│           Kubernetes Cluster                │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │      StatefulSet: redis             │    │
│  │  ┌─────────────┐                    │    │
│  │  │    Pod-0    │◄───────────────────┤    │
│  │  │  (redis)    │    Persistent      │    │
│  │  └──────┬──────┘    Volume Claim    │    │
│  │         │         (2Gi, standard)   │    │
│  └─────────┼───────────────────────────┘    │
│            │                                │
│  ┌─────────▼─────────┐    ┌───────────────┐ │
│  │ Headless Service  │    │   CronJob     │ │
│  │  redis-headless   │    │   Backup      │ │
│  │  redis-service    │    │  (каждый час) │ │
│  └───────────────────┘    └───────┬───────┘ │
│                                    │        │
│                           ┌────────▼──────┐ │
│                           │   PVC Backup  │ │
│                           │     (2Gi)     │ │
│                           └───────────────┘ │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │        Secret: redis-secret         │    │
│  │    (пароль: superSecretPassword123) │    │
│  └─────────────────────────────────────┘    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │     StorageClass: standard          │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

---

## Файлы проекта

### Структура файлов

```bash

task_03/
├── redis-statefulset.yaml          # StatefulSet для Redis
├── redis-service.yaml              # Headless Service + ClusterIP Service
├── redis-secret.yaml               # Secret с паролем
├── storageclass.yaml               # StorageClass + PV + PVC для бэкапов
├── redis-backup-job.yaml           # Job для ручного бэкапа
├── redis-backup-cronjob.yaml       # CronJob для автоматического бэкапа
├── redis-restore-job.yaml          # Job для восстановления
└── test-data/
    ├── create-test-data.yaml       # Job для создания тестовых данных
    └── verify-data.yaml            # Job для проверки данных
```

---

## Выполнение работы

### 1. Развертывание компонентов

```bash
# 1. Создаем секрет с паролем Redis
kubectl apply -f redis-secret.yaml

# 2. Создаем StorageClass, PersistentVolume и PVC для бэкапов
kubectl apply -f storageclass.yaml

# 3. Создаем сервисы (Headless + ClusterIP)
kubectl apply -f redis-service.yaml

# 4. Развертываем StatefulSet Redis
kubectl apply -f redis-statefulset.yaml

# Ждем запуска Redis (30-60 секунд)
sleep 30

# Проверяем созданные ресурсы
kubectl get all,pvc,secret
```

### 2. Тестирование StatefulSet и PVC

```bash
# Проверить состояние StatefulSet и подов
kubectl get statefulset
kubectl get pods

# Проверить созданные PVC
kubectl get pvc

# Проверить сервисы
kubectl get services | grep redis

# Проверить DNS имена Headless Service
kubectl run -it --rm --image=busybox:1.28 dns-test -- nslookup redis-0.redis-headless.default.svc.cluster.local
```

### 3. Создание и проверка тестовых данных

```bash
# 1. Создаем тестовые данные в Redis
kubectl apply -f test-data/create-test-data.yaml

# Проверить логи создания данных
kubectl logs -l job-name=create-test-data

# 2. Проверяем созданные данные
kubectl apply -f test-data/verify-data.yaml

# Посмотреть результат проверки
kubectl logs -l job-name=verify-test-data
```

**Тестовые данные включают:**

- Информацию о студенте (ФИО, группа, номер студенческого)
- Контактные данные (email, GitHub)
- Информацию о задании
- Списки курсов и технологий
- Навыки студента и ключевые слова задания

### 4. Проверка сохранности данных после перезапуска

```bash
# 1. Проверить текущие данные
kubectl apply -f test-data/verify-data.yaml
sleep 5
kubectl logs -l job-name=verify-test-data

# 2. Удалить pod для тестирования восстановления StatefulSet
kubectl delete pod redis-0

# 3. Дождаться пересоздания пода
kubectl get pods -w
# После восстановления пода продолжить...

# 4. Проверить данные после перезапуска
kubectl apply -f test-data/verify-data.yaml
sleep 5
kubectl logs -l job-name=verify-test-data

# Данные должны сохраниться благодаря PersistentVolume
```

### 5. Резервное копирование данных

#### 5.1 Ручное резервное копирование

```bash
# Запуск ручного бэкапа
kubectl apply -f redis-backup-job.yaml

# Проверить логи бэкапа
kubectl logs -l job-name=redis-backup-manual

# Проверить созданные файлы бэкапа
kubectl exec -it redis-0 -- ls -la /backup/
```

#### 5.2 Автоматическое резервное копирование (CronJob)

```bash
# Запустить CronJob для бэкапа каждый час
kubectl apply -f redis-backup-cronjob.yaml

# Проверить CronJob
kubectl get cronjobs

# Можно вручную запустить бэкап из CronJob
kubectl create job --from=cronjob/redis-backup-cron manual-cron-backup

# Проверить результат
kubectl logs job/manual-cron-backup
```

**Что сохраняется в бэкапе:**

- RDB дамп базы данных
- Список всех ключей
- Текстовый дамп данных
- Метаинформация (время, данные студента)

### 6. Восстановление данных

```bash
# 1. Удалить тестовые данные для демонстрации восстановления
kubectl run redis-cleanup --rm -it --image=redis:7-alpine -- \
  redis-cli -h redis-service -a superSecretPassword123 FLUSHALL

# 2. Проверить, что данные удалены
kubectl apply -f test-data/verify-data.yaml
sleep 5
kubectl logs -l job-name=verify-test-data

# 3. Запустить восстановление из бэкапа
kubectl apply -f redis-restore-job.yaml

# 4. Проверить логи восстановления
kubectl logs -l job-name=redis-restore

# 5. Проверить восстановленные данные
kubectl apply -f test-data/verify-data.yaml
sleep 5
kubectl logs -l job-name=verify-test-data
```

### 7. Полная проверка всех компонентов

```bash
# Проверка всех метаданных ресурсов
echo "=== ПРОВЕРКА МЕТАДАННЫХ РЕСУРСОВ ==="

echo "1. StatefulSet метки:"
kubectl describe statefulset redis | grep -A2 "Labels:"

echo "2. Secret метки:"
kubectl describe secret redis-secret | grep -A2 "Labels:"

echo "3. Service метки:"
kubectl describe service redis-headless | grep -A2 "Labels:"

echo "4. PVC метки:"
kubectl describe pvc redis-data-redis-0 | grep -A2 "Labels:"

echo "5. CronJob метки:"
kubectl describe cronjob redis-backup-cron | grep -A2 "Labels:"

echo "=== ПРОВЕРКА ЗАВЕРШЕНА ==="
```

---

## Проверка метаданных

Все ресурсы содержат следующие labels согласно заданию:

```yaml
labels:
  app: redis
  student: vyrzhemkovskiy-daniil
  group: ac-63
  variant: 2
```

**Дополнительная информация:**

- **Студент:** Выржемковский Даниил Иванович
- **Группа:** AC-63
- **Номер студенческого:** 006305
- **Вариант:** 2
- **Email:** <danikv0305@gmail.com>
- **GitHub:** romb123

---

## Команды для проверки работоспособности

```bash
# 1. Проверить подключение к Redis изнутри кластера
kubectl run redis-test --rm -it --image=redis:7-alpine -- \
  redis-cli -h redis-service -a superSecretPassword123 ping

# 2. Проверить статистику Redis
kubectl run redis-stats --rm -it --image=redis:7-alpine -- \
  redis-cli -h redis-service -a superSecretPassword123 info

# 3. Проверить Persistent Volume
kubectl get pv
kubectl describe pv redis-pv

# 4. Проверить расписание CronJob
kubectl get cronjob redis-backup-cron -o yaml | grep schedule
```

---

## Очистка ресурсов

```bash
# Удалить все созданные ресурсы
kubectl delete -f redis-secret.yaml
kubectl delete -f storageclass.yaml
kubectl delete -f redis-service.yaml
kubectl delete -f redis-statefulset.yaml
kubectl delete -f redis-backup-cronjob.yaml
kubectl delete -f redis-backup-job.yaml
kubectl delete -f redis-restore-job.yaml
kubectl delete -f test-data/create-test-data.yaml
kubectl delete -f test-data/verify-data.yaml

# Проверить, что все ресурсы удалены
kubectl get all,pvc,secret | grep redis
```
