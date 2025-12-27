#!/bin/sh
set -e

echo "=== Redis Restore Script ==="
echo "Student: Loginov Gleb Olegovich (220018)"
echo "Group: AS-63, Variant: 14"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

BACKUP_DIR="${BACKUP_DIR:-/backup}"
NAMESPACE="${NAMESPACE:-state-as63-220018-v14}"
POD_NAME="${POD_NAME:-db-as63-220018-v14-0}"

# Найти последний backup
LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/redis_backup_*.rdb 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "ERROR: No backup files found in $BACKUP_DIR"
  exit 1
fi

echo "Found backup: $LATEST_BACKUP"
echo "Backup size: $(du -h "$LATEST_BACKUP" | cut -f1)"

# Скопировать backup в Redis data директорию
echo "Copying backup to Redis data directory..."
# Скопировать во временный файл сначала для безопасности
kubectl cp "$LATEST_BACKUP" "${NAMESPACE}/${POD_NAME}:/data/dump.rdb.tmp"
# Переименовать после успешного копирования
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- mv /data/dump.rdb.tmp /data/dump.rdb

# Перезапустить под для применения восстановленных данных
echo "Restarting Redis pod..."
kubectl delete pod -n "$NAMESPACE" "$POD_NAME"

# Дождаться готовности
echo "Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod/"$POD_NAME" -n "$NAMESPACE" --timeout=120s

echo "=== Restore completed successfully ==="
exit 0
