#!/bin/bash

echo "========================================"
echo "Deploying Monitoring Stack - Variant 2"
echo "Student: Выржемковский Даниил Иванович"
echo "Group: AC-63, Variant: 2"
echo "Prefix: app02_, SLO: 99.5%, p95 < 250ms"
echo "========================================"
echo ""

# 1. Install monitoring stack if not exists
if ! kubectl get namespace monitoring > /dev/null 2>&1; then
    echo "1. Installing kube-prometheus-stack..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set grafana.adminPassword=admin123 \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false
else
    echo "1. kube-prometheus-stack already installed"
fi

# 2. Create application namespace
echo ""
echo "2. Creating namespace for app02..."
kubectl apply -f 01-namespace.yaml

# 3. Deploy application
echo ""
echo "3. Deploying app02 application..."
kubectl apply -f 02-serviceaccount.yaml
kubectl apply -f 07-configmap-exporter.yaml
kubectl apply -f 03-deployment.yaml
kubectl apply -f 04-service.yaml
kubectl apply -f 08-deployment-exporter.yaml
kubectl apply -f 09-service-exporter.yaml

# 4. Configure monitoring
echo ""
echo "4. Configuring monitoring..."
kubectl apply -f 05-servicemonitor.yaml
kubectl apply -f 06-prometheusrules.yaml
kubectl apply -f 10-grafana-dashboard.yaml

# Wait for pods to be ready
echo ""
echo "5. Waiting for pods to be ready..."
sleep 30
kubectl get pods -n app02-monitoring

# 6. Verify metrics
echo ""
echo "6. Verifying metrics..."
kubectl apply -f 12-verify-metrics.yaml
sleep 10
echo "Verification job logs:"
kubectl logs -n app02-monitoring job/app02-verify-metrics --tail=50

# 7. Instructions
echo ""
echo "========================================"
echo "DEPLOYMENT COMPLETE"
echo "========================================"
echo ""
echo "Access endpoints:"
echo "1. Grafana:     kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80"
echo "   Credentials: admin / admin123"
echo ""
echo "2. Prometheus:  kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090"
echo ""
echo "3. Application: kubectl port-forward svc/app02-service -n app02-monitoring 8080:80"
echo ""
echo "4. Run load test: kubectl apply -f 11-test-load.yaml"
echo ""
echo "========================================"
echo "Check alerts in Prometheus:"
echo "- AvailabilityBelowSLO (99.5%)"
echo "- HighLatency (p95 > 250ms)"
echo "- HighErrorRate (5xx > 1.5% for 10m)"
echo "========================================"