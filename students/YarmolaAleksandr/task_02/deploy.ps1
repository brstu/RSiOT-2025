# Скрипт для быстрого развертывания и тестирования Lab02
# PowerShell script для автоматизации

Write-Host "=== Lab02 Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Функция для проверки команд
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Проверка необходимых инструментов
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (-not (Test-Command "docker")) {
    Write-Host "✗ Docker not found!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker found" -ForegroundColor Green

if (-not (Test-Command "kubectl")) {
    Write-Host "✗ kubectl not found!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ kubectl found" -ForegroundColor Green

if (-not (Test-Command "minikube")) {
    Write-Host "✗ minikube not found!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ minikube found" -ForegroundColor Green

Write-Host ""

# Параметры
$IMAGE_NAME = "alexsandro007/rsiot-lab02"
$IMAGE_TAG = "v1.0"
$NAMESPACE = "app23"
$HOST = "web23.local"

# Меню
Write-Host "Select action:" -ForegroundColor Cyan
Write-Host "1. Build and push Docker image"
Write-Host "2. Start Minikube and enable Ingress"
Write-Host "3. Deploy to Kubernetes"
Write-Host "4. Test deployment"
Write-Host "5. Full deployment (2+3)"
Write-Host "6. Rolling update"
Write-Host "7. Clean up"
Write-Host "8. Show logs"
Write-Host "9. Deploy with Kustomize (dev)"
Write-Host "10. Deploy with Kustomize (prod)"
Write-Host "11. Test PVC persistence"
Write-Host "0. Exit"
Write-Host ""

$choice = Read-Host "Enter choice"

switch ($choice) {
    "1" {
        Write-Host "`n=== Building Docker image ===" -ForegroundColor Cyan
        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
        
        Write-Host "`nImage size:" -ForegroundColor Yellow
        docker images ${IMAGE_NAME}:${IMAGE_TAG}
        
        $push = Read-Host "`nPush to Docker Hub? (y/n)"
        if ($push -eq "y") {
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
            Write-Host "✓ Image pushed" -ForegroundColor Green
        }
    }
    
    "2" {
        Write-Host "`n=== Starting Minikube ===" -ForegroundColor Cyan
        minikube start --driver=docker
        
        Write-Host "`n=== Enabling Ingress ===" -ForegroundColor Cyan
        minikube addons enable ingress
        
        Write-Host "`nWaiting for Ingress controller..."
        kubectl wait --namespace ingress-nginx `
            --for=condition=ready pod `
            --selector=app.kubernetes.io/component=controller `
            --timeout=120s
        
        Write-Host "`nCluster info:" -ForegroundColor Yellow
        kubectl cluster-info
        
        $minikube_ip = minikube ip
        Write-Host "`nMinikube IP: $minikube_ip" -ForegroundColor Green
        Write-Host "Add to hosts file: $minikube_ip $HOST" -ForegroundColor Yellow
    }
    
    "3" {
        Write-Host "`n=== Deploying to Kubernetes ===" -ForegroundColor Cyan
        kubectl apply -f k8s/
        
        Write-Host "`nWaiting for deployment..."
        kubectl wait --namespace $NAMESPACE `
            --for=condition=available `
            --selector=app=web23 `
            deployment `
            --timeout=120s
        
        Write-Host "`n=== Resources ===" -ForegroundColor Yellow
        kubectl get all -n $NAMESPACE
        kubectl get ingress -n $NAMESPACE
        kubectl get configmap -n $NAMESPACE
    }
    
    "4" {
        Write-Host "`n=== Testing Deployment ===" -ForegroundColor Cyan
        
        # Проверка pods
        Write-Host "`nChecking pods..." -ForegroundColor Yellow
        $pods = kubectl get pods -n $NAMESPACE -l app=web23 --no-headers
        Write-Host $pods
        
        # Проверка replicas
        $replica_count = ($pods | Measure-Object).Count
        if ($replica_count -eq 2) {
            Write-Host "✓ Replicas: $replica_count" -ForegroundColor Green
        } else {
            Write-Host "✗ Expected 2 replicas, got: $replica_count" -ForegroundColor Red
        }
        
        # Проверка endpoints
        Write-Host "`nTesting HTTP endpoints..." -ForegroundColor Yellow
        
        try {
            $response = Invoke-WebRequest -Uri "http://${HOST}/" -UseBasicParsing -TimeoutSec 5
            Write-Host "✓ Main page: $($response.StatusCode)" -ForegroundColor Green
        } catch {
            Write-Host "✗ Main page failed: $_" -ForegroundColor Red
        }
        
        try {
            $ready = Invoke-WebRequest -Uri "http://${HOST}/ready" -UseBasicParsing -TimeoutSec 5
            Write-Host "✓ Readiness: $($ready.StatusCode)" -ForegroundColor Green
        } catch {
            Write-Host "✗ Readiness failed: $_" -ForegroundColor Red
        }
        
        try {
            $live = Invoke-WebRequest -Uri "http://${HOST}/live" -UseBasicParsing -TimeoutSec 5
            Write-Host "✓ Liveness: $($live.StatusCode)" -ForegroundColor Green
        } catch {
            Write-Host "✗ Liveness failed: $_" -ForegroundColor Red
        }
        
        Write-Host "`nOpen in browser: http://${HOST}/" -ForegroundColor Cyan
    }
    
    "5" {
        Write-Host "`n=== Full Deployment ===" -ForegroundColor Cyan
        
        # Start Minikube
        Write-Host "`nStarting Minikube..." -ForegroundColor Yellow
        minikube start --driver=docker
        minikube addons enable ingress
        
        # Deploy
        Write-Host "`nDeploying application..." -ForegroundColor Yellow
        kubectl apply -f k8s/
        
        # Wait
        Write-Host "`nWaiting for deployment..."
        kubectl wait --namespace $NAMESPACE `
            --for=condition=available `
            --selector=app=web23 `
            deployment `
            --timeout=120s
        
        # Show status
        kubectl get all -n $NAMESPACE
        
        $minikube_ip = minikube ip
        Write-Host "`n✓ Deployment complete!" -ForegroundColor Green
        Write-Host "Minikube IP: $minikube_ip" -ForegroundColor Cyan
        Write-Host "Add to hosts: $minikube_ip $HOST" -ForegroundColor Yellow
        Write-Host "Then test: http://${HOST}/" -ForegroundColor Cyan
    }
    
    "6" {
        Write-Host "`n=== Rolling Update ===" -ForegroundColor Cyan
        
        $new_tag = Read-Host "Enter new image tag (e.g., v1.1)"
        
        Write-Host "`nUpdating deployment..."
        kubectl set image deployment/app-web23 web=${IMAGE_NAME}:${new_tag} -n $NAMESPACE
        
        Write-Host "`nWatching rollout status..."
        kubectl rollout status deployment/app-web23 -n $NAMESPACE
        
        Write-Host "`nRollout history:"
        kubectl rollout history deployment/app-web23 -n $NAMESPACE
        
        Write-Host "`n✓ Rolling update complete!" -ForegroundColor Green
    }
    
    "7" {
        Write-Host "`n=== Cleaning up ===" -ForegroundColor Cyan
        
        $confirm = Read-Host "Delete all resources in namespace $NAMESPACE? (y/n)"
        if ($confirm -eq "y") {
            kubectl delete namespace $NAMESPACE
            Write-Host "✓ Namespace deleted" -ForegroundColor Green
        }
        
        $stop = Read-Host "Stop Minikube? (y/n)"
        if ($stop -eq "y") {
            minikube stop
            Write-Host "✓ Minikube stopped" -ForegroundColor Green
        }
    }
    
    "8" {
        Write-Host "`n=== Pod Logs ===" -ForegroundColor Cyan
        kubectl logs -n $NAMESPACE -l app=web23 --tail=50 --all-containers=true
    }
    
    "9" {
        Write-Host "`n=== Deploy with Kustomize (Development) ===" -ForegroundColor Cyan
        kubectl apply -k kustomize/overlays/development/
        
        Write-Host "`nWaiting for deployment..."
        kubectl wait --namespace app23-dev `
            --for=condition=available `
            --selector=app=web23 `
            deployment `
            --timeout=120s
        
        Write-Host "`n=== Resources ===" -ForegroundColor Yellow
        kubectl get all -n app23-dev
        
        Write-Host "`n✓ Development deployment complete!" -ForegroundColor Green
    }
    
    "10" {
        Write-Host "`n=== Deploy with Kustomize (Production) ===" -ForegroundColor Cyan
        kubectl apply -k kustomize/overlays/production/
        
        Write-Host "`nWatching rollout status..."
        kubectl rollout status deployment/app-web23 -n $NAMESPACE
        
        Write-Host "`n=== Resources ===" -ForegroundColor Yellow
        kubectl get all -n $NAMESPACE
        
        Write-Host "`n✓ Production deployment complete!" -ForegroundColor Green
    }
    
    "11" {
        Write-Host "`n=== Testing PVC Persistence ===" -ForegroundColor Cyan
        
        # Получить первый pod
        $pod = kubectl get pod -n $NAMESPACE -l app=web23 -o jsonpath='{.items[0].metadata.name}'
        Write-Host "Using pod: $pod" -ForegroundColor Yellow
        
        # Записать данные
        Write-Host "`nWriting test data..."
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        kubectl exec -n $NAMESPACE $pod -- sh -c "mkdir -p /app/data && echo 'Test at $timestamp' > /app/data/test.txt"
        
        # Прочитать данные
        Write-Host "Reading data from current pod..."
        kubectl exec -n $NAMESPACE $pod -- cat /app/data/test.txt
        
        # Удалить pod
        Write-Host "`nDeleting pod $pod..." -ForegroundColor Yellow
        kubectl delete pod -n $NAMESPACE $pod
        
        # Подождать
        Write-Host "Waiting for new pod to start (20 seconds)..."
        Start-Sleep -Seconds 20
        
        # Получить новый pod
        $new_pod = kubectl get pod -n $NAMESPACE -l app=web23 -o jsonpath='{.items[0].metadata.name}'
        Write-Host "`nNew pod: $new_pod" -ForegroundColor Yellow
        
        # Прочитать данные из нового pod
        Write-Host "Reading data from new pod..."
        kubectl exec -n $NAMESPACE $new_pod -- cat /app/data/test.txt
        
        Write-Host "`n✓ PVC persistence verified!" -ForegroundColor Green
    }
    
    "0" {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host "Invalid choice!" -ForegroundColor Red
    }
}

Write-Host "`nDone!" -ForegroundColor Green
