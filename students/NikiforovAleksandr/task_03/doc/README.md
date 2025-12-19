# Лабораторная работа №03. Kubernetes: состояние и хранение  

**Вариант 16** – db=redis, pvc=3Gi, storageClass=fast, schedule=*/12

## Студент  

- ФИО: Nikiforov-Alexandr  
- Группа: AS-63  
- StudentID: 220020  
- Email: <woqhy@mail.ru>  
- GitHub: woqhy  
- Дата выполнения: 19.12.2025  

## Цель работы

Развёртывание stateful-приложения Redis в Kubernetes с использованием StatefulSet, постоянного хранения данных через PVC/PV и резервного копирования.

## Деплой приложения

Создать namespace:

```bash
kubectl apply -f namespace.yaml
````

Создать Secret для Redis пароля:

```bash
kubectl apply -f redis-secret.yaml
```

Создать StorageClass:

```bash
kubectl apply -f storageclass-fast.yaml
```

Создать PVC для backup:

```bash
kubectl apply -f redis-backup-pvc.yaml
```

Создать ConfigMap с конфигурацией Redis:

```bash
kubectl apply -f redis-config.yaml
```

Создать Headless Service и Service:

```bash
kubectl apply -f redis-headless.yaml
kubectl apply -f redis-service.yaml
```

Создать StatefulSet:

```bash
kubectl apply -f redis-stateful.yaml
```

Проверить состояние:

```bash
kubectl get pods -n state01
kubectl get pvc -n state01
```

## Создание тестовых данных

```bash
kubectl exec -n state01 redis-stateful-0 -- redis-cli -a "redis-password-2025" SET test-key "value"
kubectl exec -n state01 redis-stateful-0 -- redis-cli -a "redis-password-2025" GET test-key
```

## Резервное копирование

### Через CronJob

```bash
kubectl apply -f redis-backup-cron.yaml
```

### Ручное

```bash
./backup-redis.sh
```

## Восстановление данных

### Через Job

```bash
kubectl apply -f redis-restore-job.yaml
```

### Ввод вручную

```bash
./restore-redis.sh <backup-file.rdb.gz>
```

## Проверка сохранности данных

- После перезапуска пода данные сохраняются благодаря volumeClaimTemplates.
- После восстановления из backup создаётся тестовый ключ `restore-test-<timestamp>`.

## Kubernetes версии и окружение

- ОС: <твоя ОС и версия>
- Docker: <версия>
- kubectl: <версия>
- Minikube/Kind: <версия>

## Метаданные

- Namespace: state01
- Лейблы в манифестах включают org.bstu.student.fullname, id, group, variant, course
