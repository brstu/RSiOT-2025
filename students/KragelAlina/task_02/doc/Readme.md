# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №2</strong></p>
<p align="center"><strong>По дисциплине:</strong> “Распределенные системы и облачные технологии”</p>
<p align="center"><strong>Тема:</strong>Kubernetes: базовый деплой</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы AC-63</p>
<p align="right">Крагель АЛина Максимовна</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

## «Метаданные студента»

- ФИО - Крагель Алина Максимовна
- Группа - АС-63
- № студенческого/зачетной книжки (StudentID) - 220046
- Email (учебный) -Я_не_помню@gmail.com
- GitHub username - Alina529
- Вариант № - 10
- Дата выполнения - 04.12.2025
- ОС (версия), версия Docker Desktop/Engine - Windows 10, Docker version 28.4.0, kubectl 1.30.5

## RSOT Проект

Это пример минимального HTTP-сервиса и набор Kubernetes-манифестов для лабораторной работы. Включает:

* Dockerfile (multi-stage build, финальный образ на базе node:20-slim, с healthcheck, размер ≤150 MB, не root)
* Приложение: HTTP-сервер с эндпоинтами /ping (health), /ready (readiness), /calc (для арифметических операций с сохранением в БД), /history (история операций).
* Логи запуска, остановки и graceful shutdown (SIGTERM/SIGINT).
* Манифесты Kubernetes: Namespace, Deployment (RollingUpdate + ресурсы для web и postgres), Service (NodePort для web, ClusterIP для postgres), ConfigMap, Secret, PVC (для postgres data).
* Настройки liveness/readiness probes (HTTP для web, с initialDelay и period).
* Инструкции локального тестирования (kubectl, Minikube или аналогичный кластер).

### 1. Запуск образа

```bash
docker build -t web10-lab02:local .
docker run -d -p 8072:8072 --name web10 -e PG_HOST=host.docker.internal -e PG_USER=postgres -e PG_PASSWORD=secret -e PG_DB=calc_history web10-lab02:local
```

### 2. Развертывание HTTP-сервиса в Kubernetes

#### 2.1 Проверка текущего контекста Kubernetes

```bash
- kubectl config current-context
- kubectl get nodes
```

Смотрим с каким класстером мы работаем и доступны ли ноды.

#### 2.2 Сборка Docker-образа

```bash
docker build -t alina272/lab02-web10:local .
```

Создаём локальный образ сервиса.

#### 2.3 Создание Namespace

```bash
kubectl apply -f k8s/namespace.yaml
```

Создание отдельного пространства имён.

#### 2.4 Применение манифестов приложения

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Создайте все необходимые ресурсы Kubernetes в нашем namespace.

#### 2.7 Просмотр работоспособности подов

```bash
kubectl get pods -n app10
```

### 3. Подтвердить приложение

#### 3.1 Liveness

```bash
curl http://web10.local/ping
```

Content           : OK

#### 3.2 Readiness

```bash
curl http://web10.local/ready
```

Content           : READY

#### 3.3 Posgres

```bash
http://web10.local/visit
```

Студент: 10, Группа: АС, Вариант: v10

### 4. Просмотр логов

#### 4.1 Просмотр логов бд

```bash
kubectl logs <postgres-pod-name> -n app10
```

#### 4.2 Просмотр логов аpp

```bash
kubectl logs <web10-pod-name> -n app10
```

### 5. Очистка ресурсов

```bash
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/postgres-service.yaml
kubectl delete -f k8s/postgres-deployment.yaml
kubectl delete -f k8s/pvc.yaml
kubectl delete -f k8s/secret.yaml
kubectl delete -f k8s/configmap.yaml
kubectl delete -f k8s/namespace.yaml
```

### 6. Краткое описание проделанных действий

* Deployment — создан для web10 (replicas:3, RollingUpdate с maxSurge:1/maxUnavailable:0, ресурсы requests/limits) и для postgres (replicas:1). Добавлены env из ConfigMap/Secret, volume из PVC для postgres.
* Service — NodePort (port 30010) для web10, ClusterIP для postgres.
* ConfigMap и Secret — используются для PG_DB, PG_HOST, PG_USER, PG_PASSWORD.
* Добавлен PersistentVolumeClaim (1Gi, ReadWriteOnce) и подключён volume для /var/lib/postgresql/data.
* Настроены livenessProbe (/ping) и readinessProbe (/ready) для web10 (HTTP, с initialDelaySeconds и periodSeconds), проверена их корректная работа (pod restarts при failure).
* Подготовлены инструкции для локального тестирования:
1. Создание локального кластера (Minikube);
2. Применение всех манифестов;
3. Проверка статуса Pod;
4. Выполнение smoke-теста через HTTP-запросы к эндпоинтам (/ping, /ready, /calc, /history).
