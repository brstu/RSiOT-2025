# Лабораторная работа №1

## Описание

Это простой HTTP-сервис написанный на языке JS, с определенными endpoint-ами (/ready, /healthz) и поддержкой graceful shutdown. Данный проект был упакован в Docker-контейнер с использованием мельтиуровневого развёртывания для более удобного и работоспособного деплоя на другие устройства. Сервер имеет единственную зависимость - драйвера для работы с Postgres.

## Структура проекта

Dockerfile - Мультуровневный Dockerfile для развертывания проекта.
.dockerignore - Исключает необязатльные файлы из создания контейнеров.
docker-compose.yml - Конфигурация для локального запуска проекта.
README.md - Документация проекта.

## Требования

- Docker
- Docker Compose

## Как запустить

Забилдить и запустить используя Docker Compose:
```docker-compose up --build```

## Endpoints

GET /ready - Readiness check
GET /healthz - Health check

## Graceful Shutdown

Сервер поддерживает graceful shutdown, ожидая сигнала типа SIGNIT или SIGTERM, позволяя системе закончить все запросы в течении 5 секунд. Для теста, пошлите какой-либо SIGTERM-сигнал (например Ctrl+C в консоли) и ожидайте "Shutting down server..." и "Server exiting" в коносли.

## Student Metadata

```
Full Name: ровнейко Захар Сергеевич
Group: АС-64
Student ID: 220022
Email (Academic): as006423@g.bstu.by
GitHub Username: Zaharihnio
Variant №: 40
Operating System: Windows 10 Pro 22H2, Ubuntu 22.04
Docker Version: Docker Desktop 4.45.0 / Engine 28.3.3
```
