#!/bin/bash
# Скрипт автоматической настройки Kind кластера для лабораторной работы 2
# Вариант 14

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Переменные
CLUSTER_NAME="lab2"
IMAGE_NAME="gleb7499/lab1-v14:stu-220018-v14"
NAMESPACE="app14"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Kind Cluster Setup для ЛР02 (Вариант 14)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Проверка наличия необходимых инструментов
echo -e "${YELLOW}Проверка установленных инструментов...${NC}"

if ! command -v kind &> /dev/null; then
    echo -e "${RED}✗ kind не установлен${NC}"
    echo "Установите Kind: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi
echo -e "${GREEN}✓ kind $(kind version | cut -d' ' -f2)${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl не установлен${NC}"
    exit 1
fi
echo -e "${GREEN}✓ kubectl $(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ docker не установлен${NC}"
    exit 1
fi
echo -e "${GREEN}✓ docker $(docker --version | cut -d' ' -f3 | tr -d ',')${NC}"

echo ""

# Проверка существующего кластера
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${YELLOW}Кластер ${CLUSTER_NAME} уже существует.${NC}"
    read -p "Удалить и пересоздать? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Удаление существующего кластера...${NC}"
        kind delete cluster --name "${CLUSTER_NAME}"
    else
        echo -e "${YELLOW}Используем существующий кластер${NC}"
        SKIP_CREATE=true
    fi
fi

# Создание кластера
if [ "$SKIP_CREATE" != "true" ]; then
    echo -e "${BLUE}Создание Kind кластера '${CLUSTER_NAME}'...${NC}"
    kind create cluster --name "${CLUSTER_NAME}"
    echo -e "${GREEN}✓ Кластер создан${NC}"
else
    # Переключение контекста на существующий кластер
    kubectl config use-context "kind-${CLUSTER_NAME}"
fi

echo ""

# Проверка подключения
echo -e "${BLUE}Проверка подключения к кластеру...${NC}"
kubectl cluster-info --context "kind-${CLUSTER_NAME}"
echo -e "${GREEN}✓ Подключение установлено${NC}"

echo ""

# Сборка образа
echo -e "${BLUE}Сборка Docker образа...${NC}"
cd "${APP_DIR}/app"
docker build -t "${IMAGE_NAME}" .
echo -e "${GREEN}✓ Образ собран${NC}"

echo ""

# Загрузка образа в Kind
echo -e "${BLUE}Загрузка образа в Kind кластер...${NC}"
kind load docker-image "${IMAGE_NAME}" --name "${CLUSTER_NAME}"
echo -e "${GREEN}✓ Образ загружен в кластер${NC}"

echo ""

# Применение манифестов
echo -e "${BLUE}Применение Kubernetes манифестов...${NC}"
kubectl apply -k "${APP_DIR}/k8s/"
echo -e "${GREEN}✓ Манифесты применены${NC}"

echo ""

# Ожидание готовности подов
echo -e "${YELLOW}Ожидание готовности подов (это может занять ~60 секунд)...${NC}"
kubectl wait --for=condition=ready pod -l app=web14 -n ${NAMESPACE} --timeout=120s || {
    echo -e "${RED}✗ Ошибка: поды не стали готовы вовремя${NC}"
    echo -e "${YELLOW}Статус подов:${NC}"
    kubectl get pods -n ${NAMESPACE}
    echo ""
    echo -e "${YELLOW}События:${NC}"
    kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp' | tail -20
    exit 1
}

echo -e "${GREEN}✓ Все поды готовы${NC}"

echo ""

# Показать статус
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Статус развертывания${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Pods:${NC}"
kubectl get pods -n ${NAMESPACE} -o wide

echo ""
echo -e "${YELLOW}Services:${NC}"
kubectl get svc -n ${NAMESPACE}

echo ""
echo -e "${YELLOW}Deployments:${NC}"
kubectl get deployments -n ${NAMESPACE}

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Kind кластер успешно настроен!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Следующие шаги:${NC}"
echo ""
echo "1. Проверьте статус ресурсов:"
echo -e "   ${GREEN}kubectl get all -n ${NAMESPACE}${NC}"
echo ""
echo "2. Откройте port-forward для доступа к приложению:"
echo -e "   ${GREEN}kubectl port-forward -n ${NAMESPACE} svc/web14 8062:80${NC}"
echo ""
echo "3. В другом терминале протестируйте endpoints:"
echo -e "   ${GREEN}curl http://localhost:8062/healthz${NC}"
echo -e "   ${GREEN}curl http://localhost:8062/${NC}"
echo ""
echo "4. Посмотрите логи приложения:"
echo -e "   ${GREEN}kubectl logs -n ${NAMESPACE} -l app=web14 --tail=50${NC}"
echo ""
echo "5. Для удаления кластера:"
echo -e "   ${GREEN}kind delete cluster --name ${CLUSTER_NAME}${NC}"
echo ""
