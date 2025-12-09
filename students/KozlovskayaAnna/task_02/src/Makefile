# Makefile для автоматизации деплоя - Лабораторная работа №02
# Студент: Козловская Анна Геннадьевна, Группа: АС-63, Вариант: 8

# Переменные
DOCKER_IMAGE = annkrq/web08
DOCKER_TAG = latest
NAMESPACE = app08
HELM_RELEASE = web08
CLUSTER_NAME = lab02-cluster

# Цвета для вывода
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help
help: ## Показать справку по всем командам
	@echo "$(GREEN)Доступные команды:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

.PHONY: all
all: build push deploy ## Полный цикл: сборка, push и деплой

.PHONY: build
build: ## Собрать Docker образ
	@echo "$(GREEN)Сборка Docker образа...$(NC)"
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) ./src
	@echo "$(GREEN)Образ успешно собран!$(NC)"

.PHONY: push
push: ## Загрузить образ в Docker Hub (требуется docker login)
	@echo "$(GREEN)Загрузка образа в Docker Hub...$(NC)"
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	@echo "$(GREEN)Образ успешно загружен!$(NC)"

.PHONY: kind-create
kind-create: ## Создать Kind кластер
	@echo "$(GREEN)Создание Kind кластера...$(NC)"
	kind create cluster --name $(CLUSTER_NAME) --config=./src/kind-config.yaml || true
	@echo "$(GREEN)Kind кластер создан!$(NC)"

.PHONY: kind-delete
kind-delete: ## Удалить Kind кластер
	@echo "$(YELLOW)Удаление Kind кластера...$(NC)"
	kind delete cluster --name $(CLUSTER_NAME)
	@echo "$(GREEN)Kind кластер удален!$(NC)"

.PHONY: kind-load
kind-load: ## Загрузить образ в Kind кластер
	@echo "$(GREEN)Загрузка образа в Kind...$(NC)"
	kind load docker-image $(DOCKER_IMAGE):$(DOCKER_TAG) --name $(CLUSTER_NAME)
	@echo "$(GREEN)Образ загружен в Kind!$(NC)"

.PHONY: deploy-k8s
deploy-k8s: ## Деплой через kubectl (обычные манифесты)
	@echo "$(GREEN)Применение Kubernetes манифестов...$(NC)"
	kubectl apply -f ./src/k8s/namespace.yaml
	kubectl apply -f ./src/k8s/configmap.yaml
	kubectl apply -f ./src/k8s/secret.yaml
	kubectl apply -f ./src/k8s/deployment.yaml
	kubectl apply -f ./src/k8s/service.yaml
	@echo "$(GREEN)Манифесты применены!$(NC)"

.PHONY: deploy-helm
deploy-helm: ## Деплой через Helm
	@echo "$(GREEN)Установка через Helm...$(NC)"
	helm upgrade --install $(HELM_RELEASE) ./src/helm/web08 --create-namespace
	@echo "$(GREEN)Helm chart установлен!$(NC)"

.PHONY: deploy
deploy: deploy-helm ## Деплой приложения (по умолчанию через Helm)

.PHONY: undeploy-k8s
undeploy-k8s: ## Удалить деплой (kubectl)
	@echo "$(YELLOW)Удаление ресурсов kubectl...$(NC)"
	kubectl delete -f ./src/k8s/ --ignore-not-found=true
	@echo "$(GREEN)Ресурсы удалены!$(NC)"

.PHONY: undeploy-helm
undeploy-helm: ## Удалить деплой (Helm)
	@echo "$(YELLOW)Удаление Helm release...$(NC)"
	helm uninstall $(HELM_RELEASE) -n $(NAMESPACE) || true
	kubectl delete namespace $(NAMESPACE) --ignore-not-found=true
	@echo "$(GREEN)Helm release удален!$(NC)"

.PHONY: undeploy
undeploy: undeploy-helm ## Удалить деплой (по умолчанию Helm)

