# Используем официальный образ Go
FROM golang:1.21-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы из папки src
COPY src/go.mod ./go.mod
RUN go mod download 2>/dev/null || true

# Копируем остальной исходный код
COPY src/ ./

# Собираем приложение
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Создаем минимальный образ для запуска
FROM alpine:3.19

# Устанавливаем рабочего пользователя с UID 10001
RUN adduser -D -u 10001 appuser

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем скомпилированное приложение из builder stage
COPY --from=builder /app/main .

# Меняем владельца файлов
RUN chown -R appuser:appuser /app

# Переключаемся на непривилегированного пользователя
USER appuser

# Открываем порт 8083
EXPOSE 8083

# Команда запуска
CMD ["./main"]