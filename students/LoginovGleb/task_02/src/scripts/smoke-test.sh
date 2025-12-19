#!/bin/bash
# Комплексный smoke test для проверки работы приложения
# Лабораторная работа 2, Вариант 14

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="app14"
BASE_URL="http://localhost:8062"
FAILED_TESTS=0
PASSED_TESTS=0
RESPONSE_FILE=$(mktemp)

# Cleanup trap
cleanup() {
    rm -f "$RESPONSE_FILE"
}
trap cleanup EXIT INT TERM

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Smoke Tests для ЛР02 (Вариант 14)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Функция для проверки endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=$3
    
    echo -e "${YELLOW}Тест: ${name}${NC}"
    
    HTTP_CODE=$(curl -s -o "$RESPONSE_FILE" -w "%{http_code}" "${url}" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "$expected_status" ]; then
        echo -e "${GREEN}✓ HTTP статус: ${HTTP_CODE} (ожидалось: ${expected_status})${NC}"
        if [ -f "$RESPONSE_FILE" ]; then
            echo -e "${BLUE}Ответ:${NC}"
            cat "$RESPONSE_FILE" | jq . 2>/dev/null || cat "$RESPONSE_FILE"
            echo ""
        fi
        ((PASSED_TESTS++))
        return 0
    else
        echo -e "${RED}✗ HTTP статус: ${HTTP_CODE} (ожидалось: ${expected_status})${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Функция для проверки JSON поля
test_json_field() {
    local name=$1
    local url=$2
    local field=$3
    local expected=$4
    
    echo -e "${YELLOW}Тест: ${name}${NC}"
    
    RESPONSE=$(curl -s "${url}" 2>/dev/null || echo "{}")
    VALUE=$(echo "$RESPONSE" | jq -r "${field}" 2>/dev/null || echo "null")
    
    if [ "$VALUE" = "$expected" ]; then
        echo -e "${GREEN}✓ Поле ${field}: ${VALUE} (ожидалось: ${expected})${NC}"
        ((PASSED_TESTS++))
        return 0
    else
        echo -e "${RED}✗ Поле ${field}: ${VALUE} (ожидалось: ${expected})${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Предварительная проверка
echo -e "${YELLOW}Предварительная проверка...${NC}"

if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ curl не установлен${NC}"
    exit 1
fi
echo -e "${GREEN}✓ curl установлен${NC}"

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}! jq не установлен (рекомендуется для парсинга JSON)${NC}"
    HAS_JQ=false
else
    echo -e "${GREEN}✓ jq установлен${NC}"
    HAS_JQ=true
fi

# Проверка доступности приложения
echo ""
echo -e "${YELLOW}Проверка доступности приложения...${NC}"
if ! curl -s -f "${BASE_URL}/healthz" > /dev/null 2>&1; then
    echo -e "${RED}✗ Приложение недоступно по адресу ${BASE_URL}${NC}"
    echo ""
    echo -e "${YELLOW}Убедитесь, что:${NC}"
    echo "1. Приложение развернуто: kubectl get pods -n ${NAMESPACE}"
    echo "2. Port-forward запущен: kubectl port-forward -n ${NAMESPACE} svc/web14 8062:80"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓ Приложение доступно${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Запуск тестов${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Тест 1: Health endpoint
test_endpoint "Health endpoint (/healthz)" "${BASE_URL}/healthz" "200"
echo ""

# Тест 2: Проверка поля status в healthz
if [ "$HAS_JQ" = true ]; then
    test_json_field "Health status field" "${BASE_URL}/healthz" ".status" "ok"
    echo ""
fi

# Тест 3: Main page
test_endpoint "Main page (/)" "${BASE_URL}/" "200"
echo ""

# Тест 4: Проверка студенческих данных
if [ "$HAS_JQ" = true ]; then
    test_json_field "Student ID" "${BASE_URL}/" ".student.id" "220018"
    echo ""
    
    test_json_field "Student group" "${BASE_URL}/" ".student.group" "АС-63"
    echo ""
    
    test_json_field "Student variant" "${BASE_URL}/" ".student.variant" "14"
    echo ""
fi

# Тест 5: Echo endpoint (POST)
echo -e "${YELLOW}Тест: Echo endpoint (POST /echo)${NC}"
ECHO_RESPONSE=$(curl -s -X POST "${BASE_URL}/echo" \
    -H "Content-Type: application/json" \
    -d '{"test":"hello","variant":14}' 2>/dev/null || echo "{}")

if [ "$HAS_JQ" = true ]; then
    ECHO_VALUE=$(echo "$ECHO_RESPONSE" | jq -r '.echo.test' 2>/dev/null || echo "null")
    if [ "$ECHO_VALUE" = "hello" ]; then
        echo -e "${GREEN}✓ Echo endpoint работает корректно${NC}"
        echo -e "${BLUE}Ответ:${NC}"
        echo "$ECHO_RESPONSE" | jq .
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Echo endpoint вернул некорректные данные${NC}"
        ((FAILED_TESTS++))
    fi
else
    if echo "$ECHO_RESPONSE" | grep -q "hello"; then
        echo -e "${GREEN}✓ Echo endpoint работает корректно${NC}"
        echo -e "${BLUE}Ответ:${NC}"
        echo "$ECHO_RESPONSE"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Echo endpoint вернул некорректные данные${NC}"
        ((FAILED_TESTS++))
    fi
fi
echo ""

# Тест 6: Проверка 404
test_endpoint "404 для несуществующего endpoint" "${BASE_URL}/nonexistent" "404"
echo ""

# Проверка Kubernetes ресурсов
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Проверка Kubernetes ресурсов${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}Проверка подов...${NC}"
    POD_COUNT=$(kubectl get pods -n ${NAMESPACE} -l app=web14 --field-selector=status.phase=Running 2>/dev/null | grep -c "Running" || echo "0")
    
    if [ "$POD_COUNT" -ge 3 ]; then
        echo -e "${GREEN}✓ Запущено ${POD_COUNT} подов (ожидалось: 3)${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Запущено ${POD_COUNT} подов (ожидалось: 3)${NC}"
        kubectl get pods -n ${NAMESPACE} -l app=web14
        ((FAILED_TESTS++))
    fi
    echo ""
    
    echo -e "${YELLOW}Проверка readiness...${NC}"
    READY_COUNT=$(kubectl get pods -n ${NAMESPACE} -l app=web14 -o json 2>/dev/null | \
        jq '[.items[].status.conditions[] | select(.type=="Ready" and .status=="True")] | length' || echo "0")
    
    if [ "$READY_COUNT" -ge 3 ]; then
        echo -e "${GREEN}✓ ${READY_COUNT} подов готовы${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ Только ${READY_COUNT} подов готовы${NC}"
        ((FAILED_TESTS++))
    fi
    echo ""
else
    echo -e "${YELLOW}kubectl недоступен, пропускаем проверку ресурсов${NC}"
    echo ""
fi

# Итоги
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Итоги тестирования${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Пройдено тестов: ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Провалено тестов: ${RED}${FAILED_TESTS}${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ Все тесты пройдены успешно!${NC}"
    exit 0
else
    echo -e "${RED}✗ Некоторые тесты провалены${NC}"
    exit 1
fi
