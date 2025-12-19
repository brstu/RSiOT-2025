# Скрипт деплоя приложения через Helm для Windows (PowerShell)
# Студент: Козловская Анна Геннадьевна, АС-63, 220012

$CHART_DIR = "..\helm"
$RELEASE_NAME = "as63-220012-v8-app"
$NAMESPACE = "app-as63-220012-v8"

Write-Host "=== Деплой мониторингового приложения ===" -ForegroundColor Green

# Проверка Helm чарта
Write-Host "1. Проверка Helm чарта..." -ForegroundColor Yellow
helm lint $CHART_DIR

# Создание namespace (если не существует)
Write-Host "2. Создание namespace $NAMESPACE..." -ForegroundColor Yellow
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Установка/обновление приложения
Write-Host "3. Установка приложения через Helm..." -ForegroundColor Yellow
helm upgrade --install $RELEASE_NAME $CHART_DIR `
  --namespace $NAMESPACE `
  --create-namespace `
  --wait

Write-Host ""
Write-Host "=== Деплой завершён! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Проверка статуса:" -ForegroundColor Cyan
Write-Host "  kubectl get all -n $NAMESPACE"
Write-Host ""
Write-Host "Просмотр подов:" -ForegroundColor Cyan
Write-Host "  kubectl get pods -n $NAMESPACE"
Write-Host ""
Write-Host "Логи приложения:" -ForegroundColor Cyan
Write-Host "  kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=monitoring-app -f"
Write-Host ""
Write-Host "Port-forward для локального доступа:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-monitoring-app 8080:8080"
Write-Host "  URL: http://localhost:8080"
Write-Host "  Metrics: http://localhost:8080/metrics"
Write-Host ""
Write-Host "Проверка ServiceMonitor:" -ForegroundColor Cyan
Write-Host "  kubectl get servicemonitor -n monitoring $RELEASE_NAME-monitoring-app"
Write-Host ""
Write-Host "Проверка PrometheusRule:" -ForegroundColor Cyan
Write-Host "  kubectl get prometheusrule -n monitoring $RELEASE_NAME-monitoring-app"
Write-Host ""
