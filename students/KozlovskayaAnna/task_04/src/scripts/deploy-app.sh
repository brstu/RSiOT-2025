#!/bin/bash
# Скрипт деплоя приложения через Helm
# Студент: Козловская Анна Геннадьевна, АС-63, 220012

set -e

CHART_DIR="../helm"
RELEASE_NAME="as63-220012-v8-app"
NAMESPACE="app-as63-220012-v8"

echo "=== Деплой мониторингового приложения ==="

# Проверка Helm чарта
echo "1. Проверка Helm чарта..."
helm lint $CHART_DIR

# Создание namespace (если не существует)
echo "2. Создание namespace $NAMESPACE..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Установка/обновление приложения
echo "3. Установка приложения через Helm..."
helm upgrade --install $RELEASE_NAME $CHART_DIR \
  --namespace $NAMESPACE \
  --create-namespace \
  --wait

echo ""
echo "=== Деплой завершён! ==="
echo ""
echo "Проверка статуса:"
echo "  kubectl get all -n $NAMESPACE"
echo ""
echo "Просмотр подов:"
echo "  kubectl get pods -n $NAMESPACE"
echo ""
echo "Логи приложения:"
echo "  kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=monitoring-app -f"
echo ""
echo "Port-forward для локального доступа:"
echo "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-monitoring-app 8080:8080"
echo "  URL: http://localhost:8080"
echo "  Metrics: http://localhost:8080/metrics"
echo ""
echo "Проверка ServiceMonitor:"
echo "  kubectl get servicemonitor -n monitoring $RELEASE_NAME-monitoring-app"
echo ""
echo "Проверка PrometheusRule:"
echo "  kubectl get prometheusrule -n monitoring $RELEASE_NAME-monitoring-app"
echo ""
