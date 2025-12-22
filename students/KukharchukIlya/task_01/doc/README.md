# РСиОТ Лабораторная работа №1

## Описание

Это простой HTTP-сервис написанный на языке GoLang, с определенными endpoint-ами (/ready, /health) и поддержкой graceful shutdown. Данный проект был упакован в Docker-контейнер с использованием мельтиуровневого развёртывания для более удобного и работоспособного деплоя на другие устройства. Сервер имеет единственную зависимость - драйвера для работы с PostgreSQL.

## Структура проекта

src/ - Содержит исходный код сервера (server.go), а также зависимости.
Dockerfile - Мультуровневный Dockerfile для развертывания проекта.
.dockerignore - Исключает необязатльные файлы из создания контейнеров.
docker-compose.yml - Конфигурация для локального запуска проекта.
README.md - Документация проекта.

## Требования

- Docker
- Docker Compose

## Как запустить

### Запуск через Docker Compose

Перейдите в директорию `src/` и выполните:

```bash
cd src
docker-compose up --build
```

Сервер будет доступен по адресу http://localhost:8074.

Для остановки используйте `Ctrl+C` или `docker-compose down`.

### Ручная сборка и запуск

Для ручной сборки Docker-образа:

```bash
cd src
docker build -t go-server:stu-220017-v13 .
docker run -p 8074:8074 \
  -e STU_ID=220017 \
  -e STU_GROUP=АС-63 \
  -e STU_VARIANT=13 \
  -e POSTGRES_HOST=postgres \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=app_220017_v13 \
  go-server:stu-220017-v13
```

**Примечание:** При ручном запуске убедитесь, что PostgreSQL доступен по указанному адресу.

## Endpoints

GET /ready - Readiness check
GET /health - Health check

## Graceful Shutdown

Сервер поддерживает graceful shutdown, ожидая сигнала типа SIGINT или SIGTERM, позволяя системе закончить все запросы в течение 5 секунд.

Для тестирования graceful shutdown:

1. Запустите сервер через `docker-compose up`
2. Отправьте сигнал SIGTERM: `docker-compose stop` или `Ctrl+C` в консоли
3. В логах должны появиться сообщения:
   - "Shutting down server..."
   - "Server exiting"

Сервер корректно завершит все активные соединения перед остановкой.

## Student Metadata

```
Full Name: Кухарчук Илья Николаевич
Group: АС-63
Student ID: 220017
Email (Academic): as006314@g.bstu.by
GitHub Username: IlyaKukharchuk
Variant №: 13
Completion Date: 13/11/2025
Operating System: Windows 10 (10.0.19045)
Docker Version: Docker Desktop / Engine (указать версию при наличии)
```
