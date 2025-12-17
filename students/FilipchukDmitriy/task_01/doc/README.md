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
<p align="right">Филипчук Д. В.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться собирать образы Docker и запускать контейнеры. Закрепить основы docker-compose: зависимости, volume, сети.

---

### Вариант №22

## Метаданные студента

- **ФИО:** Филипчук Дмитрий Васильевич
- **Группа:** АС-63
- **№ студенческого (StudentID):** 220027
- **Email (учебный):** <as006327@g.bstu.by>
- **GitHub username:** kuddel11
- **Вариант №:** 22
- **ОС и версия:** Windows 11 24H2, Docker Desktop v4.53.0

---

## Окружение и инструменты

- **Язык и фреймворк:** Python 3.11, Flask
- **Зависимость:** Redis
- **Порт приложения:** 8021
- **Health endpoint:** /healthz
- **UID пользователя:** 65532

---

## Структура репозитория

```text
task_01/
├── src/
│   ├── app.py               # Flask приложение
│   ├── requirements.txt     # Python зависимости
│   ├── Dockerfile           # Образ приложения
│   └── docker-compose.yml   # Конфигурация сервисов
└── doc/
    └── README.md            # Документация
```

---

## Подробное описание выполнения

### 1. Создание Flask приложения

Простой HTTP-сервис с эндпоинтами:

- `/` - главная страница с счетчиком посещений (хранится в Redis)
- `/healthz` - проверка здоровья приложения

### 2. Dockerfile

Создан образ на базе `python:3.11`:

- Установка зависимостей
- Запуск под пользователем с UID 65532
- EXPOSE порта 8021
- HEALTHCHECK для /healthz

### 3. docker-compose.yml

Настроены сервисы:

- **app** - Flask приложение
- **redis** - хранилище данных с persistent volume

### 4. Запуск

```bash
cd src
docker-compose up --build
```

Приложение доступно на <http://localhost:8021>

---

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [✅] Dockerfile с базовыми настройками
- [✅] docker-compose.yml с Redis
- [✅] Health endpoint работает
- [✅] Volume для Redis данных
- [❌] Graceful shutdown не реализован
- [❌] Multi-stage build не оптимизирован
- [❌] Не все LABEL указаны

---

## Вывод

В ходе работы был создан базовый Flask-сервис, контейнеризирован с помощью Docker и настроен docker-compose для работы с Redis. Освоены основы работы с Docker: создание образов, запуск контейнеров, работа с volume и сетями.
