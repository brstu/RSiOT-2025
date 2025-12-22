# Лабораторная работа №3

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №3</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Kubernetes: состояние и хранение</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Карпеш Н.П.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться работать со StatefulSet для управления stateful-приложениями, настроить постоянное хранилище через PVC/PV и StorageClass, создать Headless Service для прямого доступа к подам через DNS, реализовать механизм резервного копирования данных.

---

### Вариант №37

## Метаданные студента

- **ФИО:** Карпеш Никита Петрович
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220009
- **Email (учебный):** as006311@g.bstu.by
- **GitHub username:** Frosyka
- **Вариант №:** 6
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

**Параметры варианта:**

- База данных: PostgreSQL
- PVC: 3Gi
- StorageClass: standard
- Расписание backup: "5 6 \* \* \*"

---

## Окружение и инструменты

- **Kubernetes:** Minikube/Kind (локальный кластер)
- **База данных:** PostgreSQL 15
- **kubectl:** для управления ресурсами Kubernetes
- **Образ БД:** postgres:15

---

## Структура репозитория c описанием содержимого

```
task_03/
├── src/                           # Kubernetes манифесты
│   ├── namespace.yaml             # Namespace для изоляции ресурсов
│   ├── secret.yaml                # Secret с паролем БД
│   ├── service.yaml               # Headless Service
│   ├── statefulset.yaml           # StatefulSet для PostgreSQL
│   └── cronjob-backup.yaml        # CronJob для backup
└── doc/
    └── README.md                  # Документация
```

---

## Подробное описание выполнения

### 1. Создание Namespace

Создан namespace `state-as64-220050-v37` с метаданными студента в labels:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: state-as64-220050-v37
  labels:
    org.bstu.student.id: "220050"
    org.bstu.group: "АС-64"
    org.bstu.variant: "37"
```

### 2. Создание Secret

Secret содержит пароль для PostgreSQL (base64-encoded):

```bash
kubectl apply -f src/secret.yaml
```

### 3. Развёртывание Headless Service

Создан Headless Service (clusterIP: None) для стабильных DNS-имён подов:

```bash
kubectl apply -f src/service.yaml
```

### 4. Развёртывание StatefulSet

StatefulSet разворачивает PostgreSQL с volumeClaimTemplates:
- Replicas: 1
- PVC: 3Gi, storageClass: standard
- Volume mount: `/var/lib/postgresql/data`

```bash
kubectl apply -f src/statefulset.yaml
```

Проверка:

```bash
kubectl get statefulset -n state-as64-220050-v37
kubectl get pvc -n state-as64-220050-v37
kubectl get pods -n state-as64-220050-v37
```

### 5. Тестирование сохранности данных

Подключение к PostgreSQL и создание тестовой таблицы:

```bash
kubectl exec -it db-as64-220050-v37-0 -n state-as64-220050-v37 -- psql -U postgres -d testdb
```

SQL команды:

```sql
CREATE TABLE test_data (id SERIAL PRIMARY KEY, name VARCHAR(100));
INSERT INTO test_data (name) VALUES ('test1'), ('test2');
SELECT * FROM test_data;
```

Перезапуск пода:

```bash
kubectl delete pod db-as64-220050-v37-0 -n state-as64-220050-v37
```

После перезапуска данные должны сохраниться благодаря PVC.

### 6. Настройка резервного копирования

Создан CronJob для периодического backup по расписанию `5 6 * * *` (каждый день в 06:05):

```bash
kubectl apply -f src/cronjob-backup.yaml
```

Проверка CronJob:

```bash
kubectl get cronjob -n state-as64-220050-v37
```

---

## Контрольный список (checklist)

- [✅] Namespace с метаданными студента
- [✅] Secret для хранения паролей
- [✅] Headless Service (clusterIP: None)
- [✅] StatefulSet с volumeClaimTemplates
- [✅] PVC 3Gi, storageClass: standard
- [✅] CronJob для backup по расписанию
- [✅] Метаданные и labels в манифестах
- [✅] README с описанием

---

## Вывод

В ходе работы было выполнено развёртывание stateful-приложения PostgreSQL в Kubernetes с использованием StatefulSet и постоянного хранилища (PVC/PV). Создан Headless Service для стабильных DNS-имён подов. Настроено автоматическое резервное копирование через CronJob с использованием pg_dump. Проверена сохранность данных после перезапуска подов. Освоены основные концепции работы с состоянием в Kubernetes и управление stateful-приложениями.
