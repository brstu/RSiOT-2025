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
<p align="right">Группы АС-64</p>
<p align="right">Бурак И. Э.</p>
<p align="right"><strong>Проверил:</strong></p>
<p align="right">Несюк А. Н.</p>
<br><br><br><br><br>
<p align="center"><strong>Брест 2025</strong></p>

---

## Цель работы

Научиться собирать образы Docker и запускать контейнеры.

---

### Вариант №29

## Метаданные студента

- **ФИО:** Бурак Илья Эдуардович
- **Группа:** АС-64
- **№ студенческого (StudentID):** 220035
- **Email (учебный):** <as006405@g.bstu.by>
- **GitHub username:** burakillya
- **Вариант №:** 29
- **ОС и версия:** Windows 10 1809, Docker Desktop v4.53.0

---

## Окружение и инструменты

- Python/Flask
- Redis
- Docker Desktop

## Структура репозитория

```text
src/
  app.py               # Flask приложение
  requirements.txt     # зависимости
  Dockerfile           # сборка образа
  docker-compose.yml   # запуск сервисов
doc/
  README.md            # документация
```

## Подробное описание выполнения

### 1. Создание Flask приложения

Создан файл app.py с эндпоинтами:

- `/` - главная страница
- `/healthz` - проверка здоровья
- `/data` - работа с Redis

### 2. Dockerfile

Создан Dockerfile для сборки образа на базе python:3.11.

### 3. Docker Compose

Создан docker-compose.yml с двумя сервисами: app и redis.

## Запуск

```bash
cd src
docker-compose up --build
```

## Контрольный список (checklist)

- [✅] README с метаданными студента
- [❌] Dockerfile (multi-stage, non-root, labels) - только labels
- [✅] docker-compose.yml
- [❌] Volume для данных
- [❌] HEALTHCHECK в Dockerfile
- [❌] Graceful shutdown

---

## Вывод

В ходе выполнения лабораторной работы было создано простое Flask приложение и упаковано в Docker контейнер. Настроена работа с Redis.
