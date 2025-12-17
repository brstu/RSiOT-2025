# Лабораторная работа №03

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №03</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Kubernetes: состояние и хранение</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Грицук П. Э.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться работать со StatefulSet для управления stateful-приложениями, настроить постоянное хранилище через PVC/PV, создать Headless Service для прямого доступа к подам через DNS.

---

### Вариант №4

## Метаданные студента

- **ФИО:** Грицук Павел Эдуардович
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220007
- **Email (учебный):** <as006304@g.bstu.by>
- **GitHub username:** momo-kitsune
- **Вариант №:** 4
- **ОС и версия:** Windows 11 22H2, Docker Desktop v4.54.0

---

## Окружение и инструменты

Согласно варианту №4:

- **Stateful-сервис:** Redis
- **PVC размер:** 1Gi
- **StorageClass:** fast (требуется по варианту)
- **Расписание backup:** `0 */6 * * *` (каждые 6 часов)

Используемые инструменты:

- Kubernetes (через Docker Desktop или Minikube)
- kubectl
- Redis 7 (Alpine)

## Структура репозитория c описанием содержимого

```
task_03/
├── src/
│   └── manifests/
│       ├── namespace.yaml         # Namespace с метаданными
│       ├── secret.yaml           # Secret для пароля Redis
│       ├── service.yaml          # Headless Service
│       ├── statefulset.yaml      # StatefulSet с Redis
│       └── cronjob-backup.yaml   # CronJob для backup
└── doc/
    └── README.md                 # Документация
```

## Подробное описание выполнения

### 1. Создание Namespace

Создан namespace `state-as63-220007-v04` с метаданными студента в labels.

### 2. Создание Secret

Создан Secret `db-as63-220007-v04-secret` с паролем для Redis (base64: `redis123`).

### 3. Создание Headless Service

Создан Headless Service (`clusterIP: None`) с именем `db-as63-220007-v04` для доступа к подам Redis по стабильным DNS-именам.

### 4. Создание StatefulSet

Создан StatefulSet `db-as63-220007-v04` с:

- 1 реплика Redis
- volumeClaimTemplates для создания PVC размером 1Gi
- Mount point: `/data`
- Использование Secret для пароля

### 5. Настройка backup

Создан CronJob `backup-as63-220007-v04` с расписанием `0 */6 * * *` (каждые 6 часов), который выполняет команду `redis-cli SAVE` для создания snapshot данных.

### Деплой

Применение манифестов:

```bash
kubectl apply -f src/manifests/namespace.yaml
kubectl apply -f src/manifests/secret.yaml
kubectl apply -f src/manifests/service.yaml
kubectl apply -f src/manifests/statefulset.yaml
kubectl apply -f src/manifests/cronjob-backup.yaml
```

Проверка:

```bash
kubectl get statefulset -n state-as63-220007-v04
kubectl get pods -n state-as63-220007-v04
kubectl get pvc -n state-as63-220007-v04
```

## Контрольный список (checklist)

- [ ✅ ] Namespace с метаданными студента
- [ ✅ ] Secret для паролей
- [ ✅ ] Headless Service (clusterIP: None)
- [ ✅ ] StatefulSet с volumeClaimTemplates
- [ ✅ ] CronJob для backup с расписанием

---

## Вывод

В ходе работы были созданы манифесты для развертывания stateful-приложения Redis в Kubernetes: StatefulSet с постоянным хранилищем через PVC, Headless Service для стабильного доступа к подам и CronJob для периодического backup по расписанию (каждые 6 часов). Освоены основные концепции работы со StatefulSet, PersistentVolumeClaim и Kubernetes Services.
