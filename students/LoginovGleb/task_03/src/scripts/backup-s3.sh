#!/bin/sh
set -e

echo "=== Redis Backup Script with S3 Support ==="
echo "Student: Loginov Gleb Olegovich (220018)"
echo "Group: AS-63, Variant: 14"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

REDIS_HOST="${REDIS_HOST:-db-as63-220018-v14-0.redis-headless-as63-220018-v14.state-as63-220018-v14.svc.cluster.local}"
REDIS_PORT="${REDIS_PORT:-6379}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/redis_backup_${TIMESTAMP}.rdb"

# S3 configuration
S3_ENABLED="${S3_ENABLED:-true}"
S3_ENDPOINT="${S3_ENDPOINT:-http://minio-service-as63-220018-v14.state-as63-220018-v14.svc.cluster.local:9000}"
S3_BUCKET="${S3_BUCKET:-redis-backups}"
S3_ACCESS_KEY="${MINIO_ROOT_USER:-minioadmin}"
S3_SECRET_KEY="${MINIO_ROOT_PASSWORD:-minioadmin123}"

echo "Connecting to Redis: ${REDIS_HOST}:${REDIS_PORT}"
echo "S3 Backup enabled: ${S3_ENABLED}"

# Использовать переменную окружения для пароля (безопаснее чем -a в процессе)
export REDISCLI_AUTH="$REDIS_PASSWORD"

# Выполнить BGSAVE
echo "Executing BGSAVE..."
LAST_SAVE_BEFORE=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" LASTSAVE)
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" BGSAVE

# Подождать завершения BGSAVE
echo "Waiting for BGSAVE to complete..."
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  LAST_SAVE_CURRENT=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" LASTSAVE)
  if [ "$LAST_SAVE_CURRENT" != "$LAST_SAVE_BEFORE" ]; then
    echo "BGSAVE completed successfully"
    break
  fi
  sleep 1
  ELAPSED=$((ELAPSED + 1))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
  echo "Warning: BGSAVE timeout, proceeding anyway..."
fi

# Получить текущий dump.rdb через redis-cli
echo "Copying dump.rdb to backup location..."
redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" --rdb "${BACKUP_FILE}"

echo "Local backup completed: $BACKUP_FILE"
if [ -f "$BACKUP_FILE" ]; then
  echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
else
  echo "ERROR: Backup file not found at $BACKUP_FILE"
  exit 1
fi

# Загрузить в S3 если включено
if [ "$S3_ENABLED" = "true" ]; then
  echo ""
  echo "=== Uploading backup to S3 (MinIO) ==="
  
  # Настроить MinIO Client
  echo "Configuring MinIO Client..."
  mc alias set myminio "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY" || {
    echo "Warning: Failed to configure MinIO client"
    echo "Backup saved locally only"
  }
  
  if mc alias list | grep -q myminio; then
    # Проверить существование bucket
    if ! mc ls myminio/$S3_BUCKET >/dev/null 2>&1; then
      echo "Bucket $S3_BUCKET not found, creating..."
      mc mb myminio/$S3_BUCKET || echo "Warning: Failed to create bucket"
    fi
    
    # Загрузить файл
    echo "Uploading to s3://${S3_BUCKET}/redis_backup_${TIMESTAMP}.rdb"
    if mc cp "$BACKUP_FILE" "myminio/$S3_BUCKET/redis_backup_${TIMESTAMP}.rdb"; then
      echo "✓ Successfully uploaded to S3"
      
      # Показать список backup в S3
      echo ""
      echo "S3 Backup list (last 5):"
      mc ls myminio/$S3_BUCKET | tail -n 5 || true
      
      # Автоматическая ротация в S3 (оставить последние 10)
      echo ""
      echo "Cleaning old S3 backups (keeping 10 newest)..."
      mc ls myminio/$S3_BUCKET | head -n -10 | awk '{print $NF}' | while read -r file; do
        if [ -n "$file" ]; then
          echo "Removing old backup: $file"
          mc rm "myminio/$S3_BUCKET/$file" || true
        fi
      done
    else
      echo "Warning: Failed to upload to S3"
    fi
  fi
fi

# Очистка локальных старых backup (оставить последние 10)
echo ""
echo "Cleaning local old backups (keeping 10 newest)..."
ls -t ${BACKUP_DIR}/redis_backup_*.rdb 2>/dev/null | tail -n +11 | xargs -r rm -f

echo ""
echo "=== Backup completed successfully ==="
echo "Local: $BACKUP_FILE"
if [ "$S3_ENABLED" = "true" ]; then
  echo "S3: s3://${S3_BUCKET}/redis_backup_${TIMESTAMP}.rdb"
fi
exit 0
