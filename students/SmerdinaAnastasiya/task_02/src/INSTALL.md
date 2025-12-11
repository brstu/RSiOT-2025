\# Краткая инструкция по развертыванию



\## Требования



\- Docker Desktop / Docker Engine

\- kubectl

\- Kind или Minikube

\- Helm 3 (опционально)



\## Быстрый старт



\### Windows (PowerShell)



```powershell

\\# 1. Перейти в каталог

cd task\\\_02\\\\src



\\# 2. Запустить автоматическую установку

.\\\\deploy.ps1 -Action setup



\\# 3. Дождаться завершения установки



\\# 4. Пробросить порт для доступа

kubectl port-forward -n app41 svc/net-as64-220053-v41 7991:7991



\\# 5. Открыть в браузере

\\# http://localhost:7991

```



\### Linux/Mac (Bash + Make)



```bash

\\# 1. Перейти в каталог

cd task\\\_02/src



\\# 2. Запустить автоматическую установку

make setup-kind



\\# 3. Дождаться завершения установки



\\# 4. Пробросить порт для доступа

kubectl port-forward -n app41 svc/net-as64-220053-v41 7991:7991



\\# 5. Открыть в браузере

\\# http://localhost:7991

```



\## Пошаговая установка



\### 1. Сборка образа



```bash

docker build -t annkrq/web41:latest ./src

```



\### 2. Создание Kind кластера



```bash

kind create cluster --name lab02-cluster --config=./src/kind-config.yaml

```



\### 3. Загрузка образа в Kind



```bash

kind load docker-image annkrq/web08:latest --name lab02-cluster

```



\### 4. Установка через Helm



```bash

helm upgrade --install web41 ./src/helm/web41 --create-namespace

```



\### 5. Проверка статуса



```bash

kubectl get all -n app41

```



\## Проверка работы



\### Health check



```bash

kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n app41 \\\\

\&nbsp; -- curl -s http://net-as64-220053-v41:7991/health

```



\### Ready check



```bash

kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n app41 \\\\

\&nbsp; -- curl -s http://net-as64-220053-v41:7991/ready

```



\### Info endpoint



```bash

kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n app41 \\\\

\&nbsp; -- curl -s http://net-as64-220053-v41:7991/info

```



\## Удаление



\### Удалить приложение



```bash

helm uninstall web41 -n app41

kubectl delete namespace app41

```



\### Удалить Kind кластер



```bash

kind delete cluster --name lab02-cluster

```



\## Полезные команды



```bash

\\# Просмотр логов

kubectl logs -n app08 -l app.kubernetes.io/name=web08 --tail=50 --follow



\\# Статус подов

kubectl get pods -n app41 -o wide



\\# Описание Deployment

kubectl describe deployment app-as64-220053-v41 -n app41



\\# Проверка events

kubectl get events -n app41 --sort-by='.lastTimestamp'



\\# Проверка resource usage

kubectl top pods -n app41

```



\## Makefile команды



```bash

make help           # Показать все доступные команды

make build          # Собрать Docker образ

make deploy         # Развернуть приложение

make status         # Показать статус ресурсов

make test           # Запустить smoke-тесты

make logs           # Показать логи

make clean          # Удалить все ресурсы

```



\## Решение проблем



\### Образ не найден



```bash

kind load docker-image annkrq/web41:latest --name lab02-cluster

```



\### Поды не запускаются



```bash

kubectl describe pod -n app41 -l app.kubernetes.io/name=web41

kubectl logs -n app41 -l app.kubernetes.io/name=web41

```



\### Service недоступен



```bash

kubectl get svc -n app41

kubectl describe svc net-as64-220053-v41 -n app41

```



\## Контакты



\- Студент: Смердина Анастасия Валентиновна

\- Email: [AS006424@g.bstu.by](mailto:AS006424@g.bstu.by)

\- GitHub: KotyaLapka

