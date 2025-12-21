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
<p align="right">Попов А. С.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться работать со StatefulSet для управления stateful-приложениями (Redis), настроить постоянное хранилище через PVC/PV, создать Headless Service для прямого доступа к подам через DNS, реализовать механизм резервного копирования данных.

---

### Вариант №38

## Метаданные студента

- **ФИО:** Попов Алексей Сергеевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220051
- **Email (учебный):** <as006416@g.bstu.by>
- **GitHub username:** LexusxdsD
- **Вариант №:** 38
- **ОС и версия:** Windows 11 21H2, Docker Desktop v4.52.0

---

## Окружение и инструменты

- **База данных:** Redis 7 (Alpine)
- **PVC размер:** 1Gi
- **StorageClass:** standard (default)
- **Расписание backup:** `20 6 * * *` (ежедневно в 06:20)
- **Kubernetes:** kubectl, Kind/Minikube
- **Namespace:** state-as64-220051-v38

---

## Структура репозитория c описанием содержимого

```
task_03/
├── src/
│   ├── k8s/                         # Kubernetes манифесты
│   │   ├── namespace.yaml           # Namespace для изоляции ресурсов
│   │   ├── secret.yaml              # Secret для хранения пароля Redis
│   │   ├── pvc.yaml                 # PersistentVolumeClaim для хранения данных
│   │   ├── service.yaml             # Headless Service
│   │   ├── statefulset.yaml         # StatefulSet для Redis
│   │   └── cronjob-backup.yaml      # CronJob для резервного копирования
│   └── deploy.sh                    # Скрипт развертывания
└── doc/
    └── README.md                    # Документация
```

---

## Подробное описание выполнения

### 1. Подготовка манифестов

Созданы следующие манифесты:

- **namespace.yaml** - создание изолированного namespace `state-as64-220051-v38`
- **secret.yaml** - хранение пароля Redis в base64
- **pvc.yaml** - запрос на постоянное хранилище 1Gi
- **service.yaml** - Headless Service с `clusterIP: None` для стабильных DNS-имён
- **statefulset.yaml** - StatefulSet для Redis с 1 репликой
- **cronjob-backup.yaml** - автоматический backup по расписанию `20 6 * * *`

### 2. Развертывание приложения

Применение манифестов:

```bash
kubectl apply -f src/k8s/namespace.yaml
kubectl apply -f src/k8s/secret.yaml
kubectl apply -f src/k8s/pvc.yaml
kubectl apply -f src/k8s/service.yaml
kubectl apply -f src/k8s/statefulset.yaml
kubectl apply -f src/k8s/cronjob-backup.yaml
```

Проверка запуска подов:

```bash
kubectl get pods -n state-as64-220051-v38
kubectl get pvc -n state-as64-220051-v38
```

### 3. Создание тестовых данных

Подключение к Redis:

```bash
kubectl exec -it db-as64-220051-v38-0 -n state-as64-220051-v38 -- redis-cli
```

Создание тестовых ключей:

```
SET key1 "value1"
SET key2 "value2"
KEYS *
```

### 4. Проверка сохранности данных

Перезапуск пода:

```bash
kubectl delete pod db-as64-220051-v38-0 -n state-as64-220051-v38
```

После перезапуска проверка данных:

```bash
kubectl exec -it db-as64-220051-v38-0 -n state-as64-220051-v38 -- redis-cli KEYS '*'
```

### 5. Резервное копирование

CronJob настроен на выполнение команды `SAVE` в Redis по расписанию `20 6 * * *`.

Ручной запуск backup:

```bash
kubectl create job --from=cronjob/backup-as64-220051-v38 manual-backup -n state-as64-220051-v38
```

---

## Контрольный список (checklist)

- [✅] README с полными метаданными студента
- [✅] Namespace с метками студента
- [✅] StatefulSet для Redis
- [✅] Headless Service (clusterIP: None)
- [✅] Secret для пароля
- [✅] PVC для хранения данных (1Gi)
- [✅] CronJob для резервного копирования
- [❌] Job для восстановления данных
- [❌] Демонстрация восстановления с логами

---

## Вывод

В ходе лабораторной работы был развернут stateful-сервис Redis в Kubernetes с использованием StatefulSet. Настроено постоянное хранилище через PersistentVolumeClaim размером 1Gi. Создан Headless Service для стабильных DNS-имён подов. Реализован механизм автоматического резервного копирования через CronJob по расписанию `20 6 * * *`. Проверена базовая сохранность данных после перезапуска пода.

Освоены навыки работы с StatefulSet, PVC/PV, Secret и CronJob в Kubernetes для управления stateful-приложениями.
