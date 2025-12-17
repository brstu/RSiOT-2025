# Лабораторная работа №3

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №3</strong></p>
<p align="center"><strong>По дисциплине:</strong> “Распределенные системы и облачные технологии”</p>
<p align="center"><strong>Тема:</strong> Kubernetes: состояние и хранение (StatefulSet, PVC/PV, Backup/Restore)</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнила:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группа АС-63</p>
<p align="right">Козловская Анна Геннадьевна</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Освоить развертывание stateful-приложения в Kubernetes на примере Redis: StatefulSet с Headless Service, постоянное хранилище через PVC/PV и StorageClass, настройка резервного копирования по расписанию (CronJob) и восстановление из backup (Job), проверка сохранности данных после рестартов.

---

### Вариант №8

## Метаданные студента

- **ФИО:** Козловская Анна Геннадьевна
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220012
- **Email (учебный):** <AS006309@g.bstu.by>
- **GitHub username:** annkrq
- **Вариант №:** 8
- **ОС и версия:** Windows 11 Pro 23H2
- **Docker Desktop/Engine:** 26.1.x
- **kubectl:** 1.30.x
- **Kind/Minikube:** Minikube 1.33.x (или Kind 0.23.x — при необходимости)
- **Дата выполнения:** 17.12.2025

---

## Окружение и инструменты

- Kubernetes 1.29+ с включенным StorageClass `standard` (в манифестах — `storage-as63-220012-v8-standard` на базе hostpath для minikube; при другом кластере заменить на существующий `standard`).
- Образ Redis: `redis:7.2-alpine`.
- kubectl, kustomize (или `kubectl apply -k`).
- PVC объёмом 1Gi для данных и 1Gi для backup.
- CronJob с расписанием `*/5 * * * *` для регулярного backup.

---

## Структура репозитория

```
task_03/
├── doc/
│   ├── README.md                # текущий отчёт
│   └── screenshots/             # для скриншотов проверки
└── src/
    └── k8s/                     # Kubernetes-манифесты + kustomization
        ├── configmap-scripts.yaml
        ├── cronjob-backup.yaml
        ├── job-restore.yaml
        ├── kustomization.yaml
        ├── namespace.yaml
        ├── pvc-backup.yaml
        ├── secret.yaml
        ├── service-headless.yaml
        ├── statefulset.yaml
        └── storageclass.yaml
```

---

## Подробное описание выполнения

1. **Подготовка namespace и StorageClass.** Создан namespace `state-as63-220012-v8` с обязательными метаданными (ФИО, группа, вариант, slug). Добавлен StorageClass `storage-as63-220012-v8-standard` (hostpath для minikube); при ином CSI заменить `provisioner` на доступный `standard`.
2. **Секреты и скрипты.** Secret `db-as63-220012-v8-secret` хранит `REDIS_PASSWORD`. ConfigMap `db-as63-220012-v8-scripts` содержит `backup.sh` (redis RDB dump) и `restore.sh` (копирование последнего backup в `dump.rdb`).
3. **StatefulSet + Headless Service.**
   - StatefulSet `db-as63-220012-v8` (1 реплика) с `volumeClaimTemplates` на 1Gi (`storage-as63-220012-v8-standard`).
   - Headless Service `db-as63-220012-v8` (ClusterIP None) обеспечивает стабильный DNS `db-as63-220012-v8-0.db-as63-220012-v8...`.
   - Контейнер Redis запускается с паролем, включает AOF, выводит в лог `STU_ID`, `STU_GROUP`, `STU_VARIANT` при старте; добавлены liveness/readiness через `redis-cli PING`.
4. **Backup.** PVC `backup-as63-220012-v8-pvc` на 1Gi. CronJob `backup-as63-220012-v8` (расписание `*/5 * * * *`) вызывает `backup.sh`, выполняя `redis-cli --rdb /backup/redis-<timestamp>.rdb`, хранит резервные копии в отдельном PVC.
5. **Restore.** Job `restore-as63-220012-v8` монтирует backup PVC и PVC pod-а (`redis-data-db-as63-220012-v8-0`), копирует последний `redis-*.rdb` в `/data/dump.rdb`. Перед запуском restore требуется масштабировать StatefulSet в 0 (см. шаги ниже).
6. **Проверка сохранности данных.** Предусмотрена последовательность команд для создания тестовых ключей, рестарта pod-а и проверки их наличия после перезапуска и после восстановления из backup.

---

## Инструкции по деплою и проверке

Все команды выполняются из корня `task_03/`.

1. **Применить манифесты:**

   ```sh
   kubectl apply -k src/k8s
   ```

2. **Проверить ресурсы:**

   ```sh
   kubectl -n state-as63-220012-v8 get all,pvc,sc
   ```

