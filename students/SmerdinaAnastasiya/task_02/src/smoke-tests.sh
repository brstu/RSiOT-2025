#!/bin/bash
# Скрипт для запуска smoke-тестов - Лабораторная работа №02
# Студент: Смердина Анастасия Валентиновна, Группа: АС-64, Вариант: 41

set -e

NAMESPACE="app41"
SERVICE="net-as64-220053-v41"
PORT="7991"

echo "=== Smoke Tests для web41 ==="
echo "Namespace: $NAMESPACE"
echo "Service: $SERVICE"
echo ""

# Проверка готовности подов
echo "1. Проверка готовности подов..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=web41 -n $NAMESPACE --timeout=120s
echo "✓ Поды готовы"
echo ""

# Проверка Health endpoint
echo "2. Проверка /health endpoint..."
HEALTH_RESPONSE=$(kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- \
  curl -s http://$SERVICE:$PORT/health)
echo "$HEALTH_RESPONSE"

if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    echo "✓ Health check PASSED"
else
    echo "✗ Health check FAILED"
    exit 1
fi
echo ""

# Проверка Ready endpoint
echo "3. Проверка /ready endpoint..."
READY_RESPONSE=$(kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- \
  curl -s http://$SERVICE:$PORT/ready)
echo "$READY_RESPONSE"

if echo "$READY_RESPONSE" | grep -q "ready"; then
    echo "✓ Ready check PASSED"
else
    echo "✗ Ready check FAILED"
    exit 1
fi
echo ""

# Проверка Info endpoint
echo "4. Проверка /info endpoint..."
INFO_RESPONSE=$(kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- \
  curl -s http://$SERVICE:$PORT/info)
echo "$INFO_RESPONSE"

if echo "$INFO_RESPONSE" | grep -q "220053"; then
    echo "✓ Info check PASSED"
else
    echo "✗ Info check FAILED"
    exit 1
fi
echo ""

# Проверка главной страницы
echo "5. Проверка главной страницы..."
ROOT_RESPONSE=$(kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- \
  curl -s http://$SERVICE:$PORT/)

if echo "$ROOT_RESPONSE" | grep -q "Лабораторная работа"; then
    echo "✓ Root page check PASSED"
else
    echo "✗ Root page check FAILED"
    exit 1
fi
echo ""

# Проверка количества подов
echo "6. Проверка количества реплик..."
POD_COUNT=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=web41 --no-headers | wc -l)
if [ "$POD_COUNT" -eq 3 ]; then
    echo "✓ Количество реплик корректно: $POD_COUNT"
else
    echo "✗ Неверное количество реплик: $POD_COUNT (ожидается 3)"
    exit 1
fi
echo ""

# Проверка Service
echo "7. Проверка Service..."
kubectl get svc $SERVICE -n $NAMESPACE > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Service найден"
else
    echo "✗ Service не найден"
    exit 1
fi
echo ""

# Проверка Deployment
echo "8. Проверка Deployment..."
kubectl get deployment app-as64-220053-v41 -n $NAMESPACE > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Deployment найден"
else
    echo "✗ Deployment не найден"
    exit 1
fi
echo ""

echo "=== Все тесты пройдены успешно! ==="
echo ""
echo "Статус ресурсов:"
kubectl get all -n $NAMESPACE