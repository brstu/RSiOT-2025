# Лабораторная работа 03 — Kubernetes: состояние и хранение

## Цели лабораторной работы

Цель — освоить управление stateful-приложениями в Kubernetes с использованием StatefulSet, Headless Service, PersistentVolumeClaim (PVC) и PersistentVolume (PV), StorageClass. В варианте 31 развернём Postgers как stateful-сервис с объёмом хранилища 1Gi на StorageClass "standard". Настроим резервное копирование (backup) и восстановление (restore) данных с помощью CronJob по расписанию. Проверим сохранность данных при перезапуске подов и продемонстрируем backup/restore.

## Метаданные студента

* **ФИО:** Хомич Виталий Геннадьевич
* **Группа:** АС-64
* **№ студенческого (StudentID):** 220039
* **GitHub username:** VitalyaNB
* **Вариант №:** 42
* **ОС (версия):** Windows 10 Pro 22H2
* **Версия Docker Desktop:** 28.3.3
* **Версия kubectl:** 1.28.0
* **Версия Minikube:** 1.31.2

## Архитектура хранения

**StatefulSet:** Управляет подами postgers с упорядоченной идентичностью. Обеспечивает последовательный rollout и scaling.
**Headless Service:** Предоставляет стабильные DNS-имена подам (без балансировки нагрузки), чтобы поды могли обнаруживать друг друга (если replicas >1, но в базовом случае replicas=1).
**PVC/PV:** Абстракция для persistent storage. PVC запрашивает 1Gi на StorageClass "standard" (динамический provisioning, например, в minikube через CSI hostpath). Монтируется в /data для postgers (где хранится dump.rdb или AOF).
**Backup/Restore:** CronJob запускает под с контейнером, который копирует snapshot данных postgers (dump.rdb) в отдельный PVC для бэкапов. Restore — ручное копирование бэкапа обратно в volume данных с использованием Job.

## Структура файлов

Все манифесты хранятся в директории src/k8s. Структура:

* cronjob-backup.yaml: Манифест CronJob для бэкапа.
* backup-pvc.yaml: PVC для хранения бэкапов.
* secret.yaml: Секрет с паролем для Postgres.
* headless-service.yaml: Headless Service.
* statefulset.yaml: StatefulSet.
* storageclass.yaml: StorageClass "standard" (если не существует).

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
    kubectl apply -f src/k8s/storageclass.yaml

2. Создание namespace и применение манифестов

    * Создайте namespace (если не существует):
    kubectl apply -f src/k8s/namespace.yaml

    * Примените базовые манифесты:
    kubectl apply -f src/k8s/secret.yaml
    kubectl apply -f src/k8s/service.yaml
    kubectl apply -f src/k8s/statefulset.yaml
    kubectl apply -f src/k8s/cronjob-backup.yaml
    kubectl apply -f src/k8s/handless-service.yaml

    * Дождитесь готовности пода Postgers:
    kubectl get pods -n state01 -w

3. Проверка сохранности данных

    * Подключитесь к Postgers:

    * В CLI Postgers выполните:
    SET mykey "Hello, persistent world!"

    * Проверьте:
    GET mykey
    (Должно вернуть "Hello, persistent world!").

    * Перезапустите под:

    * Дождитесь восстановления:
    kubectl get pods -n state01 -w

    * Подключитесь снова и проверьте:
    GET mykey

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

## Отладка и типичные ошибки

* PVC в Pending: kubectl describe pvc -n state01 — проверьте StorageClass и CSI-драйвер.
* Данные не сохраняются: Убедитесь в правильном mountPath (/data) и volumeClaimTemplates (не emptyDir!).
* CronJob не запускается: kubectl describe cronjob redis-backup -n state01 — проверьте schedule, права на volumes.
* Redis не стартует: kubectl logs redis-0 -n state01 — проверьте пароль или config.
* Ошибки в Job: Убедитесь, что volumes правильно смонтированы и команды в command корректны.