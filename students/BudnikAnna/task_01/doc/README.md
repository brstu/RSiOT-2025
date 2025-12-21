# Go net/http Service with Redis

## Description

A minimal Go net/http service running on port **8083**, with a **/ready** health endpoint. Connects to **Redis** for data persistence (request counter). Built with security in mind: non-root user (**UID 65532**), multi-stage Docker build, healthcheck, and graceful shutdown on **SIGTERM**.

Version: **v3**

## Метаданные студента

- ФИО: Будник Анна
- Группа: АС-64
- № студенческого (StudentID): 220033
- Email (учебный): 
- GitHub username: annettebb
- Вариант №: №3
- Дата выполнения: 18.12.2025
- ОС (версия): сборка ОС 19045.6456
- Версия Docker Desktop/Engine: 

## Setup and Run

1. Ensure Docker and Docker Compose are installed.
2. Build and start: `docker compose up --build`
3. Access:
   - http://localhost:8083/ (hello + counter)
   - http://localhost:8083/ready (health check)
4. Environment vars: configurable in `docker-compose.yml`:
   - `PORT=8083`
   - `REDIS_ADDR=redis:6379`
   - `REDIS_DB=0`
   - `SHUTDOWN_TIMEOUT=10s`
5. Stop:
   - Ctrl+C (triggers graceful shutdown)
   - or `docker compose down`

## Image Tag

Uses `lab01:**v3**` (adjust image name if needed).

## Volumes

- `data_v3`: persists Redis data (AOF).

## Testing Graceful Shutdown

- Run the service: `docker compose up --build`
- Send SIGTERM to the app container:
  1) Get container name:
     - `docker ps`
  2) Send SIGTERM:
     - `docker kill --signal=SIGTERM <APP_CONTAINER_NAME>`
- Check logs for graceful close (HTTP server and Redis client):
  - `docker logs <APP_CONTAINER_NAME>`

## Build Optimization

Dockerfile caches Go dependencies and build cache:
- `go mod download` layer caching
- BuildKit cache mounts for `/go/pkg/mod` and `go-build` cache

