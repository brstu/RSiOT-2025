#!/bin/bash
# Installation script for kube-prometheus-stack
# Student: Логинов Глеб Олегович (AS-63-220018-v14)

set -e

MONITORING_NAMESPACE="monitoring"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/kube-prometheus-stack-values.yaml"

echo "==================================="
echo "Installing kube-prometheus-stack"
echo "Student: AS-63-220018-v14"
echo "==================================="

# Add Prometheus Community Helm repository
echo "Adding Prometheus Community Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "Creating namespace: ${MONITORING_NAMESPACE}"
kubectl create namespace ${MONITORING_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Label the namespace
kubectl label namespace ${MONITORING_NAMESPACE} \
  org.bstu.student.id="220018" \
  org.bstu.group="AS-63" \
  org.bstu.variant="14" \
  org.bstu.course="RSIOT" \
  --overwrite

# Install kube-prometheus-stack
echo "Installing kube-prometheus-stack..."
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace ${MONITORING_NAMESPACE} \
  --values "${VALUES_FILE}" \
  --wait \
  --timeout 10m

echo ""
echo "==================================="
echo "Installation completed successfully!"
echo "==================================="
echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=prometheus \
  -n ${MONITORING_NAMESPACE} \
  --timeout=300s || true

echo ""
echo "==================================="
echo "Access Information:"
echo "==================================="
echo ""
echo "Prometheus UI:"
echo "  kubectl port-forward -n ${MONITORING_NAMESPACE} svc/kube-prometheus-stack-prometheus 9090:9090"
echo "  Then open: http://localhost:9090"
echo ""
echo "Grafana UI:"
echo "  kubectl port-forward -n ${MONITORING_NAMESPACE} svc/kube-prometheus-stack-grafana 3000:80"
echo "  Then open: http://localhost:3000"
echo "  Username: admin"
echo "  Password: prom-operator"
echo ""
echo "Alertmanager UI:"
echo "  kubectl port-forward -n ${MONITORING_NAMESPACE} svc/kube-prometheus-stack-alertmanager 9093:9093"
echo "  Then open: http://localhost:9093"
echo ""
echo "==================================="
echo "Verify installation:"
echo "==================================="
echo "kubectl get pods -n ${MONITORING_NAMESPACE}"
echo "kubectl get svc -n ${MONITORING_NAMESPACE}"
echo ""
