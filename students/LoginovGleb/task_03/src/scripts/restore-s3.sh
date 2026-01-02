#!/bin/sh
set -e

echo "=== Redis Restore Script with S3 Support ==="
echo "Student: Loginov Gleb Olegovich (220018)"
echo "Group: AS-63, Variant: 14"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

REDIS_NAMESPACE="${REDIS_NAMESPACE:-state-as63-220018-v14}"
REDIS_POD="${REDIS_POD:-db-as63-220018-v14-0}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
RESTORE_SOURCE="${RESTORE_SOURCE:-s3}"  # "local" or "s3"

# S3 configuration
S3_ENDPOINT="${S3_ENDPOINT:-http://minio-service-as63-220018-v14.state-as63-220018-v14.svc.cluster.local:9000}"
S3_BUCKET="${S3_BUCKET:-redis-backups}"
S3_ACCESS_KEY="${MINIO_ROOT_USER:-minioadmin}"
S3_SECRET_KEY="${MINIO_ROOT_PASSWORD:-minioadmin123}"

echo "Restore source: ${RESTORE_SOURCE}"

if [ "$RESTORE_SOURCE" = "s3" ]; then
  echo ""
  echo "=== Downloading latest backup from S3 (MinIO) ==="
  
  # Настроить MinIO Client
  echo "Configuring MinIO Client..."
  mc alias set myminio "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY" || {
    echo "ERROR: Failed to configure MinIO client"
    exit 1
  }
  
  # Получить список backup и найти последний
  echo "Fetching backup list from S3..."
  LATEST_S3_BACKUP=$(mc ls myminio/$S3_BUCKET | grep redis_backup_ | tail -n 1 | awk '{print $NF}')
  
  if [ -z "$LATEST_S3_BACKUP" ]; then
    echo "ERROR: No backups found in S3 bucket: $S3_BUCKET"
    exit 1
  fi
  
  echo "Found latest S3 backup: $LATEST_S3_BACKUP"
  
  # Скачать backup
  LATEST_BACKUP="${BACKUP_DIR}/${LATEST_S3_BACKUP}"
  echo "Downloading to: $LATEST_BACKUP"
  
  if ! mc cp "myminio/$S3_BUCKET/$LATEST_S3_BACKUP" "$LATEST_BACKUP"; then
    echo "ERROR: Failed to download backup from S3"
    exit 1
  fi
  
  echo "✓ Successfully downloaded from S3"
else
  # Использовать локальный backup
  echo ""
  echo "=== Using local backup ==="
  
  LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/redis_backup_*.rdb 2>/dev/null | head -n 1)
  
  if [ -z "$LATEST_BACKUP" ]; then
    echo "ERROR: No local backup files found in $BACKUP_DIR"
    exit 1
  fi
  
  echo "Found local backup: $LATEST_BACKUP"
fi

echo "Backup size: $(du -h "$LATEST_BACKUP" | cut -f1)"

# Проверить наличие kubectl (если используем этот подход)
if command -v kubectl >/dev/null 2>&1; then
  echo ""
  echo "=== Restoring to Redis pod ==="
  
  # Остановить Redis для безопасного восстановления
  echo "Stopping Redis gracefully..."
  kubectl exec -n "$REDIS_NAMESPACE" "$REDIS_POD" -- redis-cli -a "$REDIS_PASSWORD" SHUTDOWN NOSAVE || {
    echo "Warning: Redis shutdown command failed (pod may already be stopped)"
  }
  
  # Подождать остановки
  sleep 5
  
  # Скопировать backup в Redis data директорию
  echo "Copying backup to Redis data directory..."
  kubectl cp "$LATEST_BACKUP" "${REDIS_NAMESPACE}/${REDIS_POD}:/data/dump.rdb" || {
    # Альтернативный метод через cat
    echo "Trying alternative copy method..."
    cat "$LATEST_BACKUP" | kubectl exec -i -n "$REDIS_NAMESPACE" "$REDIS_POD" -- sh -c 'cat > /data/dump.rdb'
  }
  
  # Перезапустить под для применения восстановленных данных
  echo "Restarting Redis pod..."
  kubectl delete pod -n "$REDIS_NAMESPACE" "$REDIS_POD"
  
  # Дождаться готовности
  echo "Waiting for pod to be ready..."
  kubectl wait --for=condition=ready pod/"$REDIS_POD" -n "$REDIS_NAMESPACE" --timeout=120s
  
  echo ""
  echo "✓ Pod is ready"
else
  echo ""
  echo "=== Manual restore required ==="
  echo "kubectl is not available in this container"
  echo "Backup is ready at: $LATEST_BACKUP"
  echo ""
  echo "Manual steps:"
  echo "1. kubectl exec -n $REDIS_NAMESPACE $REDIS_POD -- redis-cli -a \$REDIS_PASSWORD SHUTDOWN NOSAVE"
  echo "2. kubectl cp $LATEST_BACKUP ${REDIS_NAMESPACE}/${REDIS_POD}:/data/dump.rdb"
  echo "3. kubectl delete pod -n $REDIS_NAMESPACE $REDIS_POD"
  exit 0
fi

echo ""
echo "=== Restore completed successfully ==="
echo "Data restored from: $LATEST_BACKUP"
if [ "$RESTORE_SOURCE" = "s3" ]; then
  echo "Source: S3 bucket s3://${S3_BUCKET}/"
fi
exit 0