3. **Создать тестовые данные в Redis:**

   ```sh
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- \
     sh -c 'redis-cli -a "$REDIS_PASSWORD" set lab03:key "persist-me"'
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- \
     sh -c 'redis-cli -a "$REDIS_PASSWORD" get lab03:key'
   ```

4. **Перезапуск pod-а и проверка сохранности:**

   ```sh
   kubectl -n state-as63-220012-v8 delete pod db-as63-220012-v8-0
   kubectl -n state-as63-220012-v8 wait --for=condition=ready pod/db-as63-220012-v8-0 --timeout=180s
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- \
     sh -c 'redis-cli -a "$REDIS_PASSWORD" get lab03:key'
   ```

5. **Проверка CronJob backup:** дождаться выполнения (или запустить разово):

   ```sh
   kubectl -n state-as63-220012-v8 create job --from=cronjob/backup-as63-220012-v8 manual-backup-$(date +%H%M%S)
   kubectl -n state-as63-220012-v8 logs job/manual-backup-<time>
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- ls -lh /backup || true
   ```

6. **Имитация потери данных:**

   ```sh
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- \
     sh -c 'redis-cli -a "$REDIS_PASSWORD" flushall'
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- \
     sh -c 'redis-cli -a "$REDIS_PASSWORD" get lab03:key'  # должно вернуть (nil)
   ```

7. **Restore из backup:**

   ```sh
   kubectl -n state-as63-220012-v8 scale sts db-as63-220012-v8 --replicas=0
   kubectl -n state-as63-220012-v8 wait --for=delete pod/db-as63-220012-v8-0 --timeout=180s
   kubectl -n state-as63-220012-v8 delete job restore-as63-220012-v8 --ignore-not-found
   kubectl -n state-as63-220012-v8 apply -f src/k8s/job-restore.yaml
   kubectl -n state-as63-220012-v8 logs job/restore-as63-220012-v8
   kubectl -n state-as63-220012-v8 scale sts db-as63-220012-v8 --replicas=1
   kubectl -n state-as63-220012-v8 wait --for=condition=ready pod/db-as63-220012-v8-0 --timeout=180s
   kubectl -n state-as63-220012-v8 exec sts/db-as63-220012-v8 -c redis -- \
     sh -c 'redis-cli -a "$REDIS_PASSWORD" get lab03:key'
   ```

8. **Очистка ресурсов:**

   ```sh
   kubectl delete namespace state-as63-220012-v8
   ```

---

## Контрольный список

- [✅] README с полными метаданными студента и инструкциями
- [✅] Namespace с метками, Secret с паролем Redis
- [✅] StorageClass `standard` (hostpath) + PVC/PV 1Gi для данных
- [✅] StatefulSet Redis с volumeClaimTemplates, Headless Service, probes
- [✅] PVC 1Gi для backup, CronJob `*/5 * * * *` для резервного копирования
- [✅] Job для восстановления из последнего backup
- [✅] Инструкции по проверке сохранности данных и восстановлению

---

## Ссылки

- Методические материалы: см. локальный каталог `tasks/task_03/`
- Варианты: `tasks/task_03/Варианты.md`

---

## Вывод

Развернуто stateful-приложение Redis с постоянным хранилищем (PVC/PV, StorageClass `standard`), Headless Service для стабильного DNS и паролем в Secret. Настроен CronJob для регулярного backup каждые 5 минут в отдельный PVC, подготовлен Job для восстановления из последнего резервного файла. Предложена последовательность проверки устойчивости данных при рестарте и после восстановления.

---

## Самопроверка строгим ревьюером

- **Требования к ресурсам:** имеются StatefulSet, volumeClaimTemplates (1Gi), Headless Service `clusterIP: None`, Secret с паролем, StorageClass `standard`-базовый, метки и slug присутствуют.
- **Хранение и устойчивость:** PVC подключён к Redis, инструкции по созданию/проверке данных после рестартов добавлены.
- **Backup/Restore:** CronJob `*/5 * * * *` с `redis-cli --rdb`, отдельный backup PVC; Job копирует последний backup в `dump.rdb` (с шагом масштабирования в 0 перед восстановлением).
- **Документация:** README включает метаданные, окружение, структуру, пошаговый деплой, контрольный список, вывод.
- **Дополнительно:** kustomization для упрощённого применения; лейблы/аннотации соответствуют заданию; старт контейнера логирует `STU_*`.

Недочёты, требующие внимательности при защите:

- В кластерах без `k8s.io/minikube-hostpath` нужно заменить `storage-as63-220012-v8-standard` на доступный StorageClass `standard` или скорректировать provisioner.
- Для restore имя PVC `redis-data-db-as63-220012-v8-0` зависит от ordinal; при масштабировании >1 восстановление выполнять для нужного pod-а или временно оставить 1 реплику.
