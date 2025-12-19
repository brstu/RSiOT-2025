#!/bin/bash
# Демонстрация работы с PersistentVolumeClaim для PostgreSQL
# Лабораторная работа 2, Вариант 14

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="app14"
DB_POD=""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Демонстрация работы с PVC${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Функция получения имени пода БД
get_db_pod() {
    DB_POD=$(kubectl get pod -n ${NAMESPACE} -l app=postgres-db -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -z "$DB_POD" ]; then
        echo -e "${RED}✗ PostgreSQL pod не найден${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ PostgreSQL pod: ${DB_POD}${NC}"
}

# Проверка kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl не установлен${NC}"
    exit 1
fi

echo -e "${YELLOW}Проверка статуса PVC...${NC}"
kubectl get pvc -n ${NAMESPACE}
echo ""

echo -e "${YELLOW}Проверка статуса PostgreSQL pod...${NC}"
kubectl get pods -n ${NAMESPACE} -l app=postgres-db
echo ""

get_db_pod

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Тест 1: Создание тестовой таблицы и данных${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Создание таблицы test_persistence...${NC}"
kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -c "
CREATE TABLE IF NOT EXISTS test_persistence (
    id SERIAL PRIMARY KEY,
    test_data VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"
echo -e "${GREEN}✓ Таблица создана${NC}"
echo ""

echo -e "${YELLOW}Вставка тестовых данных...${NC}"
kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -c "
INSERT INTO test_persistence (test_data) VALUES 
    ('Test data from variant 14'),
    ('Student ID: 220018'),
    ('Group: АС-63'),
    ('PVC demonstration'),
    ('Data should persist after pod restart');
"
echo -e "${GREEN}✓ Данные добавлены${NC}"
echo ""

echo -e "${YELLOW}Проверка вставленных данных...${NC}"
kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -c "
SELECT * FROM test_persistence;
"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Тест 2: Проверка персистентности данных${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Удаление PostgreSQL pod для проверки персистентности...${NC}"
kubectl delete pod -n ${NAMESPACE} ${DB_POD}
echo -e "${GREEN}✓ Pod удален${NC}"
echo ""

echo -e "${YELLOW}Ожидание создания нового pod (это займет ~30 секунд)...${NC}"
sleep 10
kubectl wait --for=condition=ready pod -l app=postgres-db -n ${NAMESPACE} --timeout=120s
echo -e "${GREEN}✓ Новый pod готов${NC}"
echo ""

get_db_pod

echo -e "${YELLOW}Проверка, что данные сохранились после перезапуска...${NC}"
DATA_COUNT=$(kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -t -c "SELECT COUNT(*) FROM test_persistence;" | tr -d ' ')

if [ "$DATA_COUNT" -eq 5 ]; then
    echo -e "${GREEN}✓ Все данные сохранились! Найдено записей: ${DATA_COUNT}${NC}"
else
    echo -e "${RED}✗ Данные не сохранились. Найдено записей: ${DATA_COUNT} (ожидалось: 5)${NC}"
    exit 1
fi
echo ""

echo -e "${YELLOW}Содержимое таблицы после перезапуска:${NC}"
kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -c "
SELECT * FROM test_persistence;
"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Тест 3: Информация о томе${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Информация о PVC:${NC}"
kubectl describe pvc -n ${NAMESPACE} data-pvc-as63-220018-v14
echo ""

echo -e "${YELLOW}Размер использованного пространства в pod:${NC}"
kubectl exec -n ${NAMESPACE} ${DB_POD} -- df -h /var/lib/postgresql/data
echo ""

echo -e "${YELLOW}Файлы в директории PostgreSQL:${NC}"
kubectl exec -n ${NAMESPACE} ${DB_POD} -- ls -lh /var/lib/postgresql/data | head -20
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Тест 4: Очистка тестовых данных${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Проверка параметров командной строки для автоматической очистки
AUTO_CLEANUP=false
if [[ "$1" == "--auto-cleanup" ]]; then
    AUTO_CLEANUP=true
    echo -e "${YELLOW}Автоматическая очистка включена${NC}"
fi

if [ "$AUTO_CLEANUP" = true ]; then
    echo -e "${YELLOW}Удаление тестовой таблицы...${NC}"
    kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -c "
    DROP TABLE IF EXISTS test_persistence;
    "
    echo -e "${GREEN}✓ Тестовая таблица удалена${NC}"
else
    read -p "Удалить тестовую таблицу? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Удаление тестовой таблицы...${NC}"
        kubectl exec -n ${NAMESPACE} ${DB_POD} -- psql -U app_user -d app_220018_v14 -c "
        DROP TABLE IF EXISTS test_persistence;
        "
        echo -e "${GREEN}✓ Тестовая таблица удалена${NC}"
    else
        echo -e "${YELLOW}Тестовая таблица оставлена для дальнейшего изучения${NC}"
    fi
fi
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Демонстрация PVC завершена успешно!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Выводы:${NC}"
echo "1. PVC корректно создан и примонтирован к PostgreSQL pod"
echo "2. Данные сохраняются при перезапуске pod"
echo "3. PersistentVolume обеспечивает персистентность данных"
echo "4. При удалении pod, новый pod получает доступ к тем же данным"
echo ""
