#!/bin/bash
# Скрипт установки Argo CD
# Студент: Козловская Анна Геннадьевна, АС-63, 220012

set -e

echo "=== Установка Argo CD ==="

# Создание namespace для Argo CD
echo "1. Создание namespace argocd..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Установка Argo CD
echo "2. Установка Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Ожидание готовности Argo CD
echo "3. Ожидание готовности подов Argo CD..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Получение пароля администратора
echo ""
echo "=== Argo CD установлен! ==="
echo ""
echo "Получение пароля администратора:"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Логин: admin"
echo "Пароль: $ARGOCD_PASSWORD"
echo ""
echo "Port-forward для доступа к UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  URL: https://localhost:8080"
echo ""
echo "Применение Application манифеста:"
echo "  kubectl apply -f ../argocd/application.yaml"
echo ""
