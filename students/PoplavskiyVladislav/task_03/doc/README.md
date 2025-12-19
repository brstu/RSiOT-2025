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

Научиться работать со StatefulSet для управления stateful-приложениями (Postgres/Redis/MinIO). Настроить постоянное хранилище через PVC/PV и StorageClass с динамическим провижинингом. Создать Headless Service для прямого доступа к подам через DNS. Реализовать механизм резервного копирования (backup) и восстановления (restore) данных. Проверить сохранность данных после перезапуска подов.

---

### Вариант №18

**db=postgres, pvc=1Gi, storageClass=premium, schedule="0 12 * * "*

---

## Ход выполнения работы

### 1. Архитектура проекта

- **Stateful-сервис:** PostgreSQL 15
- **PersistentVolumeClaim:** 1Gi
- **StorageClass:** premium (с параметрами для SSD-дисков)
- **Headless Service:** postgres-headless для стабильных DNS-имен подов (формат: pod-name.service-name.namespace.svc.cluster.local)
- **Backup:** CronJob с расписанием
- **Restore:** state-lab03 для изоляции ресурсов

---

### 2. Деплой и проверка

#### Подготовка окружения

```bash

minikube start
kubectl cluster-info
kubectl apply -f src/manifests/

```

#### Проверка созданных ресурсов

```bash

kubectl get namespace state-lab03
kubectl get statefulset -n state-lab03
kubectl get pods -n state-lab03 -o wide
kubectl get pvc -n state-lab03
kubectl get svc -n state-lab03

```

---

#### Лейблы и аннотации

```yml

org.bstu.student.fullname: Poplavsky Vladislav Vladmirovich
org.bstu.student.id: as006321
org.bstu.group: AS-63
org.bstu.variant: 17
org.bstu.course: RSIOT
org.bstu.owner: Poplavsky Vladislav Vladmirovich

```
