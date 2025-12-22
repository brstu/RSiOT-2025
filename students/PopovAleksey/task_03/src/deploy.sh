#!/bin/bash
# Скрипт для развертывания в Kubernetes

echo "Применение манифестов Kubernetes..."

kubectl apply -f src/k8s/namespace.yaml
kubectl apply -f src/k8s/secret.yaml
kubectl apply -f src/k8s/pvc.yaml
kubectl apply -f src/k8s/service.yaml
kubectl apply -f src/k8s/statefulset.yaml
kubectl apply -f src/k8s/cronjob-backup.yaml

echo "Проверка статуса подов..."
kubectl get pods -n state-as64-220051-v38

echo "Проверка PVC..."
kubectl get pvc -n state-as64-220051-v38
