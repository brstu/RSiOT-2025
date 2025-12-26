# Министерство образования Республики Беларусь

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
<p align="right">Группы АС-63</p>
<p align="right">Грицук Д.Ю.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

* Обзор StatefulSet, Headless Service, PVC/PV, StorageClass, backup/restore.
* Практика: деплой stateful‑сервиса (Postgres/Redis/MinIO), проверка сохранности данных, резервное копирование и восстановление.

---

### Вариант №3

## Ход выполнения работы

### 1. Архитектура хранения

┌─────────────────────────────────────────────────────────────┐
│                       Namespace: state24                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │  StatefulSet│    │   CronJob    │    │     Pod      │    │
│  │    postgres │    │postgres-backup│   │ temp-restore │    │
│  └──────┬──────┘    └──────┬───────┘    └──────┬───────┘    │
│         │                  │                    │           │
│  ┌──────▼──────┐    ┌──────▼──────┐     ┌──────▼──────┐     │
│  │   Service   │    │     PVC     │     │     PVC     │     │
│  │ (headless)  │    │postgres-backup│   │postgres-data│     │
│  └─────────────┘    │   -pvc      │     │     -0      │     │
│                     └──────┬──────┘     └──────┬──────┘     │
│                            │                   │            │
│                     ┌──────▼───────────────────▼──────┐     │
│                     │      StorageClass: fast         │     │
│                     └─────────────────────────────────┘     │
│                                                             │
│  ┌─────────────┐    ┌─────────────────┐                     │
│  │   Secret    │    │  PVC (manual)   │                     │
│  │postgres-secret│  │postgres-pvc.yaml│                     │
│  └─────────────┘    └─────────────────┘                     │
└─────────────────────────────────────────────────────────────┘

Описание компонентов:

### 1. PostgreSQL StatefulSet

- Использует PostgreSQL 15 Alpine
- Настроены liveness и readiness probes
- Данные хранятся в /var/lib/postgresql/data
- Автоматическое создание PVC через volumeClaimTemplates

### 2. Headless Service

- clusterIP: None для прямого доступа к pod'ам
- DNS имя: postgres-0.postgres.state24.svc.cluster.local

### 3. CronJob для бэкапо

- Запускается по расписанию `"30 * * * *"`
- Использует pg_dump для создания SQL-дампа
- Хранит последние 10 бэкапов
- Автоматически удаляет старые бэкапы

### 4. StorageClass

- Имя: fast
- Provisioner: docker.io/hostpath (для локального тестирования)
- Поддерживает расширение томов

---

### 2 Пошаговое выполнение

#### Создать все ресурсы

```bash
# Создать все ресурсы
kubectl apply -f deploy-all.yaml

# Проверить состояние
kubectl get all -n state24
kubectl get pvc -n state24
kubectl get cronjob -n state24

# Проверить логи PostgreSQL
kubectl logs -n state24 statefulset/postgres --tail=20

# Запустить бэкап вручную
kubectl create job --from=cronjob/postgres-backup manual-backup -n state24
```

---

## Таблица критериев

| Критерий                                                                | Баллы |  Выполнено |
|-------------------------------------------------------------------------|-------|------------|
| StatefulSet и PVC                                                       |  20   |  ✅ / ✅  |
| Headless Service                                                        |  20   |  ✅ / ✅  |
| Безопасность и конфигурация                                             |  20   |  ✅ / ✅  |
| Автоматическое резервное копирование                                    |  20   |  ✅ / ✅  |
| Восстановление данных                                                   |  10   |  ✅ / ✅  |
| Документация и отчетность                                               |  10   |  ✅ / ✅  |

---

## Вывод

Развернут Redis в Kubernetes с сохранением данных. Настроены автоматические бэкапы и восстановление. Все компоненты работают корректно. Система готова к использованию.
