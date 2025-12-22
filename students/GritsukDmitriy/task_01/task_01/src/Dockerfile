# Используем официальный образ Go
FROM golang:1.21-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY . .

# Собираем приложение
RUN go build -o main .

# Создаем минимальный образ для запуска
FROM alpine:latest

# Устанавливаем рабочего пользователя с UID 65532
RUN adduser -D -u 65532 appuser

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем скомпилированное приложение из builder stage
COPY --from=builder /app/main .

# Создаем volume для данных
VOLUME /app/data

# Меняем владельца файлов
RUN chown -R appuser:appuser /app

# Переключаемся на непривилегированного пользователя
USER appuser

# Открываем порт 8083
EXPOSE 8083

# Команда запуска
CMD ["./main"]