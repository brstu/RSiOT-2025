# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>

<p align="center"><strong>Лабораторная работа №4</strong></p>
<p align="center"><strong>По дисциплине:</strong> “РСиОТ”</p>
<p align="center"><strong>Тема:</strong> “Наблюдаемость и метрики”</p>

<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Савко П.С.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться устанавливать и настраивать систему мониторинга (Prometheus + Grafana) в Kubernetes.

---

### Вариант №18

prefix=app18_, slo=99.9%, p95=250ms, alert="5xx>1.5% за 15м"

---

## Ход выполнения работы

### 1. Архитектура проекта

- **Stateful-сервис:** Redis
- **PersistentVolumeClaim:** 2Gi
- **StorageClass:** premium
- **Headless Service:** для стабильных DNS-имен подов
- **Backup:** CronJob с расписанием `*/25 * * * *`
- **Restore:** Job для восстановления из backup

---

### 2. Использованные ресурсы Kubernetes

- **Namespace:** state-as63
- **Secret:** redis-secret (пароль Redis)
- **StatefulSet:** redis-statefulset.yaml
- **Headless Service:** redis-service.yaml
- **StorageClass:** premium
- **CronJob:** backup-cronjob.yaml
- **Job:** restore-job.yaml

---

### 3. Деплой и проверка

1. Создан namespace: `kubectl apply -f src/manifests/namespace.yaml`
2. Создан StorageClass и PVC: `kubectl apply -f src/manifests/storageclass.yaml`
3. Создан Secret с паролем Redis: `kubectl apply -f src/manifests/redis-secret.yaml`
4. Развернут Headless Service и StatefulSet

   ```bash

   kubectl apply -f src/manifests/redis-service.yaml
   kubectl apply -f src/manifests/redis-statefulset.yaml

   ```

---

### 4. Проверка состояния

```bash

kubectl get pvc -n state-as63
kubectl get pods -n state-as63

```

---

#### Лейблы и аннотации

```yml

org.bstu.student.fullname: Savko Pavel Stanislavovich
org.bstu.student.id: as006322
org.bstu.group: AS-63
org.bstu.variant: 1
org.bstu.course: RSIOT
org.bstu.owner: Savko Pavel Stanislavovich
org.bstu.student.slug: 1nsirius
slug: as63--v1

```

#### Вывод

В ходе выполнения лабораторной работы был успешно развёрнут stateful-сервис Redis в Kubernetes с использованием StatefulSet и постоянного хранилища. Реализованы механизмы резервного копирования и восстановления данных, а также корректная организация сетевого взаимодействия с помощью Headless Service. Полученные навыки позволяют применять Kubernetes для эксплуатации stateful-приложений в реальных production-сценариях.
