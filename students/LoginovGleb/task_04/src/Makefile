.PHONY: help install-monitoring build-app deploy-app upgrade-app test-app load-test uninstall clean port-forward-prometheus port-forward-grafana port-forward-alertmanager lint-helm validate-helm

# Variables
NAMESPACE := app-AS-63-220018-v14
RELEASE_NAME := app14-release
HELM_CHART := ./helm/app14-monitoring
MONITORING_NAMESPACE := monitoring
APP_IMAGE := app14-monitoring:latest
DOCKER_BUILD_DIR := ./app

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help:
	@echo "$(GREEN)===================================$(NC)"
	@echo "$(GREEN)Task 04 - Monitoring & Observability$(NC)"
	@echo "$(GREEN)Student: AS-63-220018-v14$(NC)"
	@echo "$(GREEN)===================================$(NC)"
	@echo ""
	@echo "Available commands:"
	@echo "  $(YELLOW)install-monitoring$(NC)      - Install kube-prometheus-stack"
	@echo "  $(YELLOW)build-app$(NC)               - Build Docker image for application"
	@echo "  $(YELLOW)deploy-app$(NC)              - Deploy application via Helm"
	@echo "  $(YELLOW)upgrade-app$(NC)             - Upgrade application deployment"
	@echo "  $(YELLOW)test-app$(NC)                - Test application endpoints"
	@echo "  $(YELLOW)load-test$(NC)               - Generate load for testing alerts"
	@echo "  $(YELLOW)lint-helm$(NC)               - Validate Helm chart"
	@echo "  $(YELLOW)validate-helm$(NC)           - Dry-run Helm install"
	@echo "  $(YELLOW)port-forward-prometheus$(NC) - Port-forward Prometheus UI"
	@echo "  $(YELLOW)port-forward-grafana$(NC)    - Port-forward Grafana UI"
	@echo "  $(YELLOW)port-forward-alertmanager$(NC) - Port-forward Alertmanager UI"
	@echo "  $(YELLOW)uninstall$(NC)               - Remove application"
	@echo "  $(YELLOW)clean$(NC)                   - Clean all resources"
	@echo ""

install-monitoring:
	@echo "$(GREEN)Installing kube-prometheus-stack...$(NC)"
	@chmod +x ./monitoring/install-monitoring.sh
	@./monitoring/install-monitoring.sh
	@echo "$(GREEN)Monitoring stack installed successfully!$(NC)"

build-app:
	@echo "$(GREEN)Building Docker image: $(APP_IMAGE)$(NC)"
	@cd $(DOCKER_BUILD_DIR) && docker build -t $(APP_IMAGE) .
	@echo "$(GREEN)Docker image built successfully!$(NC)"
	@docker images | grep app14-monitoring

deploy-app: lint-helm
	@echo "$(GREEN)Deploying application to namespace: $(NAMESPACE)$(NC)"
	@helm upgrade --install $(RELEASE_NAME) $(HELM_CHART) \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--wait \
		--timeout 5m
	@echo "$(GREEN)Application deployed successfully!$(NC)"
	@kubectl get pods -n $(NAMESPACE)
	@echo ""
	@echo "$(YELLOW)Checking ServiceMonitor and PrometheusRule...$(NC)"
	@kubectl get servicemonitor -n $(NAMESPACE)
	@kubectl get prometheusrule -n $(NAMESPACE)

upgrade-app:
	@echo "$(GREEN)Upgrading application...$(NC)"
	@helm upgrade $(RELEASE_NAME) $(HELM_CHART) \
		--namespace $(NAMESPACE) \
		--wait \
		--timeout 5m
	@echo "$(GREEN)Application upgraded successfully!$(NC)"
	@kubectl get pods -n $(NAMESPACE)

test-app:
	@echo "$(GREEN)Testing application endpoints...$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Testing health endpoint...$(NC)"
	@kubectl run test-health --image=curlimages/curl:latest --rm -it --restart=Never -- \
		curl -s http://app14-release-app14-monitoring.$(NAMESPACE).svc.cluster.local:8000/health || true
	@echo ""
	@echo "$(YELLOW)2. Testing metrics endpoint...$(NC)"
	@kubectl run test-metrics --image=curlimages/curl:latest --rm -it --restart=Never -- \
		curl -s http://app14-release-app14-monitoring.$(NAMESPACE).svc.cluster.local:8000/metrics | head -20 || true
	@echo ""
	@echo "$(YELLOW)3. Testing main endpoint...$(NC)"
	@kubectl run test-main --image=curlimages/curl:latest --rm -it --restart=Never -- \
		curl -s http://app14-release-app14-monitoring.$(NAMESPACE).svc.cluster.local:8000/ || true

