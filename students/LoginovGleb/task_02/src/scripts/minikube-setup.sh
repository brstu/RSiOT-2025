#!/bin/bash
# Скрипт автоматической настройки Minikube для лабораторной работы 2
# Вариант 14

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Переменные
IMAGE_NAME="gleb7499/lab1-v14:stu-220018-v14"
NAMESPACE="app14"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Minikube Setup для ЛР02 (Вариант 14)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Проверка наличия необходимых инструментов
echo -e "${YELLOW}Проверка установленных инструментов...${NC}"

if ! command -v minikube &> /dev/null; then
    echo -e "${RED}✗ minikube не установлен${NC}"
    echo "Установите Minikube: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi
echo -e "${GREEN}✓ minikube $(minikube version --short)${NC}"

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

# Проверка статуса Minikube
MINIKUBE_STATUS=$(minikube status -f '{{.Host}}' 2>/dev/null || echo "")

if [ "$MINIKUBE_STATUS" = "Running" ]; then
    echo -e "${YELLOW}Minikube уже запущен.${NC}"
    read -p "Остановить и перезапустить? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Остановка Minikube...${NC}"
        minikube stop
        echo -e "${BLUE}Запуск Minikube...${NC}"
        minikube start --driver=docker
    else
        echo -e "${YELLOW}Используем запущенный Minikube${NC}"
    fi
else
    echo -e "${BLUE}Запуск Minikube...${NC}"
    minikube start --driver=docker
fi

echo -e "${GREEN}✓ Minikube запущен${NC}"

echo ""

# Включение Ingress addon
echo -e "${BLUE}Включение Ingress контроллера...${NC}"
minikube addons enable ingress
echo -e "${GREEN}✓ Ingress включен${NC}"

echo ""

# Проверка подключения
echo -e "${BLUE}Проверка подключения к кластеру...${NC}"
kubectl cluster-info
echo -e "${GREEN}✓ Подключение установлено${NC}"

echo ""

# Сборка образа
echo -e "${BLUE}Сборка Docker образа...${NC}"
cd "${APP_DIR}/app"
docker build -t "${IMAGE_NAME}" .
echo -e "${GREEN}✓ Образ собран${NC}"

echo ""

# Загрузка образа в Minikube
echo -e "${BLUE}Загрузка образа в Minikube...${NC}"
minikube image load "${IMAGE_NAME}"
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

# Ожидание готовности Ingress
echo -e "${YELLOW}Ожидание готовности Ingress контроллера...${NC}"
sleep 10

# Получение IP Minikube
MINIKUBE_IP=$(minikube ip)

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
echo -e "${YELLOW}Ingress:${NC}"
kubectl get ingress -n ${NAMESPACE}

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Minikube успешно настроен!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Minikube IP: ${GREEN}${MINIKUBE_IP}${NC}"
echo ""

echo -e "${YELLOW}Следующие шаги:${NC}"
echo ""
echo "1. Добавьте запись в файл hosts для доступа через Ingress:"
echo ""
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo -e "   ${BLUE}Windows (PowerShell от администратора):${NC}"
    echo -e "   ${GREEN}Add-Content -Path \"C:\\Windows\\System32\\drivers\\etc\\hosts\" -Value \"${MINIKUBE_IP} web14.local\"${NC}"
else
    echo -e "   ${BLUE}Linux/macOS:${NC}"
    echo -e "   ${GREEN}sudo sh -c \"echo '${MINIKUBE_IP} web14.local' >> /etc/hosts\"${NC}"
fi

echo ""
echo "2. Проверьте доступ через Ingress:"
echo -e "   ${GREEN}curl http://web14.local/healthz${NC}"
echo -e "   ${GREEN}curl http://web14.local/${NC}"
echo ""
echo "3. Альтернатива - используйте port-forward:"
echo -e "   ${GREEN}kubectl port-forward -n ${NAMESPACE} svc/web14 8062:80${NC}"
echo -e "   ${GREEN}curl http://localhost:8062/healthz${NC}"
echo ""
echo "4. Посмотрите логи приложения:"
echo -e "   ${GREEN}kubectl logs -n ${NAMESPACE} -l app=web14 --tail=50${NC}"
echo ""
echo "5. Для остановки Minikube:"
echo -e "   ${GREEN}minikube stop${NC}"
echo ""
echo "6. Для удаления кластера:"
echo -e "   ${GREEN}minikube delete${NC}"
echo ""
