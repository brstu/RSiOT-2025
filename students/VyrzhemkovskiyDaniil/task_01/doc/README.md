# Лабораторная работа 01 — Контейнеризация и Docker

## Метаданные студента

- ФИО: Выржемковский Даниил Иванович
- Группа: АС-63
- № зачётной книжки (StudentID): 220005
- Email: [danikv0305@gmail.com]
- GitHub username: `romb123`
- Вариант: 2
- Стек: Python/Flask + Postgres
- Порт приложения: 8082
- Health endpoint: `/healthz`
- Volume для БД: `data_v2`
- UID непривилегированного пользователя в контейнере: `10001`

## Сборка и запуск

```bash
docker compose up --build
```

```bash
curl http://localhost:8082/
```

```bash
curl http://localhost:8082/healthz
```
