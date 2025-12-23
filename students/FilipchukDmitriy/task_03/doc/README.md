# Лабораторная работа №03

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №03</strong></p>
<p align="center"><strong>По дисциплине:</strong> “Распределенные системы и облачные технологии”</p>
<p align="center"><strong>Тема:</strong> Kubernetes: состояние и хранение</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Филипчук Д. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться работать со StatefulSet для управления stateful-приложениями (Redis), настроить постоянное хранилище через PVC/PV и StorageClass, создать Headless Service для прямого доступа к подам через DNS, реализовать механизм резервного копирования и восстановления данных.

---

### Вариант №22

## Метаданные студента

- **ФИО:** Филипчук Дмитрий Васильевич
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220027
- **Email (учебный):** <as006327@g.bstu.by>
- **GitHub username:** kuddel11
- **Вариант №:** 22
- **ОС и версия:** Windows 11 24H2, Docker Desktop v4.53.0

---

## Окружение и инструменты

- Kubernetes (локальный single-node), kubectl >= 1.29
- Docker Desktop + встроенный Kubernetes
- Redis 7.2 container image
- Манифесты YAML

## Структура репозитория c описанием содержимого

```
src/                       # все артефакты
  Dockerfile               # образ с метаданными
  docker-compose.yml       # локальный стенд для проверки Redis
  k8s/                     # манифесты
    namespace.yaml         # namespace state-as63-220027-v22
    storageclass.yaml      # StorageClass fast (hostPath)
    persistentvolume.yaml  # статический PV 3Gi
    pvc-backup.yaml        # PVC для резервных копий
    secret.yaml            # пароль Redis
    service-headless.yaml  # headless Service для StatefulSet
    statefulset-redis.yaml # Redis с одной репликой
    cronjob-backup.yaml    # CronJob для периодического backup
    job-restore.yaml       # Job для восстановления данных

doc/README.md              # данный файл
```

## Подробное описание выполнения

1. Создан namespace и Secret с паролем Redis для безопасного хранения учетных данных.
2. Настроен StorageClass (fast) с no-provisioner и статический PersistentVolume на hostPath объемом 3Gi.
3. StatefulSet с одной репликой Redis, подключена headless Service для стабильных DNS-имён и volumeClaimTemplates для динамического создания PVC. При старте выводятся переменные среды STU_ID, STU_GROUP и STU_VARIANT.
4. Развертывание: `kubectl apply -f src/k8s -n state-as63-220027-v22` создает namespace, Secret, Service, StatefulSet, PVC. Данные сохраняются на хост-системе через hostPath.
5. CronJob выполняется по расписанию `40 */5 * * *` и вызывает `redis-cli SAVE` для создания снимка состояния базы данных с записью отметки времени.
6. Job для восстановления копирует файл dump.rdb из PVC резервной копии в PVC рабочего пода для восстановления данных.
7. Dockerfile содержит необходимые LABEL с метаданными студента; docker-compose.yml предоставляет локальный стенд для тестирования Redis.

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [✅] Kubernetes манифесты для StatefulSet/Service/Secret/PVC/PV
- [✅] StorageClass и хранилище
- [✅] Проверка сохранности данных после перезапуска
- [✅] CronJob для backup
- [✅] Job для restore

---

## Ссылкы(если требует задание)

Нет внешних ссылок.

## Вывод

Подготовлен рабочий стенд Redis в Kubernetes с постоянным хранилищем (PVC/PV), настроена периодическая архивация данных через CronJob и реализована процедура восстановления через Job. Все компоненты (StatefulSet, Headless Service, Secret, StorageClass) развернуты и готовы к использованию.
