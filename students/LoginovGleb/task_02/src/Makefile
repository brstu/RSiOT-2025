# Makefile для автоматизации деплоя и тестирования Kubernetes приложения
# Лабораторная работа №2 - Вариант 14

# Переменные
IMAGE_NAME = gleb7499/lab1-v14
IMAGE_TAG = stu-220018-v14
NAMESPACE = app14
DEPLOYMENT_NAME = web14
KIND_CLUSTER_NAME = lab2
KUSTOMIZE_DIR = k8s

# Цвета для вывода
COLOR_RESET = \033[0m
COLOR_BOLD = \033[1m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m
COLOR_BLUE = \033[34m

.PHONY: help
help: ## Показать справку по командам
	@echo "$(COLOR_BOLD)Доступные команды:$(COLOR_RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(COLOR_GREEN)%-20s$(COLOR_RESET) %s\n", $$1, $$2}'

# ============================================
# Docker операции
# ============================================

.PHONY: docker-build
docker-build: ## Собрать Docker образ
	@echo "$(COLOR_BLUE)Сборка Docker образа $(IMAGE_NAME):$(IMAGE_TAG)...$(COLOR_RESET)"
	cd app && docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "$(COLOR_GREEN)✓ Образ успешно собран$(COLOR_RESET)"

.PHONY: docker-push
docker-push: ## Отправить образ в Docker Hub
	@echo "$(COLOR_BLUE)Отправка образа в Docker Hub...$(COLOR_RESET)"
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "$(COLOR_GREEN)✓ Образ отправлен в реестр$(COLOR_RESET)"

.PHONY: docker-run
docker-run: ## Запустить контейнер локально для тестирования
	@echo "$(COLOR_BLUE)Запуск контейнера локально на порту 8062...$(COLOR_RESET)"
	docker run -d -p 8062:8062 --name test-web14 $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "$(COLOR_GREEN)✓ Контейнер запущен. Проверьте: curl http://localhost:8062/healthz$(COLOR_RESET)"

.PHONY: docker-stop
docker-stop: ## Остановить и удалить тестовый контейнер
	@echo "$(COLOR_BLUE)Остановка тестового контейнера...$(COLOR_RESET)"
	docker stop test-web14 2>/dev/null || true
	docker rm test-web14 2>/dev/null || true
	@echo "$(COLOR_GREEN)✓ Контейнер остановлен и удален$(COLOR_RESET)"

.PHONY: docker-logs
docker-logs: ## Показать логи контейнера
	docker logs test-web14

.PHONY: docker-test
docker-test: docker-build docker-run ## Собрать и запустить контейнер для теста
	@echo "$(COLOR_YELLOW)Ожидание запуска приложения (5 сек)...$(COLOR_RESET)"
	@sleep 5
	@echo "$(COLOR_BLUE)Тестирование endpoints...$(COLOR_RESET)"
	@curl -s http://localhost:8062/healthz | jq . || echo "jq не установлен - показываем raw ответ: $$(curl -s http://localhost:8062/healthz)"
	@echo ""
	@curl -s http://localhost:8062/ | jq . || echo "jq не установлен"
	@$(MAKE) docker-stop

# ============================================
# Kind операции
# ============================================

.PHONY: kind-create
kind-create: ## Создать Kind кластер
	@echo "$(COLOR_BLUE)Создание Kind кластера $(KIND_CLUSTER_NAME)...$(COLOR_RESET)"
	kind create cluster --name $(KIND_CLUSTER_NAME)
	@echo "$(COLOR_GREEN)✓ Кластер создан$(COLOR_RESET)"

.PHONY: kind-delete
kind-delete: ## Удалить Kind кластер
	@echo "$(COLOR_BLUE)Удаление Kind кластера...$(COLOR_RESET)"
	kind delete cluster --name $(KIND_CLUSTER_NAME)
	@echo "$(COLOR_GREEN)✓ Кластер удален$(COLOR_RESET)"

.PHONY: kind-load
kind-load: docker-build ## Загрузить образ в Kind кластер
	@echo "$(COLOR_BLUE)Загрузка образа в Kind кластер...$(COLOR_RESET)"
	kind load docker-image $(IMAGE_NAME):$(IMAGE_TAG) --name $(KIND_CLUSTER_NAME)
	@echo "$(COLOR_GREEN)✓ Образ загружен в кластер$(COLOR_RESET)"

.PHONY: kind-deploy
kind-deploy: kind-load ## Развернуть приложение в Kind
	@echo "$(COLOR_BLUE)Применение манифестов через Kustomize...$(COLOR_RESET)"
	kubectl apply -k $(KUSTOMIZE_DIR)
	@echo "$(COLOR_GREEN)✓ Манифесты применены$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Ожидание готовности подов...$(COLOR_RESET)"
	kubectl wait --for=condition=ready pod -l app=web14 -n $(NAMESPACE) --timeout=120s || true
	@$(MAKE) status

.PHONY: kind-full
kind-full: kind-create kind-deploy ## Полный цикл: создать кластер и развернуть приложение
	@echo "$(COLOR_GREEN)✓ Kind кластер полностью настроен и приложение развернуто$(COLOR_RESET)"

# ============================================
# Minikube операции
# ============================================

.PHONY: minikube-start
minikube-start: ## Запустить Minikube
	@echo "$(COLOR_BLUE)Запуск Minikube...$(COLOR_RESET)"
	minikube start --driver=docker
	minikube addons enable ingress
	@echo "$(COLOR_GREEN)✓ Minikube запущен и Ingress включен$(COLOR_RESET)"

.PHONY: minikube-stop
minikube-stop: ## Остановить Minikube
	@echo "$(COLOR_BLUE)Остановка Minikube...$(COLOR_RESET)"
	minikube stop
	@echo "$(COLOR_GREEN)✓ Minikube остановлен$(COLOR_RESET)"

.PHONY: minikube-delete
minikube-delete: ## Удалить Minikube кластер
	@echo "$(COLOR_BLUE)Удаление Minikube...$(COLOR_RESET)"
	minikube delete
	@echo "$(COLOR_GREEN)✓ Minikube удален$(COLOR_RESET)"

.PHONY: minikube-load
minikube-load: docker-build ## Загрузить образ в Minikube
	@echo "$(COLOR_BLUE)Загрузка образа в Minikube...$(COLOR_RESET)"
	minikube image load $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "$(COLOR_GREEN)✓ Образ загружен$(COLOR_RESET)"

.PHONY: minikube-deploy
minikube-deploy: minikube-load ## Развернуть приложение в Minikube
	@echo "$(COLOR_BLUE)Применение манифестов...$(COLOR_RESET)"
	kubectl apply -k $(KUSTOMIZE_DIR)
	@echo "$(COLOR_GREEN)✓ Манифесты применены$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Ожидание готовности подов...$(COLOR_RESET)"
	kubectl wait --for=condition=ready pod -l app=web14 -n $(NAMESPACE) --timeout=120s || true
	@$(MAKE) status

.PHONY: minikube-full
minikube-full: minikube-start minikube-deploy ## Полный цикл для Minikube
	@echo "$(COLOR_GREEN)✓ Minikube полностью настроен$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Для доступа через Ingress добавьте в /etc/hosts:$(COLOR_RESET)"
	@echo "$$(minikube ip) web14.local"

# ============================================
# Kubernetes операции
# ============================================

.PHONY: apply
apply: ## Применить манифесты
	@echo "$(COLOR_BLUE)Применение Kubernetes манифестов...$(COLOR_RESET)"
	kubectl apply -k $(KUSTOMIZE_DIR)
	@echo "$(COLOR_GREEN)✓ Манифесты применены$(COLOR_RESET)"

.PHONY: delete
delete: ## Удалить все ресурсы
	@echo "$(COLOR_BLUE)Удаление ресурсов...$(COLOR_RESET)"
	kubectl delete -k $(KUSTOMIZE_DIR) --ignore-not-found=true
	@echo "$(COLOR_GREEN)✓ Ресурсы удалены$(COLOR_RESET)"

.PHONY: status
status: ## Показать статус ресурсов
	@echo "$(COLOR_BOLD)Статус ресурсов в namespace $(NAMESPACE):$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_YELLOW)Pods:$(COLOR_RESET)"
	@kubectl get pods -n $(NAMESPACE) -o wide || echo "Namespace не существует"
	@echo ""
	@echo "$(COLOR_YELLOW)Deployments:$(COLOR_RESET)"
	@kubectl get deployments -n $(NAMESPACE) || true
	@echo ""
	@echo "$(COLOR_YELLOW)Services:$(COLOR_RESET)"
	@kubectl get svc -n $(NAMESPACE) || true
	@echo ""
	@echo "$(COLOR_YELLOW)Ingress:$(COLOR_RESET)"
	@kubectl get ingress -n $(NAMESPACE) || true
	@echo ""
	@echo "$(COLOR_YELLOW)PVC:$(COLOR_RESET)"
	@kubectl get pvc -n $(NAMESPACE) || true

.PHONY: logs
logs: ## Показать логи Flask приложения
	@echo "$(COLOR_BLUE)Логи Flask приложения (последние 50 строк):$(COLOR_RESET)"
	kubectl logs -n $(NAMESPACE) -l app=web14 --tail=50

.PHONY: logs-db
logs-db: ## Показать логи PostgreSQL
	@echo "$(COLOR_BLUE)Логи PostgreSQL (последние 50 строк):$(COLOR_RESET)"
	kubectl logs -n $(NAMESPACE) -l app=postgres-db --tail=50

.PHONY: logs-follow
logs-follow: ## Следить за логами в реальном времени
	kubectl logs -n $(NAMESPACE) -l app=web14 -f

.PHONY: describe
describe: ## Подробная информация о подах
	@echo "$(COLOR_BLUE)Подробная информация о подах web14:$(COLOR_RESET)"
	kubectl describe pod -n $(NAMESPACE) -l app=web14

# ============================================
# Тестирование
# ============================================

.PHONY: port-forward
port-forward: ## Port-forward для локального доступа
	@echo "$(COLOR_BLUE)Port-forward на localhost:8062...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Используйте Ctrl+C для остановки$(COLOR_RESET)"
	kubectl port-forward -n $(NAMESPACE) svc/web14 8062:80

.PHONY: test-health
test-health: ## Тест health endpoint (требуется port-forward)
	@echo "$(COLOR_BLUE)Тестирование /healthz endpoint...$(COLOR_RESET)"
	@curl -s http://localhost:8062/healthz | jq . || curl -s http://localhost:8062/healthz
	@echo ""

.PHONY: test-app
test-app: ## Тест основных endpoints (требуется port-forward)
	@echo "$(COLOR_BLUE)Тестирование endpoints...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)1. Health check:$(COLOR_RESET)"
	@curl -s http://localhost:8062/healthz | jq . || curl -s http://localhost:8062/healthz
	@echo ""
	@echo "$(COLOR_YELLOW)2. Main page:$(COLOR_RESET)"
	@curl -s http://localhost:8062/ | jq . || curl -s http://localhost:8062/
	@echo ""
	@echo "$(COLOR_YELLOW)3. Echo endpoint:$(COLOR_RESET)"
	@curl -s -X POST http://localhost:8062/echo -H "Content-Type: application/json" -d '{"test":"hello","variant":14}' | jq . || curl -s -X POST http://localhost:8062/echo -H "Content-Type: application/json" -d '{"test":"hello"}'
	@echo ""

.PHONY: smoke-test
smoke-test: ## Полный smoke test (в отдельном терминале должен быть port-forward)
	@echo "$(COLOR_BOLD)Запуск smoke tests...$(COLOR_RESET)"
	@echo ""
	@$(MAKE) test-app
	@echo ""
	@echo "$(COLOR_GREEN)✓ Smoke tests завершены$(COLOR_RESET)"

# ============================================
# Rolling Update
# ============================================

.PHONY: rolling-update
rolling-update: ## Симуляция rolling update
	@echo "$(COLOR_BLUE)Запуск rolling update...$(COLOR_RESET)"
	kubectl set image deployment/$(DEPLOYMENT_NAME) $(DEPLOYMENT_NAME)=$(IMAGE_NAME):$(IMAGE_TAG) -n $(NAMESPACE)
	@echo "$(COLOR_YELLOW)Наблюдение за процессом обновления...$(COLOR_RESET)"
	kubectl rollout status deployment/$(DEPLOYMENT_NAME) -n $(NAMESPACE)
	@echo "$(COLOR_GREEN)✓ Rolling update завершен$(COLOR_RESET)"

.PHONY: rollout-history
rollout-history: ## История обновлений
	@echo "$(COLOR_BLUE)История обновлений deployment:$(COLOR_RESET)"
	kubectl rollout history deployment/$(DEPLOYMENT_NAME) -n $(NAMESPACE)

.PHONY: rollout-undo
rollout-undo: ## Откатить последнее обновление
	@echo "$(COLOR_BLUE)Откат последнего обновления...$(COLOR_RESET)"
	kubectl rollout undo deployment/$(DEPLOYMENT_NAME) -n $(NAMESPACE)
	kubectl rollout status deployment/$(DEPLOYMENT_NAME) -n $(NAMESPACE)
	@echo "$(COLOR_GREEN)✓ Откат выполнен$(COLOR_RESET)"

# ============================================
# Утилиты
# ============================================

.PHONY: shell
shell: ## Открыть shell в поде приложения
	@echo "$(COLOR_BLUE)Открытие shell в поде...$(COLOR_RESET)"
	kubectl exec -it -n $(NAMESPACE) $$(kubectl get pod -n $(NAMESPACE) -l app=web14 -o jsonpath='{.items[0].metadata.name}') -- sh

.PHONY: shell-db
shell-db: ## Открыть psql в PostgreSQL поде
	@echo "$(COLOR_BLUE)Открытие psql в PostgreSQL...$(COLOR_RESET)"
	kubectl exec -it -n $(NAMESPACE) $$(kubectl get pod -n $(NAMESPACE) -l app=postgres-db -o jsonpath='{.items[0].metadata.name}') -- psql -U app_user -d app_220018_v14

.PHONY: events
events: ## Показать события в namespace
	@echo "$(COLOR_BLUE)События в namespace $(NAMESPACE):$(COLOR_RESET)"
	kubectl get events -n $(NAMESPACE) --sort-by='.lastTimestamp'

.PHONY: validate
validate: ## Валидация манифестов
	@echo "$(COLOR_BLUE)Валидация Kubernetes манифестов...$(COLOR_RESET)"
	kubectl apply -k $(KUSTOMIZE_DIR) --dry-run=client
	@echo "$(COLOR_GREEN)✓ Манифесты валидны$(COLOR_RESET)"

.PHONY: clean
clean: delete docker-stop ## Полная очистка (удалить ресурсы и контейнеры)
	@echo "$(COLOR_GREEN)✓ Очистка завершена$(COLOR_RESET)"

.PHONY: reset-kind
reset-kind: kind-delete kind-full ## Пересоздать Kind кластер с нуля
	@echo "$(COLOR_GREEN)✓ Kind кластер пересоздан$(COLOR_RESET)"

.PHONY: reset-minikube
reset-minikube: minikube-delete minikube-full ## Пересоздать Minikube кластер с нуля
	@echo "$(COLOR_GREEN)✓ Minikube пересоздан$(COLOR_RESET)"

# ============================================
# CI/CD
# ============================================

.PHONY: ci-test
ci-test: docker-build validate ## CI тесты (сборка и валидация)
	@echo "$(COLOR_GREEN)✓ CI тесты пройдены$(COLOR_RESET)"

# Установка по умолчанию
.DEFAULT_GOAL := help
