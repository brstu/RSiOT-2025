#!/bin/bash
# Скрипт установки kube-prometheus-stack
# Студент: Козловская Анна Геннадьевна, АС-63, 220012

set -e

echo "=== Установка kube-prometheus-stack ==="

# Добавление Helm репозитория
echo "1. Добавление Helm репозитория prometheus-community..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Создание namespace для мониторинга
echo "2. Создание namespace monitoring..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Установка kube-prometheus-stack
echo "3. Установка kube-prometheus-stack..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.retention=7d \
  --set grafana.adminPassword=admin \
  --wait

echo ""
echo "=== Установка завершена! ==="
echo ""
echo "Для доступа к компонентам используйте port-forward:"
echo ""
echo "Prometheus:"
echo "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo "  URL: http://localhost:9090"
echo ""
echo "Grafana (admin/admin):"
echo "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "  URL: http://localhost:3000"
echo ""
echo "Alertmanager:"
echo "  kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093"
echo "  URL: http://localhost:9093"
echo ""
