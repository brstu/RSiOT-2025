#!/bin/bash
# ArgoCD installation script
# Student: Логинов Глеб Олегович (AS-63-220018-v14)

set -e

ARGOCD_NAMESPACE="argocd"

echo "==================================="
echo "Installing Argo CD"
echo "Student: AS-63-220018-v14"
echo "==================================="

# Create namespace for ArgoCD
echo "Creating namespace: ${ARGOCD_NAMESPACE}"
kubectl create namespace ${ARGOCD_NAMESPACE} || true

# Label the namespace
kubectl label namespace ${ARGOCD_NAMESPACE} \
  org.bstu.student.id="220018" \
  org.bstu.group="AS-63" \
  org.bstu.variant="14" \
  org.bstu.course="RSIOT" \
  --overwrite

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n ${ARGOCD_NAMESPACE} -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=available --timeout=600s \
  deployment/argocd-server -n ${ARGOCD_NAMESPACE} || true

echo ""
echo "==================================="
echo "ArgoCD Installation completed!"
echo "==================================="
echo ""
echo "Getting initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Password retrieval failed")

echo ""
echo "==================================="
echo "Access Information:"
echo "==================================="
echo ""
echo "ArgoCD UI:"
echo "  kubectl port-forward svc/argocd-server -n ${ARGOCD_NAMESPACE} 8080:443"
echo "  Then open: https://localhost:8080"
echo ""
echo "Login credentials:"
echo "  Username: admin"
echo "  Password: ${ARGOCD_PASSWORD}"
echo ""
echo "Note: Accept the self-signed certificate warning in your browser"
echo ""
echo "==================================="
echo "Verify installation:"
echo "==================================="
echo "kubectl get pods -n ${ARGOCD_NAMESPACE}"
echo ""
