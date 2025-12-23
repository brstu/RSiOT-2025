#!/bin/bash
# Скрипт для генерации нагрузки на приложение
# Используется для тестирования метрик и алертов

APP_URL="http://localhost:8080"
REQUESTS=1000
DELAY=0.1

echo "=== Генерация тестовой нагрузки ==="
echo "URL: $APP_URL"
echo "Запросов: $REQUESTS"
echo ""

# Счётчик
count=0

while [ $count -lt $REQUESTS ]; do
  # 70% нормальных запросов
  if [ $((RANDOM % 10)) -lt 7 ]; then
    curl -s "$APP_URL/api/data" > /dev/null
  # 20% медленных запросов
  elif [ $((RANDOM % 10)) -lt 9 ]; then
    curl -s "$APP_URL/api/slow" > /dev/null
  # 10% запросов с возможными ошибками
  else
    curl -s "$APP_URL/api/error" > /dev/null
  fi
  
  count=$((count + 1))
  
  # Прогресс каждые 100 запросов
  if [ $((count % 100)) -eq 0 ]; then
    echo "Выполнено: $count/$REQUESTS запросов"
  fi
  
  sleep $DELAY
done

echo ""
echo "=== Нагрузка завершена! ==="
echo "Проверьте метрики: $APP_URL/metrics"
