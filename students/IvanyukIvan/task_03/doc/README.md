# Лабораторная работа 03 — Kubernetes: состояние и хранение

## Цели лабораторной работы

Цель — освоить управление stateful-приложениями в Kubernetes с использованием StatefulSet, Headless Service, PersistentVolumeClaim (PVC) и PersistentVolume (PV), StorageClass. В варианте 32 развернём Redis как stateful-сервис с объёмом хранилища 1Gi на StorageClass "standard". Настроим резервное копирование (backup) и восстановление (restore) данных с помощью CronJob по расписанию - каждые 40 минут. Проверим сохранность данных при перезапуске подов и продемонстрируем backup/restore.

## Метаданные студента

* **ФИО:** Иванюк Иван Александрович
* **Группа:** АС-64
* **№ студенческого (StudentID):** 220041
* **Email (учебный):** [AS006412@g.bstu.by](AS006412@g.bstu.by)
* **GitHub username:** JonF1re
* **Вариант №:** 32
* **Дата выполнения:** 22.12.2025
* **ОС (версия):** Windows 11 Home 24H2
* **Версия Docker Desktop:** 4.49.0
* **Версия kubectl:** 1.35.0
* **Версия Minikube:** 1.37.0

## Архитектура хранения

**StatefulSet:** Управляет подами Redis с упорядоченной идентичностью (имена вроде redis-0). Обеспечивает последовательный rollout и scaling.
**Headless Service:** Предоставляет стабильные DNS-имена подам (без балансировки нагрузки), чтобы поды могли обнаруживать друг друга (если replicas >1, но в базовом случае replicas=1).
**PVC/PV:** Абстракция для persistent storage. PVC запрашивает 1Gi на StorageClass "standard" (динамический provisioning, например, в minikube через CSI hostpath). Монтируется в /data для Redis (где хранится dump.rdb или AOF).
**Backup/Restore:** CronJob запускает под с контейнером, который копирует snapshot данных Redis (dump.rdb) в отдельный PVC для бэкапов. Restore — ручное копирование бэкапа обратно в volume данных с использованием Job.

## Структура файлов

Все манифесты хранятся в директории src/k8s. Структура:

* cronjob-backup.yaml: Манифест CronJob для бэкапа.
* namespace.yaml: Создание namespace state01.
* redis-backup-pvc.yaml: PVC для хранения бэкапов.
* secret.yaml: Секрет с паролем для Redis.
* service-headless.yaml: Headless Service.
* statefulset.yaml: StatefulSet для Redis.
* storageclass-standard.yaml: StorageClass "standard" (если не существует).
* temp-redis-restore.yaml: Временный Job для restore.

## Необходимая подготовка

* Kubernetes-кластер с динамическим provisioning (minikube с аддонами volumesnapshots и csi-hostpath-driver, или managed-кластер вроде GKE/EKS).
* Установленный kubectl.
* В minikube: minikube start --addons=volumesnapshots,csi-hostpath-driver.
* Проверьте StorageClass: kubectl get sc — должен быть "standard" (или аналогичный; если нет, примените storageclass-standard.yaml).

## Шаги запуска

1. Подготовка кластера

    * Запустите minikube (если используете):
    minikube start --addons=volumesnapshots,csi-hostpath-driver

    * Проверьте StorageClass:
    kubectl get sc

    * Если "standard" отсутствует, примените:
    kubectl apply -f src/k8s/storageclass-standard.yaml

2. Создание namespace и применение манифестов

    * Создайте namespace (если не существует):
    kubectl apply -f src/k8s/namespace.yaml

    * Примените базовые манифесты:
    kubectl apply -f src/k8s/secret.yaml
    kubectl apply -f src/k8s/service.yaml
    kubectl apply -f src/k8s/statefulset.yaml
    kubectl apply -f src/k8s/redis-backup-pvc.yaml
    kubectl apply -f src/k8s/backup-cronjob.yaml

    * Дождитесь готовности пода Redis:
    kubectl get pods -n state01 -w

    Ожидаемый вывод: redis-0 в статусе Running.
    ![Вывод kubectl get pods -n state01](/doc/img/1.jpg)

3. Проверка сохранности данных

    * Подключитесь к Redis:
    kubectl exec -it redis-0 -n state01 -- redis-cli -a examplepass

    * В CLI Redis выполните:
    SET mykey "Hello, persistent world!"

    * Проверьте:
    GET mykey
    (Должно вернуть "Hello, persistent world!").

    * Перезапустите под:
    kubectl delete pod redis-0 -n state01

    * Дождитесь восстановления:
    kubectl get pods -n state01 -w

    * Подключитесь снова и проверьте:
    GET mykey

    * Данные должны сохраниться благодаря PVC.
    Логи/скриншоты:
    ![Вывод Redis CLI до и после рестарта](/doc/img/2.jpg)

4. Настройка и проверка Backup

    * CronJob настроен на расписание. Проверьте CronJob:
    kubectl get cronjobs -n state01

    * Для ручного теста создайте Job из CronJob:
    kubectl create job --from=cronjob/redis-backup manual-backup -n state01

    * Дождитесь завершения:
    kubectl get jobs -n state01

    * Проверьте логи Job:
    kubectl logs "job-pod-name" -n state01

    * Проверьте файлы в backup PVC (создайте инспектор-под):
    kubectl run inspector -n state01 --image=busybox --rm -it -- sh

    Логи/скриншоты:
    ![Вывод kubectl get cronjobs: (скриншот).](/doc/img/3.jpg)

5. Восстановление (Restore)

    * Остановите StatefulSet:
    kubectl scale sts/redis --replicas=0 -n state01

    * Примените restore Job:
    kubectl apply -f src/k8s/temp-redis-restore.yaml

    * Дождитесь завершения:
    kubectl get jobs -n state01
    kubectl logs redis-restore-"pod" -n state01

    * Масштабируйте обратно:
    kubectl scale sts/redis --replicas=1 -n state01

    * Проверьте данные в Redis (как в шаге 3).
    ![Вывод](/doc/img/4.jpg)

## Отладка и типичные ошибки

* PVC в Pending: kubectl describe pvc -n state01 — проверьте StorageClass и CSI-драйвер.
* Данные не сохраняются: Убедитесь в правильном mountPath (/data) и volumeClaimTemplates (не emptyDir!).
* CronJob не запускается: kubectl describe cronjob redis-backup -n state01 — проверьте schedule, права на volumes.
* Redis не стартует: kubectl logs redis-0 -n state01 — проверьте пароль или config.
* Ошибки в Job: Убедитесь, что volumes правильно смонтированы и команды в command корректны.
