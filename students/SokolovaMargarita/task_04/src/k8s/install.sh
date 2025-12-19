# Скрипт установки monitoring stack и приложения
# Вариант 19

# Добавить Helm репозиторий
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Установить kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false

# Дождаться готовности
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

# Установить приложение
helm install monitoring-app ./src/helm/monitoring-app \
  --namespace monitoring-app \
  --create-namespace

# Проверить статус
kubectl get all -n monitoring
kubectl get all -n monitoring-app

echo "✅ Установка завершена!"
echo ""
echo "Для доступа к Grafana:"
echo "kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
echo "Login: admin"
echo "Password: $(kubectl get secret monitoring-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 --decode)"
echo ""
echo "Для доступа к Prometheus:"
echo "kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring"
