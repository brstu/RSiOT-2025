#!/bin/bash
set -e

echo "=== Manual Redis Backup Script ==="
echo "Student: 220020, Variant: 16"

# Параметры
NAMESPACE="state01"
REDIS_POD="redis-stateful-0"
BACKUP_DIR="./backups"

# Создаем директорию для бэкапов
mkdir -p "$BACKUP_DIR"

# Получаем пароль из секрета
PASSWORD=$(kubectl get secret redis-secret -n $NAMESPACE -o jsonpath='{.data.password}' | base64 -d)

# Выполняем SAVE в Redis
echo "Executing SAVE command..."
kubectl exec -n $NAMESPACE $REDIS_POD -- redis-cli -a "$PASSWORD" SAVE

# Копируем файл дампа
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="$BACKUP_DIR/redis-backup-$TIMESTAMP.rdb"

echo "Copying dump.rdb..."
kubectl cp $NAMESPACE/$REDIS_POD:/data/dump.rdb "$BACKUP_FILE"

# Сжимаем
gzip "$BACKUP_FILE"

echo "Backup created: ${BACKUP_FILE}.gz"
echo "Size: $(du -h "${BACKUP_FILE}.gz" | cut -f1)"