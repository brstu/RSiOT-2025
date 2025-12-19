# Makefile для Lab02
# Для Windows используйте PowerShell или Git Bash

IMAGE_NAME := alexsandro007/rsiot-lab02
IMAGE_TAG := v1.0
NAMESPACE := app23
HOST := web23.local

.PHONY: help
help: ## Показать справку
	@echo "Available commands:"
	@echo "  make build         - Собрать Docker образ"
	@echo "  make push          - Отправить образ в Docker Hub"
	@echo "  make test-local    - Тестировать образ локально"
	@echo "  make minikube-start - Запустить Minikube"
	@echo "  make deploy        - Задеплоить в Kubernetes"
	@echo "  make test          - Протестировать deployment"
	@echo "  make update        - Rolling update"
	@echo "  make logs          - Показать логи"
	@echo "  make clean         - Очистить ресурсы"
	@echo "  make all           - Полный цикл (build + deploy)"

.PHONY: build
build: ## Собрать Docker образ
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "Image size:"
	@docker images $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: push
push: ## Отправить образ в Docker Hub
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test-local
test-local: ## Тестировать образ локально
	docker run -d -p 8043:8043 \
		-e STU_ID=14 \
		-e STU_GROUP=АС-64 \
		-e STU_VARIANT=23 \
		--name rsiot-test \
		$(IMAGE_NAME):$(IMAGE_TAG)
	@echo "Waiting for container to start..."
	@sleep 3
	@echo "Testing endpoints..."
	@curl -s http://localhost:8043/ready
	@echo ""
	@curl -s http://localhost:8043/live
	@echo ""
	@echo "Logs:"
	@docker logs rsiot-test
	@echo ""
	@echo "Cleaning up..."
	@docker stop rsiot-test
	@docker rm rsiot-test

.PHONY: minikube-start
minikube-start: ## Запустить Minikube с Ingress
	minikube start --driver=docker
	minikube addons enable ingress
	kubectl wait --namespace ingress-nginx \
		--for=condition=ready pod \
		--selector=app.kubernetes.io/component=controller \
		--timeout=120s
	@echo "Minikube IP: $$(minikube ip)"
	@echo "Add to hosts: $$(minikube ip) $(HOST)"

.PHONY: deploy
deploy: ## Задеплоить в Kubernetes
	kubectl apply -f k8s/
	kubectl wait --namespace $(NAMESPACE) \
		--for=condition=available \
		--selector=app=web23 \
		deployment \
		--timeout=120s
	@echo "Deployment complete!"
	@kubectl get all -n $(NAMESPACE)

.PHONY: test
test: ## Протестировать deployment
	@echo "Testing pods..."
	@kubectl get pods -n $(NAMESPACE) -l app=web23
	@echo ""
	@echo "Testing endpoints..."
	@curl -s -o /dev/null -w "Main page: %{http_code}\n" http://$(HOST)/
	@curl -s -o /dev/null -w "Readiness: %{http_code}\n" http://$(HOST)/ready
	@curl -s -o /dev/null -w "Liveness: %{http_code}\n" http://$(HOST)/live

.PHONY: update
update: ## Rolling update
	@read -p "Enter new image tag: " TAG; \
	kubectl set image deployment/app-web23 web=$(IMAGE_NAME):$$TAG -n $(NAMESPACE)
	kubectl rollout status deployment/app-web23 -n $(NAMESPACE)
	kubectl rollout history deployment/app-web23 -n $(NAMESPACE)

.PHONY: logs
logs: ## Показать логи
	kubectl logs -n $(NAMESPACE) -l app=web23 --tail=50 --all-containers=true

.PHONY: status
status: ## Показать статус всех ресурсов
	@echo "=== Namespace ==="
	@kubectl get namespace $(NAMESPACE)
	@echo ""
	@echo "=== Pods ==="
	@kubectl get pods -n $(NAMESPACE)
	@echo ""
	@echo "=== Services ==="
	@kubectl get svc -n $(NAMESPACE)
	@echo ""
	@echo "=== Ingress ==="
	@kubectl get ingress -n $(NAMESPACE)
	@echo ""
	@echo "=== ConfigMap ==="
	@kubectl get configmap -n $(NAMESPACE)

.PHONY: clean
clean: ## Очистить ресурсы
	kubectl delete namespace $(NAMESPACE) --ignore-not-found=true
	@echo "Resources cleaned up!"

.PHONY: kustomize-dev
kustomize-dev: ## Deploy с Kustomize (dev окружение)
	@echo "🚀 Deploying with Kustomize (development)..."
	kubectl apply -k kustomize/overlays/development/
	@echo "✅ Development deployment complete!"

.PHONY: kustomize-prod
kustomize-prod: ## Deploy с Kustomize (production окружение)
	@echo "🚀 Deploying with Kustomize (production)..."
	kubectl apply -k kustomize/overlays/production/
	kubectl rollout status deployment/app-web23 -n $(NAMESPACE)
	@echo "✅ Production deployment complete!"

.PHONY: pvc-test
pvc-test: ## Тест персистентности данных
	@echo "🔍 Testing PVC persistence..."
	@POD=$$(kubectl get pod -n $(NAMESPACE) -l app=web23 -o jsonpath='{.items[0].metadata.name}'); \
	echo "Writing test data to pod: $$POD"; \
	kubectl exec -n $(NAMESPACE) $$POD -- sh -c 'mkdir -p /app/data && echo "Test at $$(date)" > /app/data/test.txt'; \
	echo "Reading data..."; \
	kubectl exec -n $(NAMESPACE) $$POD -- cat /app/data/test.txt; \
	echo "Deleting pod..."; \
	kubectl delete pod -n $(NAMESPACE) $$POD; \
	echo "Waiting for new pod..."; \
	sleep 20; \
	NEW_POD=$$(kubectl get pod -n $(NAMESPACE) -l app=web23 -o jsonpath='{.items[0].metadata.name}'); \
	echo "Reading from new pod: $$NEW_POD"; \
	kubectl exec -n $(NAMESPACE) $$NEW_POD -- cat /app/data/test.txt; \
	echo "✅ PVC persistence verified!"

.PHONY: all
all: build push minikube-start deploy test ## Полный цикл развертывания
	@echo "Full deployment complete!"
	@echo "Access: http://$(HOST)/"
