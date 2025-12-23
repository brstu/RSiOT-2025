# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>

<p align="center"><strong>Лабораторная работа №2</strong></p>
<p align="center"><strong>По дисциплине:</strong> “РСиОТ”</p>
<p align="center"><strong>Тема:</strong> “Контейнеризация и Docker — продолжение / Практика”</p>

<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Рабченя Максим</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Углубить навыки контейнеризации с Docker и Docker Compose: оптимизация образов, добавление healthchecks, управление томами и сетями, а также корректная остановка сервисов (graceful shutdown).

---

### Вариант (проверьте параметры и замените при необходимости)

| Параметр            | Значение                  |
|---------------------|---------------------------|
| Стек                | Go (net/http)             |
| Порт приложения     | 8063                      |
| Healthcheck endpoint| `/ping`                   |
| Зависимость         | Redis                     |
| Volume              | `data_v15`                |
| UID                 | 65532                     |
| Тег                 | `v15`                     |

---

## Ход выполнения работы

### 1. Структура проекта

- `Dockerfile` — multi-stage сборка Go-приложения
- `docker-compose.yml` — оркестрация приложения (app) и базы данных (redis)
- `main.go` — исходный код HTTP-сервиса на Go (net/http) с использованием Redis для подсчета посещений
- `.dockerignore` — правила игнорирования файлов при сборке образа
- `README.md` — отчёт и инструкции

### 2. Dockerfile (основные моменты)

Dockerfile использует multi-stage build для уменьшения финального размера образа.

Этап builder: используется образ `golang:1.25-alpine` для сборки приложения.

Этап final: используется минимальный образ `alpine:latest`.

Ненулевой UID: задаётся пользователь `appuser` с UID 65532.

`RUN addgroup -S appgroup && adduser -S appuser -G appgroup -u 65532`

`USER appuser`

Порт: Приложение слушает порт 8063.

`EXPOSE 8063`

HEALTHCHECK: проверка `/ping` через `curl`.

`HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
 CMD curl -f http://localhost:8063/ping || exit 1`

Кэширование зависимостей: рекомендуется использовать `--mount=type=cache` в этапе сборки.

### 3. docker-compose.yml

Композиция включает сервисы `app` и `redis` с именованным томом и отдельной сетью.

Пример настроек:

- slug: `as-63-<STUDENT_ID>-v15`
- контейнер: `app-as-63-<STUDENT_ID>-v15`
- порты: `8063:8063`
- depends_on: `[redis]`
- env: `APP_PORT=8063`, `REDIS_ADDR=redis:6379`, `STU_ID=<STUDENT_ID>`, `STU_GROUP=АС-64`, `STU_VARIANT=39`

Redis:

- образ: `redis:7-alpine`
- контейнер: `redis-as-64-<STUDENT_ID>-v39`
- volume: `data-as-64-<STUDENT_ID>-v39:/data`
- сеть: `net-as-64-<STUDENT_ID>-v39`

### 4. Graceful shutdown

Реализована обработка сигналов SIGINT и SIGTERM для корректной остановки HTTP-сервера:

```go
quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
<-quit
log.Println("Получен сигнал для завершения работы. Начинаю остановку сервера...")
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()
if err := server.Shutdown(ctx); err != nil {}
```

### 5. Проверка и запуск

Запустить сборку и поднять сервисы:

```bash
docker compose up --build
```

Проверить healthcheck:

```bash
curl http://localhost:8063/ping
```

Проверить основной эндпоинт:

```bash
curl http://localhost:8063/
```

### 6. Критерии соответствия

| Критерий | Выполнено | Комментарий |
|-----------|-----------|--------------|
| Multi-stage build | ✅ | Использован builder и минимальный финальный образ |
| USER ненулевой | ✅ | `appuser` с UID 65532 |
| EXPOSE / HEALTHCHECK | ✅ | Порт 8063, `/ping` |
| ENV конфигурация | ✅ | Переменные окружения через compose |
| docker-compose (app + db + volume + network) | ✅ | Пример настроек включён |
| Graceful shutdown | ✅ | Через `server.Shutdown` |
| Кэширование зависимостей | ✅ | Рекомендация по `--mount=type=cache` |

---

## Метаданные студента (заполните, пожалуйста)

| Поле | Значение |
|------|-----------|
| **ФИО** | Рабченя Максим |
| **Группа** | АС-64 |
| **StudentID** | <YOUR_STUDENT_ID> |
| **Email (учебный)** | <your_email@example.com> |
| **GitHub username** | <your_github> |
| **Вариант** | 39 |
| **ОС / Docker** | (например: W10, Docker Desktop) |
| **Slug** | as-64-<YOUR_STUDENT_ID>-v39 |

---

## Вывод

- Собран контейнеризированный Go-сервис с multi-stage build.
- Настроены `redis`, volume и сеть в `docker-compose`.
- Реализован graceful shutdown и healthcheck.
