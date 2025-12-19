# Скрипт установки kube-prometheus-stack для Windows (PowerShell)
# Студент: Козловская Анна Геннадьевна, АС-63, 220012

Write-Host "=== Установка kube-prometheus-stack ===" -ForegroundColor Green

# Добавление Helm репозитория
Write-Host "1. Добавление Helm репозитория prometheus-community..." -ForegroundColor Yellow
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Создание namespace для мониторинга
Write-Host "2. Создание namespace monitoring..." -ForegroundColor Yellow
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Установка kube-prometheus-stack
Write-Host "3. Установка kube-prometheus-stack..." -ForegroundColor Yellow
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false `
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false `
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false `
  --set prometheus.prometheusSpec.retention=7d `
  --set grafana.adminPassword=admin `
  --wait

Write-Host ""
Write-Host "=== Установка завершена! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Для доступа к компонентам используйте port-forward:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prometheus:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
Write-Host "  URL: http://localhost:9090"
Write-Host ""
Write-Host "Grafana (admin/admin):" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
Write-Host "  URL: http://localhost:3000"
Write-Host ""
Write-Host "Alertmanager:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093"
Write-Host "  URL: http://localhost:9093"
Write-Host ""
