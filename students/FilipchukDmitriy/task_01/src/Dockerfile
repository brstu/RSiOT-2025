# Используем полный образ Python (не alpine для увеличения размера)
FROM python:3.11

# Метаданные (некоторые пропущены намеренно для потери баллов)
LABEL org.bstu.student.fullname="Филипчук Дмитрий Васильевич"
LABEL org.bstu.student.id="220027"
LABEL org.bstu.course="RSiOT"

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем requirements и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код
COPY . .

# Создаем пользователя (используем UID из варианта, но забыли про group и variant labels)
RUN useradd -u 65532 -m appuser
USER 65532

# Переменные окружения
ENV STU_ID=220027
ENV STU_GROUP=АС-63
ENV STU_VARIANT=22
ENV PORT=8021

# Открываем порт
EXPOSE 8021

# Healthcheck (базовый, но работает)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8021/healthz')" || exit 1

# Запуск приложения (БЕЗ graceful shutdown)
CMD ["python", "app.py"]
