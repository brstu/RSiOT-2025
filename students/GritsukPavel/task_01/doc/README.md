# Лабораторная работа №01

<p align="center">Министерство образования Республики Беларусь</p>
<p align="center">Учреждение образования</p>
<p align="center">"Брестский Государственный технический университет"</p>
<p align="center">Кафедра ИИТ</p>
<br><br><br><br><br><br>
<p align="center"><strong>Лабораторная работа №01</strong></p>
<p align="center"><strong>По дисциплине:</strong> "Распределенные системы и облачные технологии"</p>
<p align="center"><strong>Тема:</strong> Контейнеризация и Docker</p>
<br><br><br><br><br><br>
<p align="right"><strong>Выполнил:</strong></p>
<p align="right">Студент 4 курса</p>
<p align="right">Группы АС-63</p>
<p align="right">Грицук П. Э.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться собирать Docker образы и запускать контейнеры. Закрепить основы docker-compose: зависимости (БД), volume, сети.

---

### Вариант №4

## Метаданные студента

- **ФИО:** Грицук Павел Эдуардович
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220007
- **Email (учебный):** <as006304@g.bstu.by>
- **GitHub username:** momo-kitsune
- **Вариант №:** 4
- **ОС и версия:** Windows 11 22H2, Docker Desktop v4.54.0

---

## Окружение и инструменты

- **Язык/Фреймворк:** Node.js 22 / Express.js
- **База данных:** PostgreSQL 16
- **Порт приложения:** 8084
- **Health endpoint:** /live
- **Volume:** data_v4
- **UID пользователя:** 10001
- **Тег образа:** v4

## Структура репозитория c описанием содержимого

```text
task_01/
├── doc/
│   └── README.md           # Отчет по лабораторной работе
└── src/
    ├── src/
    │   └── index.js        # Исходный код Express приложения
    ├── Dockerfile           # Описание образа приложения
    ├── docker-compose.yml   # Конфигурация сервисов
    ├── package.json         # Зависимости Node.js
    └── .env                 # Переменные окружения
```

## Подробное описание выполнения

### 1. Создание минимального HTTP-сервиса на Node.js/Express

Реализован простой Express-сервер с двумя endpoints:

- `GET /` - возвращает приветствие и метаданные студента
- `GET /live` - health check endpoint, проверяет подключение к БД

Приложение использует переменные окружения для конфигурации и логирует метаданные студента при старте.

### 2. Создание Dockerfile

Создан Dockerfile на базе `node:22-alpine`:

- Установлен USER с UID 10001
- Приложение запускается от непривилегированного пользователя
- EXPOSE 8084

### 3. Настройка docker-compose.yml

Настроены два сервиса:

- **app** - Node.js приложение (порт 8084)
- **db** - PostgreSQL 16 (база данных app_220007_v4)

Созданы:

- Volume `data_v4` для хранения данных PostgreSQL
- Сеть `net-as63-220007-v04` для связи сервисов
- Зависимость app от db

### 4. Запуск и проверка работы

Сборка и запуск:

```bash
cd src
docker-compose up --build
```

Проверка health endpoint:

```bash
curl http://localhost:8084/live
```

Ожидаемый результат:

```json
{"status":"ok"}
```

### 5. Проверка работы с БД

```bash
curl http://localhost:8084/
```

Ожидаемый результат:

```json
{"hello":"world","variant":"v4","student":"220007"}
```

## Контрольный список (checklist)

- [ ✅ ] README с полными метаданными студента
- [ ✅ ] Dockerfile (non-root user, EXPOSE)
- [ ✅ ] docker-compose.yml с сервисами app и db
- [ ✅ ] Volume для PostgreSQL данных
- [ ✅ ] Сеть для связи между сервисами
- [ ✅ ] Health check endpoint /live
- [ ✅ ] Логирование метаданных при старте (STU_ID, STU_GROUP, STU_VARIANT)
- [ ✅ ] Переменные окружения для конфигурации

---

## Команды для запуска

```bash
# Переход в директорию src
cd src

# Сборка и запуск контейнеров
docker-compose up --build

# В другом терминале - проверка работы
curl http://localhost:8084/
curl http://localhost:8084/live

# Остановка
docker-compose down

# Полная очистка (включая volume)
docker-compose down -v
```

## Вывод

В ходе выполнения лабораторной работы были освоены базовые навыки работы с Docker:

- Создание Dockerfile для Node.js приложения с непривилегированным пользователем
- Настройка docker-compose для запуска связанных сервисов (приложение + PostgreSQL)
- Работа с volumes для персистентности данных
- Настройка сетевого взаимодействия между контейнерами
- Использование переменных окружения для конфигурации

Реализовано простое Express приложение с health check endpoint и подключением к PostgreSQL. Приложение корректно запускается в Docker контейнере и взаимодействует с базой данных.
