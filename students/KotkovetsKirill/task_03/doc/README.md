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
<p align="right">Группы АС-64</p>
<p align="right">Котковец К. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться работать со StatefulSet для управления stateful-приложениями, настроить постоянное хранилище через PVC/PV и StorageClass, создать Headless Service для прямого доступа к подам через DNS, реализовать механизм резервного копирования данных.

---

### Вариант №35

## Метаданные студента

- **ФИО:** Котковец Кирилл Викторович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220044
- **Email (учебный):** <as006412@g.bstu.by>
- **GitHub username:** Kirill-Kotkovets
- **Вариант №:** 35
- **ОС и версия:** Windows 11 21H3, Docker Desktop v4.53.0

---

## Окружение и инструменты

Согласно варианту 35:

- **База данных:** PostgreSQL
- **PVC размер:** 1Gi
- **StorageClass:** premium
- **Расписание backup:** "40 1 ** *" (ежедневно в 01:40)

Используемые инструменты:

- Kubernetes (Minikube/Kind)
- kubectl
- PostgreSQL 14
- Docker Desktop v4.53.0

---

## Структура репозитория c описанием содержимого

```
task_03/
├── src/
│   └── k8s/
│       ├── namespace.yaml        # Namespace для изоляции ресурсов
│       ├── secret.yaml           # Secret с данными подключения к БД
│       ├── storageclass.yaml     # StorageClass для хранилища
│       ├── pv.yaml               # PersistentVolume
│       ├── service.yaml          # Headless Service
│       ├── statefulset.yaml      # StatefulSet для PostgreSQL
│       └── cronjob.yaml          # CronJob для резервного копирования
└── doc/
    └── README.md                 # Документация проекта
```

---

## Подробное описание выполнения

### 1. Создание namespace

Создан namespace `state-as64-220044-v35` для изоляции ресурсов проекта.

```bash
kubectl apply -f src/k8s/namespace.yaml
```

### 2. Создание Secret

Secret содержит учетные данные для PostgreSQL (пользователь и пароль).

```bash
kubectl apply -f src/k8s/secret.yaml
```

### 3. Настройка StorageClass и PersistentVolume

Создан StorageClass `storage-as64-220044-v35` и PersistentVolume с размером 1Gi.

```bash
kubectl apply -f src/k8s/storageclass.yaml
kubectl apply -f src/k8s/pv.yaml
```

### 4. Развертывание Headless Service

Создан Headless Service для прямого доступа к подам PostgreSQL через DNS.

```bash
kubectl apply -f src/k8s/service.yaml
```

### 5. Развертывание StatefulSet

StatefulSet запускает PostgreSQL с постоянным хранением данных.

```bash
kubectl apply -f src/k8s/statefulset.yaml
```

Проверка статуса:

```bash
kubectl get pods -n state-as64-220044-v35
kubectl get statefulset -n state-as64-220044-v35
```

### 6. Настройка резервного копирования

Создан CronJob для автоматического резервного копирования БД по расписанию "40 1 ** *".

```bash
kubectl apply -f src/k8s/cronjob.yaml
```

Проверка:

```bash
kubectl get cronjob -n state-as64-220044-v35
```

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Kubernetes Namespace с метаданными
- [✅] Secret для хранения паролей
- [✅] StorageClass для хранилища
- [✅] PersistentVolume (1Gi)
- [✅] Headless Service (clusterIP: None)
- [✅] StatefulSet для PostgreSQL
- [✅] CronJob для резервного копирования
- [❌] Job для восстановления данных
- [❌] Тестирование сохранности данных
- [❌] Демонстрация восстановления из backup

---

## Вывод

В ходе выполнения лабораторной работы были созданы базовые манифесты для развертывания stateful-приложения PostgreSQL в Kubernetes. Реализован Headless Service, настроен StorageClass и PersistentVolume, создан CronJob для автоматического резервного копирования по расписанию. Освоены базовые навыки работы с StatefulSet и управления хранением данных в Kubernetes.
