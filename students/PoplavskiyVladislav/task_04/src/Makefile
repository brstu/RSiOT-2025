.PHONY: help build push deploy test clean monitor lint

# Переменные
APP_NAME = app17
VERSION = 1.0.0
DOCKER_REGISTRY = your-registry
NAMESPACE = app17-namespace

help:
	@echo "Available commands:"
	@echo "  build     - Build Docker image"
	@echo "  run       - Run locally with Docker Compose"
	@echo "  deploy    - Deploy to Kubernetes"
	@echo "  test      - Run tests"
	@echo "  monitor   - Open monitoring dashboards"
	@echo "  clean     - Clean up resources"
	@echo "  lint      - Lint Python code"

build:
	docker build -t $(APP_NAME):$(VERSION) -f docker/Dockerfile .
	docker tag $(APP_NAME):$(VERSION) $(APP_NAME):latest

run:
	docker-compose up --build

deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/app/namespace.yaml
	kubectl apply -f k8s/app/deployment.yaml
	kubectl apply -f k8s/app/service.yaml
	kubectl apply -f k8s/app/servicemonitor.yaml
	kubectl apply -f k8s/app/prometheusrule.yaml
	@echo "Deployment completed!"

test:
	@echo "Running tests..."
	curl http://localhost:8000/health
	curl http://localhost:8000/metrics
	@echo "Tests completed!"

monitor:
	@echo "Opening monitoring dashboards..."
	@echo "Grafana: http://localhost:3000 (admin/admin)"
	@echo "Prometheus: http://localhost:9090"
	@echo "App: http://localhost:8000"

clean:
	@echo "Cleaning up..."
	docker-compose down -v
	kubectl delete -f k8s/app/ --ignore-not-found=true
	@echo "Cleanup completed!"

lint:
	@echo "Linting Python code..."
	pylint src/*.py
	@echo "Linting completed!"

# Helm commands
helm-install:
	helm install app17-release ./helm/app17-chart -n $(NAMESPACE) --create-namespace

helm-upgrade:
	helm upgrade app17-release ./helm/app17-chart -n $(NAMESPACE)

helm-uninstall:
	helm uninstall app17-release -n $(NAMESPACE)

# Port forwarding
port-forward:
	@echo "Setting up port forwarding..."
	@echo "App: localhost:8000"
	@echo "Prometheus: localhost:9090"
	@echo "Grafana: localhost:3000"
	kubectl port-forward -n $(NAMESPACE) service/app17-service 8000:80 &
	kubectl port-forward -n monitoring service/kube-prometheus-stack-prometheus 9090:9090 &
	kubectl port-forward -n monitoring service/kube-prometheus-stack-grafana 3000:80 &

load-test:
	@echo "Running load test..."
	ab -n 1000 -c 10 http://localhost:8000/
	@echo "Load test completed!"

generate-traffic:
	@echo "Generating traffic for testing alerts..."
	while true; do curl -s http://localhost:8000/ > /dev/null; sleep 0.1; done