#!/bin/bash
set -e  # Останавливаться при любой ошибке

echo "=== ЛР04: Установка мониторинга и приложения (вариант 20) ==="

# 1. Добавляем Helm-репозитории (если ещё не добавлены)
echo "Добавляем Helm-репозитории..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

# 2. Установка kube-prometheus-stack в namespace monitoring
echo "Устанавливаем kube-prometheus-stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --wait \
  --timeout 10m \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.adminPassword=admin  # для быстрого доступа, потом можно сменить

echo "kube-prometheus-stack установлен."

# 3. Создаём namespace для приложения (если указан в values.yaml)
APP_NAMESPACE=$(helm -n default show values ./helm/monitoring-app | grep '^namespace:' | awk '{print $2}' || echo "default")
if [ "$APP_NAMESPACE" != "default" ]; then
  echo "Создаём namespace $APP_NAMESPACE..."
  kubectl create namespace "$APP_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
fi

# 4. Установка приложения через Helm-чарт
echo "Устанавливаем приложение (вариант 20)..."
helm upgrade --install app20 ./helm/monitoring-app \
  --namespace "$APP_NAMESPACE" \
  --wait \
  --timeout 10m

echo "Приложение успешно задеплоено."

# 5. Инструкции по доступу
echo ""
echo "=== Доступ к сервисам ==="
echo "Grafana: http://localhost:3000 (login: admin / password: admin)"
echo "   Проброс порта:"
echo "   kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
echo ""
echo "Prometheus: http://localhost:9090"
echo "   Проброс порта:"
echo "   kubectl port-forward svc/monitoring-prometheus-oper-prometheus 9090:9090 -n monitoring"
echo ""
echo "Приложение:"
if kubectl get ingress -n "$APP_NAMESPACE" app20-monitoring-app >/dev/null 2>&1; then
  INGRESS_HOST=$(kubectl get ingress -n "$APP_NAMESPACE" app20-monitoring-app -o jsonpath='{.spec.rules[0].host}')
  echo "   Ingress: http://$INGRESS_HOST"
  echo "   (если ingress не работает локально — добавьте в /etc/hosts: 127.0.0.1 $INGRESS_HOST)"
else
  echo "   Service (ClusterIP):"
  echo "   kubectl port-forward svc/app20-monitoring-app 5000:5000 -n $APP_NAMESPACE"
fi

echo ""
echo "Готово! Теперь можно:"
echo "  • Проверить метрики в Prometheus (поиск app20_)"
echo "  • Импортировать дашборды в Grafana"
echo "  • Нагрузить /error и /slow для срабатывания алертов"