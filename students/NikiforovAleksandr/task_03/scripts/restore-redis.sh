#!/bin/bash
set -e

echo "=== Manual Redis Restore Script ==="
echo "Student: 220020, Variant: 16"

# Параметры
NAMESPACE="state01"
REDIS_POD="redis-stateful-0"
BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file.rdb.gz>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Получаем пароль из секрета
PASSWORD=$(kubectl get secret redis-secret -n $NAMESPACE -o jsonpath='{.data.password}' | base64 -d)

echo "Stopping Redis..."
kubectl exec -n $NAMESPACE $REDIS_POD -- redis-cli -a "$PASSWORD" SHUTDOWN SAVE || true

echo "Waiting for pod to restart..."
sleep 10

# Распаковываем бэкап
TEMP_FILE="/tmp/restore.rdb"
gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"

echo "Copying backup to pod..."
kubectl cp "$TEMP_FILE" $NAMESPACE/$REDIS_POD:/data/dump.rdb

# Удаляем временный файл
rm -f "$TEMP_FILE"

echo "Restore completed!"
echo "You may need to restart the pod: kubectl delete pod -n $NAMESPACE $REDIS_POD"