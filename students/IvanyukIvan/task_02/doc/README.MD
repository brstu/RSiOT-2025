# Лабораторная работа 02: Kubernetes базовый деплой

## Метаданные студента

- **ФИО:** Иванюк Иван Александрович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220041
- **Email (учебный):** [AS006412@g.bstu.by](AS006412@g.bstu.by)
- **GitHub username:** JonF1re
- **Вариант №:** 8
- **Дата выполнения:** 21.12.2025
- **ОС (версия):** Windows 11 Home 24H2
- **Версия Docker Desktop:** 4.49.0
- **Версия kubectl:** 1.35.0
- **Версия Minikube:** 1.37.0

## Описание

Эта лабораторная работа реализует деплой HTTP-сервиса (Flask app из ЛР01) в Kubernetes с использованием Minikube. Включает Deployment, Service, Ingress, probes, ресурсы, rolling update, ConfigMap/Secret и PVC для данных. Также развернута зависимость Postgres как StatefulSet.

## Шаги сборки и запуска образа (из ЛР01)

1. Соберите образ: `docker build -t JonF1re/myapp:stu-220041-v08 .`
2. Push в реестр: `docker push JonF1re/myapp:stu-220041-v08`
3. Тестируйте локально: `docker run -p 8094:8094 -e DB_HOST=localhost JonF1re/myapp:stu-220041-v08`

## Шаги деплоя и проверки в Kubernetes (Minikube)

1. Запустите Minikube: `minikube start`
2. Включите Ingress: `minikube addons enable ingress`
3. Примените манифесты: `kubectl apply -f k8s/`
4. Проверьте статус: `kubectl get all -n app08`
5. Добавьте в /etc/hosts: `127.0.0.1 web08.local`
6. Smoke-test: `curl http://web08.local/ping` (должен вернуть {"status": "healthy", ...})
7. Проверьте логи: `kubectl logs -f deployment/web08 -n app08` (ищите STU_* ENV и startup)
8. Тест graceful shutdown: `kubectl delete pod <pod-name> -n app08` (проверьте логи на shutdown)
9. Rolling update: Измените tag образа в deployment-app.yaml на новый (соберите/push новую версию), `kubectl apply -f k8s/deployment-app.yaml`. Наблюдайте: `kubectl get pods -n app08 -w` (замена без простоя).
10. Очистка: `kubectl delete -f k8s/`
