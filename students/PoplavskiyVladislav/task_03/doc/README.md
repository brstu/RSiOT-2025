# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>

<p align="center"><strong>Лабораторная работа №3</strong></p>
<p align="center"><strong>По дисциплине:</strong> “РСиОТ”</p>
<p align="center"><strong>Тема:</strong> “Kubernetes: состояние и хранение”</p>

<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Поплавский В.В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться работать со StatefulSet для управления stateful-приложениями (Postgres). Настроить постоянное хранилище через PVC/PV и StorageClass с динамическим провижинингом. Создать Headless Service для прямого доступа к подам через DNS. Реализовать механизм резервного копирования (backup) и восстановления (restore) данных. Проверить сохранность данных после перезапуска подов.

---

### Вариант №18

**db=postgres, pvc=1Gi, storageClass=premium, schedule="0 12 * * "*

---

## Ход выполнения работы

### 1. Архитектура проекта

- **Stateful-сервис:** PostgreSQL 15
- **PersistentVolumeClaim:** 1Gi
- **StorageClass:** premium с параметрами для SSD-дисков, provisioner: k8s.io/minikube-hostpath
- **Headless Service:** postgres-headless для стабильных DNS-имен подов
- **Резервное копирование:** CronJob с расписанием "0 12" (ежедневно в 12:00)
- **Восстановление:** Job для демонстрации восстановления из backup
- **Namespace:** state-lab03 для изоляции ресурсов

---

### 2. Стркутура проекта

lab03-kubernetes-stateful/
├── k8s/
│   ├── 00-namespace.yaml
│   ├── 01-secret.yaml
│   ├── 02-storageclass.yaml
│   ├── 03-statefulset.yaml
│   ├── 04-headless-service.yaml
│   ├── 05-backup-pvc.yaml
│   ├── 06-scripts-configmap.yaml
│   ├── 07-backup-cronjob.yaml
│   ├── 08-restore-job.yaml
│   └── 09-test-pod.yaml
├── scripts/
│   ├── backup.sh
│   └── restore.sh

### 3. Лейблы и аннотации

```yml

org.bstu.student.fullname: Poplavsky Vladislav Vladmirovich
org.bstu.student.id: as006321
org.bstu.group: AS-63
org.bstu.variant: 17
org.bstu.course: RSIOT
org.bstu.owner: Poplavsky Vladislav Vladmirovich
slug: ac-63--v17

```

### 4. Выполнение

#### 1. Развертывание

```bash

minikube start
kubectl apply -f k8s/

```

#### 2. Тестовые данные

```bash

CREATE TABLE lab_test (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(20),
    test_data TEXT
);
INSERT INTO lab_test VALUES (1, 'as006321', 'Данные до перезапуска');

```

#### 3. Тестовые данные

```bash

kubectl delete pod db-postgres-0 -n state-lab03
kubectl exec db-postgres-0 -n state-lab03 -- psql -U postgres -d testdb \
  -c "SELECT * FROM lab_test;"

```

#### 4. Резервное копирование

```bash

kubectl create job --from=cronjob/backup-postgres manual-backup -n state-lab03
kubectl logs job/manual-backup -n state-lab03 | tail -5

```

#### 5. Восстановление данных

```bash

kubectl exec db-postgres-0 -n state-lab03 -- psql -U postgres -d testdb \
  -c "DROP TABLE lab_test;"
kubectl apply -f k8s/08-restore-job.yaml
kubectl logs job/restore-postgres-demo -n state-lab03 | grep -A5 "Данные в таблице"

```
