# Министерство образования Республики Беларусь

<p align="center">Учреждение образования</p>
<p align="center">“Брестский Государственный технический университет”</p>
<p align="center">Кафедра ИИТ</p>

<p align="center"><strong>Лабораторная работа №1</strong></p>
<p align="center"><strong>По дисциплине:</strong> “РСиОТ”</p>
<p align="center"><strong>Тема:</strong> “Контейнеризация и Docker”</p>

<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-64</p>
<p align="right">Рабченя М.Ю.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А.Н.</p>

<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Освоить основы контейнеризации с использованием Docker, научиться собирать минимальные образы (multi-stage build), работать с volume, сетями, и docker-compose, а также реализовать graceful shutdown и healthcheck для сервисов.

---

### Вариант 39

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

Dockerfile использует multi-stage build, что позволяет получить минимальный финальный образ.

Этап builder: используется образ `golang:1.25-alpine` для сборки приложения.

Этап final: используется минимальный образ `alpine:latest`.

Ненулевой UID: Задается пользователь `appuser` с UID 65532 (через `adduser -u 65532`), что соответствует требованиям безопасности.

`RUN addgroup -S appgroup && adduser -S appuser -G appgroup -u 65532`

`USER appuser`

Порт: Приложение открывает порт 8063.

`EXPOSE 8063`

HEALTHCHECK: Настроен эндпоинт `/ping` с использованием `curl`.

`HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
 CMD curl -f http://localhost:8063/ping || exit 1`

Метаданные (LABEL): Указаны поля студента и информация по сборке.

### 3. docker-compose.yml

Файл оркестрации включает два сервиса: `app` (Go-приложение) и `redis` (база данных).

Рекомендуемые настройки (пример):

- slug: `as-63-<STUDENT_ID>-v15`
- имя контейнера: `app-as-63-<STUDENT_ID>-v15`
- проброс порта: `8063:8063`
- depends_on: `[redis]`
- env: `APP_PORT=8063`, `REDIS_ADDR=redis:6379`, `STU_ID=<STUDENT_ID>`, `STU_GROUP=АС-63`, `STU_VARIANT=15`

Сервис `redis`:

- образ: `redis:7-alpine`
- имя контейнера: `redis-as-63-<STUDENT_ID>-v15`
- volume: именованный том `data-as-63-<STUDENT_ID>-v15` для хранения данных Redis
- сеть: общая сеть `net-as-63-<STUDENT_ID>-v15`

### 4. Реализация graceful shutdown

В коде Go-приложения реализована обработка системных сигналов SIGINT и SIGTERM, что обеспечивает плавное завершение работы сервера. Пример реализации:

```go
quit := make(chan os.Signal, 1)
signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)

<-quit
log.Println("Получен сигнал для завершения работы. Начинаю остановку сервера...")

ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

if err := server.Shutdown(ctx); err != nil {}
```

### 5. Проверка работы

#### Запуск

```bash
docker compose up --build
```

Эндпоинты приложения:

`/ping — Healthcheck`, возвращает OK.

`/` — Основной эндпоинт, увеличивает счетчик посещений в Redis и выводит информацию о студенте.

Примеры запросов:

```bash
curl http://localhost:8063/ping
curl http://localhost:8063/
```

### 6. Проверка требований

| Критерий | Выполнено | Комментарий |
|-----------|-----------|--------------|
| Multi-stage build | ✅ | Сборка с golang:1.25-alpine в alpine:latest |
| USER ненулевой | ✅ | Пользователь appuser с UID 65532 |
| EXPOSE / HEALTHCHECK | ✅ | порт 8063, /ping |
| ENV конфигурация | ✅ | все переменные заданы (пример) |
| docker-compose (app + db + volume + network) | ✅ | корректно оформлено (пример) |
| Graceful shutdown | ✅ | через `server.Shutdown` |
| Кэширование зависимостей | ✅ | с `--mount=type=cache` |
| LABEL / slug / теги образов | ✅ | поля указаны как пример |
| README и отчёт | ✅ | оформлено в соответствии с ТЗ (заполнить метаданные) |

---

## Метаданные студента (заполните, пожалуйста)

| Поле | Значение |
|------|-----------|
| **ФИО** | Рабченя Максим |
| **Группа** | АС-63 |
| **StudentID** | <YOUR_STUDENT_ID> |
| **Email (учебный)** | <your_email@example.com> |
| **GitHub username** | <your_github> |
| **Вариант** | 39 |
| **ОС / Docker** | (например: W10, Docker Desktop) |
| **Slug** | as-64-<YOUR_STUDENT_ID>-v39 |

---

## Вывод

В ходе лабораторной работы:
- Собран минимальный контейнеризированный Go-сервис (multi-stage build).
- Настроен `redis` как зависимость через `docker-compose`.
- Реализован `graceful shutdown` и `healthcheck`.
- Использованы `--mount=type=cache` для кэширования зависимостей и ненулевой `USER`.

Замените плейсхолдеры в секции "Метаданные студента" на свои данные и при желании пришлите их — я обновлю файл под ваши реальные значения.