load-test:
	@echo "$(GREEN)Generating load for testing alerts...$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Generating normal requests (10 requests)...$(NC)"
	@kubectl run load-gen-ok --image=curlimages/curl:latest --rm -it --restart=Never -- \
		sh -c 'for i in $$(seq 1 10); do curl -s http://app14-release-app14-monitoring.$(NAMESPACE).svc.cluster.local:8000/simulate/ok > /dev/null; echo "Request $$i sent"; sleep 0.5; done' || true
	@echo ""
	@echo "$(YELLOW)2. Generating slow requests (20 requests - will trigger P95 alert)...$(NC)"
	@kubectl run load-gen-slow --image=curlimages/curl:latest --rm -it --restart=Never -- \
		sh -c 'for i in $$(seq 1 20); do curl -s http://app14-release-app14-monitoring.$(NAMESPACE).svc.cluster.local:8000/simulate/slow > /dev/null; echo "Slow request $$i sent"; sleep 0.3; done' || true
	@echo ""
	@echo "$(YELLOW)3. Generating 5xx errors (30 requests - will trigger error rate alert)...$(NC)"
	@kubectl run load-gen-errors --image=curlimages/curl:latest --rm -it --restart=Never -- \
		sh -c 'for i in $$(seq 1 30); do curl -s http://app14-release-app14-monitoring.$(NAMESPACE).svc.cluster.local:8000/simulate/error > /dev/null; echo "Error request $$i sent"; sleep 0.2; done' || true
	@echo ""
	@echo "$(GREEN)Load generation completed!$(NC)"
	@echo "$(YELLOW)Wait 5-10 minutes and check Prometheus alerts:$(NC)"
	@echo "  kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-stack-prometheus 9090:9090"
	@echo "  Then open: http://localhost:9090/alerts"

lint-helm:
	@echo "$(GREEN)Linting Helm chart...$(NC)"
	@helm lint $(HELM_CHART)
	@echo "$(GREEN)Helm chart is valid!$(NC)"

validate-helm:
	@echo "$(GREEN)Validating Helm chart with dry-run...$(NC)"
	@helm template $(RELEASE_NAME) $(HELM_CHART) \
		--namespace $(NAMESPACE) \
		--debug
	@echo "$(GREEN)Helm chart validation passed!$(NC)"

port-forward-prometheus:
	@echo "$(GREEN)Port-forwarding Prometheus UI...$(NC)"
	@echo "Open http://localhost:9090 in your browser"
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-stack-prometheus 9090:9090

port-forward-grafana:
	@echo "$(GREEN)Port-forwarding Grafana UI...$(NC)"
	@echo "Open http://localhost:3000 in your browser"
	@echo "Username: admin"
	@echo "Password: prom-operator"
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-stack-grafana 3000:80

port-forward-alertmanager:
	@echo "$(GREEN)Port-forwarding Alertmanager UI...$(NC)"
	@echo "Open http://localhost:9093 in your browser"
	@kubectl port-forward -n $(MONITORING_NAMESPACE) svc/kube-prometheus-stack-alertmanager 9093:9093

uninstall:
	@echo "$(YELLOW)Uninstalling application...$(NC)"
	@helm uninstall $(RELEASE_NAME) -n $(NAMESPACE) || true
	@kubectl delete namespace $(NAMESPACE) || true
	@echo "$(GREEN)Application uninstalled!$(NC)"

clean:
	@echo "$(YELLOW)Cleaning all resources...$(NC)"
	@helm uninstall $(RELEASE_NAME) -n $(NAMESPACE) || true
	@helm uninstall kube-prometheus-stack -n $(MONITORING_NAMESPACE) || true
	@kubectl delete namespace $(NAMESPACE) || true
	@kubectl delete namespace $(MONITORING_NAMESPACE) || true
	@echo "$(GREEN)All resources cleaned!$(NC)"

# Quick status check
status:
	@echo "$(GREEN)===================================$(NC)"
	@echo "$(GREEN)Current Status$(NC)"
	@echo "$(GREEN)===================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Monitoring Stack:$(NC)"
	@kubectl get pods -n $(MONITORING_NAMESPACE) 2>/dev/null || echo "Not installed"
	@echo ""
	@echo "$(YELLOW)Application:$(NC)"
	@kubectl get pods -n $(NAMESPACE) 2>/dev/null || echo "Not installed"
	@echo ""
	@echo "$(YELLOW)ServiceMonitor:$(NC)"
	@kubectl get servicemonitor -n $(NAMESPACE) 2>/dev/null || echo "Not found"
	@echo ""
	@echo "$(YELLOW)PrometheusRule:$(NC)"
	@kubectl get prometheusrule -n $(NAMESPACE) 2>/dev/null || echo "Not found"

# All-in-one installation
install-all: install-monitoring build-app deploy-app
	@echo "$(GREEN)===================================$(NC)"
	@echo "$(GREEN)Complete installation finished!$(NC)"
	@echo "$(GREEN)===================================$(NC)"
	@echo ""
	@echo "Next steps:"
	@echo "1. Port-forward Prometheus: make port-forward-prometheus"
	@echo "2. Port-forward Grafana: make port-forward-grafana"
	@echo "3. Generate load: make load-test"
	@echo "4. Check alerts in Prometheus UI"
