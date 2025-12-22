# «Метаданные студента»

- ФИО - Грицук Дмитрий Юрьевич
- Группа - АС-63
- № студенческого/зачетной книжки (StudentID) - 220006
- Email (учебный) -as006306@g.bstu.by
- GitHub username - llayyz
- Вариант № - 3
- Дата выполнения - 22.12.2025
- ОС (версия), версия Docker Desktop/Engine - Windows 10, Docker version 28.4.0

## RSOT Проект

Разработка минимального веб-приложения на Go с использованием стандартного пакета net/http и подключением к базе данных Redis. Контейнеризированное приложение для быстрого развёртывания через Docker, использующее порт 8083, точку проверки /ready и собственный volume data_v3.

### 1. Клонировать репазиторий

```bash
git clone https://github.com/llayyz/task_01.git
cd task_01
```

### 2. Сбор и запуск контейнера

```bash
- docker compose up -d --build
```

### 3. Подтвердить приложение

#### 3.1 Healthcheck

```bash
Invoke-RestMethod http://localhost:8083/ready
```

{"group":"АС-63","id":"220006","service":"Variant 3 - Грицук Дмитрий Юрьевич","status":"ready","version":"v3"}

#### 3.2 Readiness

```bash
Invoke-WebRequest http://localhost:8083/
```

{
  "status": "ready",
  "service": "Variant 3 - Грицук Дмитрий Юрьевич",
  "group": "АС-63",
  "id": "220006",
  "version": "v3"
}

#### 3.3 Главная страница

```bash
Invoke-WebRequest http://localhost:8083/
```

Открыть в браузере: http://localhost:8083/

### 4. Остановка и удаление контейнера

```bash
docker compose down
```
