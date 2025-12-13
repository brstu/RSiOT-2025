# PowerShell script для установки Lab 04 (Observability and Metrics)
# Variant 23: prefix=app23_, SLO=99.5%, p95≤200ms, Alert: 5xx>1% за 5м

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Lab 04: Observability and Metrics" -ForegroundColor Cyan
Write-Host "Student: Ярмола Александр Олегович" -ForegroundColor Cyan
Write-Host "Group: АС-63, Variant: 23" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Проверка Minikube
Write-Host "[1/7] Checking Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Minikube is not running. Starting..." -ForegroundColor Red
    minikube start --cpus=4 --memory=8192 --driver=docker
} else {
    Write-Host "Minikube is running ✓" -ForegroundColor Green
}

# Добавление Helm репозитория
Write-Host "`n[2/7] Adding Helm repository..." -ForegroundColor Yellow
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
Write-Host "Helm repo added ✓" -ForegroundColor Green

# Установка kube-prometheus-stack
Write-Host "`n[3/7] Installing kube-prometheus-stack..." -ForegroundColor Yellow
$helmList = helm list -n monitoring 2>&1
if ($helmList -match "monitoring") {
    Write-Host "kube-prometheus-stack already installed. Skipping..." -ForegroundColor Yellow
} else {
    helm install monitoring prometheus-community/kube-prometheus-stack `
        --namespace monitoring `
        --create-namespace `
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false `
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false `
        --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false
    
    Write-Host "Waiting for Grafana to be ready (this may take 5-10 minutes)..." -ForegroundColor Yellow
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana `
        -n monitoring --timeout=600s
    Write-Host "kube-prometheus-stack installed ✓" -ForegroundColor Green
}

# Сборка образа приложения
Write-Host "`n[4/7] Building monitoring-app Docker image..." -ForegroundColor Yellow
$env:DOCKER_HOST = minikube docker-env --shell powershell | Invoke-Expression
docker build -t monitoring-app:latest src/app/
if ($LASTEXITCODE -eq 0) {
    Write-Host "Docker image built ✓" -ForegroundColor Green
} else {
    Write-Host "Failed to build Docker image!" -ForegroundColor Red
    exit 1
}

# Установка приложения
Write-Host "`n[5/7] Installing monitoring-app via Helm..." -ForegroundColor Yellow
$helmAppList = helm list -n monitoring-app 2>&1
if ($helmAppList -match "monitoring-app") {
    Write-Host "monitoring-app already installed. Upgrading..." -ForegroundColor Yellow
    helm upgrade monitoring-app ./src/helm/monitoring-app --namespace monitoring-app
} else {
    helm install monitoring-app ./src/helm/monitoring-app `
        --namespace monitoring-app `
        --create-namespace
}
Write-Host "monitoring-app installed ✓" -ForegroundColor Green

# Проверка развертывания
Write-Host "`n[6/7] Checking deployments..." -ForegroundColor Yellow
Write-Host "`nNamespace: monitoring" -ForegroundColor Cyan
kubectl get pods -n monitoring
Write-Host "`nNamespace: monitoring-app" -ForegroundColor Cyan
kubectl get all -n monitoring-app

Write-Host "`n[7/7] Installation complete! ✓`n" -ForegroundColor Green

# Инструкции по доступу
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Access Instructions" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "1. Grafana (Dashboards):" -ForegroundColor Yellow
Write-Host "   kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring" -ForegroundColor White
Write-Host "   URL: http://localhost:3000" -ForegroundColor White
Write-Host "   Login: admin" -ForegroundColor White
Write-Host "   Password: (run command below)" -ForegroundColor White
Write-Host "   kubectl get secret monitoring-grafana -n monitoring -o jsonpath='{.data.admin-password}' | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(`$_)) }`n" -ForegroundColor Gray

Write-Host "2. Prometheus (Metrics):" -ForegroundColor Yellow
Write-Host "   kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring" -ForegroundColor White
Write-Host "   URL: http://localhost:9090`n" -ForegroundColor White

Write-Host "3. Application Metrics:" -ForegroundColor Yellow
Write-Host "   kubectl port-forward svc/monitoring-app 8080:80 -n monitoring-app" -ForegroundColor White
Write-Host "   URL: http://localhost:8080/metrics`n" -ForegroundColor White

Write-Host "4. Generate Load (test alerts):" -ForegroundColor Yellow
Write-Host "   # Normal traffic" -ForegroundColor Gray
Write-Host "   while (`$true) { Invoke-WebRequest http://localhost:8080/api/data -UseBasicParsing | Out-Null; Start-Sleep -Milliseconds 100 }`n" -ForegroundColor White
Write-Host "   # Trigger HighLatencyP95 alert" -ForegroundColor Gray
Write-Host "   while (`$true) { Invoke-WebRequest http://localhost:8080/api/slow -UseBasicParsing | Out-Null; Start-Sleep -Milliseconds 500 }`n" -ForegroundColor White
Write-Host "   # Trigger HighErrorRate5xx alert" -ForegroundColor Gray
Write-Host "   while (`$true) { try { Invoke-WebRequest http://localhost:8080/api/error -UseBasicParsing } catch {}; Start-Sleep -Milliseconds 100 }`n" -ForegroundColor White

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Variant 23 Configuration" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Metrics prefix: app23_" -ForegroundColor White
Write-Host "SLO Availability: 99.5%" -ForegroundColor White
Write-Host "SLO p95 Latency: ≤200ms" -ForegroundColor White
Write-Host "Alert: 5xx errors >1% for 5m`n" -ForegroundColor White

Write-Host "Alerts:" -ForegroundColor Yellow
Write-Host "  1. LowAvailability - triggers if availability < 99.5%" -ForegroundColor White
Write-Host "  2. HighErrorRate5xx - triggers if 5xx errors > 1% for 5m" -ForegroundColor White
Write-Host "  3. HighLatencyP95 - triggers if p95 latency > 200ms for 5m`n" -ForegroundColor White

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "For full documentation, see doc/README.md" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan
