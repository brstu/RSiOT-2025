#!/bin/bash
# Инструкции по установке kube-prometheus-stack

# 1. Добавить Helm репозиторий
# helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm repo update

# 2. Создать namespace для мониторинга
# kubectl create namespace monitoring

# 3. Установить kube-prometheus-stack
# helm install prometheus prometheus-community/kube-prometheus-stack \
#   --namespace monitoring

# 4. Проверить статус установки
# kubectl get pods -n monitoring

# 5. Получить доступ к Grafana (port-forward)
# kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