.PHONY: status
status: ## Показать статус ресурсов
	@echo "$(GREEN)Проверка статуса ресурсов...$(NC)"
	@echo "\n$(YELLOW)Pods:$(NC)"
	kubectl get pods -n $(NAMESPACE)
	@echo "\n$(YELLOW)Services:$(NC)"
	kubectl get svc -n $(NAMESPACE)
	@echo "\n$(YELLOW)Deployments:$(NC)"
	kubectl get deployments -n $(NAMESPACE)
	@echo "\n$(YELLOW)ConfigMaps:$(NC)"
	kubectl get configmaps -n $(NAMESPACE)
	@echo "\n$(YELLOW)Secrets:$(NC)"
	kubectl get secrets -n $(NAMESPACE)

.PHONY: logs
logs: ## Показать логи подов
	@echo "$(GREEN)Логи подов:$(NC)"
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/name=web08 --tail=50 --follow

.PHONY: test
test: ## Провести smoke-тест приложения
	@echo "$(GREEN)Запуск smoke-тестов...$(NC)"
	@echo "\n$(YELLOW)Проверка health endpoint:$(NC)"
	kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $(NAMESPACE) -- \
		curl -s http://net-as63-220012-v8:8094/health | grep -o "healthy" && echo "$(GREEN)✓ Health check OK$(NC)" || echo "$(RED)✗ Health check FAILED$(NC)"
	@echo "\n$(YELLOW)Проверка ready endpoint:$(NC)"
	kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $(NAMESPACE) -- \
		curl -s http://net-as63-220012-v8:8094/ready | grep -o "ready" && echo "$(GREEN)✓ Ready check OK$(NC)" || echo "$(RED)✗ Ready check FAILED$(NC)"
	@echo "\n$(YELLOW)Проверка info endpoint:$(NC)"
	kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n $(NAMESPACE) -- \
		curl -s http://net-as63-220012-v8:8094/info
	@echo "$(GREEN)Smoke-тесты завершены!$(NC)"

.PHONY: port-forward
port-forward: ## Проброс порта для локального доступа
	@echo "$(GREEN)Пробрасываем порт 8094...$(NC)"
	@echo "$(YELLOW)Приложение будет доступно по адресу: http://localhost:8094$(NC)"
	kubectl port-forward -n $(NAMESPACE) svc/net-as63-220012-v8 8094:8094

.PHONY: describe
describe: ## Подробная информация о ресурсах
	@echo "$(GREEN)Deployment:$(NC)"
	kubectl describe deployment app-as63-220012-v8 -n $(NAMESPACE)
	@echo "\n$(GREEN)Service:$(NC)"
	kubectl describe service net-as63-220012-v8 -n $(NAMESPACE)
	@echo "\n$(GREEN)Pods:$(NC)"
	kubectl describe pods -n $(NAMESPACE) -l app.kubernetes.io/name=web08

.PHONY: clean
clean: undeploy ## Полная очистка (удалить деплой)

.PHONY: verify
verify: ## Проверить корректность манифестов
	@echo "$(GREEN)Проверка Kubernetes манифестов...$(NC)"
	kubectl apply -f ./src/k8s/ --dry-run=client
	@echo "$(GREEN)Проверка Helm chart...$(NC)"
	helm lint ./src/helm/web08
	@echo "$(GREEN)Все манифесты корректны!$(NC)"

.PHONY: setup-kind
setup-kind: kind-create build kind-load deploy ## Полная настройка Kind кластера

.PHONY: info
info: ## Показать информацию о конфигурации
	@echo "$(GREEN)Конфигурация проекта:$(NC)"
	@echo "  Docker образ: $(DOCKER_IMAGE):$(DOCKER_TAG)"
	@echo "  Namespace: $(NAMESPACE)"
	@echo "  Helm release: $(HELM_RELEASE)"
	@echo "  Kind cluster: $(CLUSTER_NAME)"
	@echo "  StudentID: 220012"
	@echo "  Group: АС-63"
	@echo "  Variant: 8"
