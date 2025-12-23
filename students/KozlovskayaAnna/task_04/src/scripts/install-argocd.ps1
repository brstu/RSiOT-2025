# Скрипт установки Argo CD для Windows (PowerShell)
# Студент: Козловская Анна Геннадьевна, АС-63, 220012

Write-Host "=== Установка Argo CD ===" -ForegroundColor Green

# Создание namespace для Argo CD
Write-Host "1. Создание namespace argocd..." -ForegroundColor Yellow
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Установка Argo CD
Write-Host "2. Установка Argo CD..." -ForegroundColor Yellow
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Ожидание готовности Argo CD
Write-Host "3. Ожидание готовности подов Argo CD..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Получение пароля администратора
Write-Host ""
Write-Host "=== Argo CD установлен! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Получение пароля администратора:" -ForegroundColor Cyan
$ARGOCD_PASSWORD = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$ARGOCD_PASSWORD = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ARGOCD_PASSWORD))
Write-Host "Логин: admin" -ForegroundColor Yellow
Write-Host "Пароль: $ARGOCD_PASSWORD" -ForegroundColor Yellow
Write-Host ""
Write-Host "Port-forward для доступа к UI:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
Write-Host "  URL: https://localhost:8080"
Write-Host ""
Write-Host "Применение Application манифеста:" -ForegroundColor Cyan
Write-Host "  kubectl apply -f ..\argocd\application.yaml"
Write-Host ""
