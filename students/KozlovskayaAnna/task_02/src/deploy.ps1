# PowerShell скрипт для развертывания в Kind - Лабораторная работа №02
# Студент: Козловская Анна Геннадьевна, Группа: АС-63, Вариант: 8

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("setup", "build", "deploy", "test", "status", "clean", "logs")]
    [string]$Action = "setup"
)

$ErrorActionPreference = "Stop"

# Переменные
$DOCKER_IMAGE = "annkrq/web08:latest"
$NAMESPACE = "app08"
$CLUSTER_NAME = "lab02-cluster"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Build-DockerImage {
    Write-ColorOutput Green "=== Сборка Docker образа ==="
    Set-Location src
    docker build -t $DOCKER_IMAGE .
    Set-Location ..
    Write-ColorOutput Green "✓ Образ успешно собран!"
}

function Create-KindCluster {
    Write-ColorOutput Green "=== Создание Kind кластера ==="
    
    # Проверяем, существует ли кластер
    $existingCluster = kind get clusters | Select-String -Pattern $CLUSTER_NAME
    if ($existingCluster) {
        Write-ColorOutput Yellow "Кластер уже существует, пересоздаем..."
        kind delete cluster --name $CLUSTER_NAME
    }
    
    kind create cluster --name $CLUSTER_NAME --config=src/kind-config.yaml
    Write-ColorOutput Green "✓ Kind кластер создан!"
    
    # Ждем готовности кластера
    Write-ColorOutput Yellow "Ожидание готовности кластера..."
    Start-Sleep -Seconds 10
}

function Load-ImageToKind {
    Write-ColorOutput Green "=== Загрузка образа в Kind ==="
    kind load docker-image $DOCKER_IMAGE --name $CLUSTER_NAME
    Write-ColorOutput Green "✓ Образ загружен в Kind!"
}

function Deploy-Application {
    Write-ColorOutput Green "=== Деплой приложения через Helm ==="
    
    # Устанавливаем через Helm
    helm upgrade --install web08 ./src/helm/web08 --create-namespace --wait --timeout 5m
    
    Write-ColorOutput Green "✓ Приложение успешно развернуто!"
}

function Test-Application {
    Write-ColorOutput Green "=== Smoke-тестирование ==="
    
    # Ждем готовности подов
    Write-ColorOutput Yellow "Ожидание готовности подов..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=web08 -n $NAMESPACE --timeout=120s
    
    Write-ColorOutput Yellow "`nПроверка health endpoint:"
    kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- curl -s http://net-as63-220012-v8:8094/health
    
    Write-ColorOutput Yellow "`nПроверка ready endpoint:"
    kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- curl -s http://net-as63-220012-v8:8094/ready
    
    Write-ColorOutput Yellow "`nПроверка info endpoint:"
    kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $NAMESPACE -- curl -s http://net-as63-220012-v8:8094/info
    
    Write-ColorOutput Green "`n✓ Smoke-тесты завершены!"
}

function Show-Status {
    Write-ColorOutput Green "=== Статус ресурсов ==="
    
    Write-ColorOutput Yellow "`nNamespaces:"
    kubectl get namespaces | Select-String -Pattern $NAMESPACE
    
    Write-ColorOutput Yellow "`nPods:"
    kubectl get pods -n $NAMESPACE -o wide
    
    Write-ColorOutput Yellow "`nServices:"
    kubectl get svc -n $NAMESPACE
    
    Write-ColorOutput Yellow "`nDeployments:"
    kubectl get deployments -n $NAMESPACE
    
    Write-ColorOutput Yellow "`nConfigMaps:"
    kubectl get configmaps -n $NAMESPACE
    
    Write-ColorOutput Yellow "`nSecrets:"
    kubectl get secrets -n $NAMESPACE
}

function Show-Logs {
    Write-ColorOutput Green "=== Логи приложения ==="
    kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=web08 --tail=100
}

function Clean-All {
    Write-ColorOutput Yellow "=== Очистка ресурсов ==="
    
    # Удаляем Helm release
    helm uninstall web08 -n $NAMESPACE 2>$null
    
    # Удаляем namespace
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    
    # Удаляем Kind кластер
    kind delete cluster --name $CLUSTER_NAME
    
    Write-ColorOutput Green "✓ Все ресурсы удалены!"
}

function Full-Setup {
    Write-ColorOutput Green "=== ПОЛНАЯ УСТАНОВКА ==="
    Write-ColorOutput Yellow "Студент: Козловская Анна Геннадьевна"
    Write-ColorOutput Yellow "Группа: АС-63, StudentID: 220012, Вариант: 8"
    Write-ColorOutput Yellow ""
    
    Build-DockerImage
    Create-KindCluster
    Load-ImageToKind
    Deploy-Application
    Show-Status
    Test-Application
    
    Write-ColorOutput Green "`n=== УСТАНОВКА ЗАВЕРШЕНА ==="
    Write-ColorOutput Yellow "`nДля доступа к приложению выполните:"
    Write-ColorOutput Cyan "kubectl port-forward -n $NAMESPACE svc/net-as63-220012-v8 8094:8094"
    Write-ColorOutput Yellow "Затем откройте в браузере: http://localhost:8094"
}

# Главная логика
switch ($Action) {
    "setup" { Full-Setup }
    "build" { Build-DockerImage }
    "deploy" { Deploy-Application }
    "test" { Test-Application }
    "status" { Show-Status }
    "logs" { Show-Logs }
    "clean" { Clean-All }
    default { 
        Write-ColorOutput Red "Неизвестное действие: $Action"
        Write-ColorOutput Yellow "Доступные действия: setup, build, deploy, test, status, logs, clean"
    }
}
