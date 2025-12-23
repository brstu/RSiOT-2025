# Лабораторная работа 02: Kubernetes базовый деплой

## Метаданные студента

- **ФИО:** Хомич Виталий Геннадьевич
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220054
- **GitHub username:** VitalyaNB
- **Вариант №:** 42
- **ОС (версия):** Windows 10 Pro 22H2
- **Версия Docker Desktop:** 28.3.3
- **Версия kubectl:** 1.28.0
- **Версия Minikube:** 1.31.2

## Описание

Эта лабораторная работа реализует деплой HTTP-сервиса (из ЛР01) в Kubernetes с использованием Minikube. Включает Deployment, Service, Ingress, probes, ресурсы, rolling update, ConfigMap/Secret и PVC для данных.

## Шаги сборки и запуска образа (из ЛР01)

1. Соберите образ: `docker build -t myapp:-v42 .`
2. Push в реестр: `docker push myapp:-v42`

## Шаги деплоя и проверки в Kubernetes (Minikube)

1. Запустите Minikube
2. Включите Ingress
3. Примените манифесты
4. Проверьте статус
5. Добавьте в /etc/hosts
6. Smoke-test
7. Тест graceful shutdown
8. Rolling update
9. Очистка