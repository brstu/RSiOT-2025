#!/bin/sh
set -e

echo "=== Redis Backup Script ==="
echo "Student: Loginov Gleb Olegovich (220018)"
echo "Group: AS-63, Variant: 14"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

REDIS_HOST="${REDIS_HOST:-db-as63-220018-v14-0.redis-headless-as63-220018-v14.state-as63-220018-v14.svc.cluster.local}"
REDIS_PORT="${REDIS_PORT:-6379}"
BACKUP_DIR="${BACKUP_DIR:-/backup}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/redis_backup_${TIMESTAMP}.rdb"

echo "Connecting to Redis: ${REDIS_HOST}:${REDIS_PORT}"

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

echo "Backup completed: $BACKUP_FILE"
if [ -f "$BACKUP_FILE" ]; then
  echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
else
  echo "Warning: Backup file not found at $BACKUP_FILE"
fi

# Очистка старых backup (ls -t сортирует по времени изменения, новые первые)
# tail -n +11 пропускает первые 10 и возвращает остальные для удаления
echo "Cleaning old backups (keeping 10 newest)..."
ls -t ${BACKUP_DIR}/redis_backup_*.rdb 2>/dev/null | tail -n +11 | xargs -r rm -f

echo "=== Backup completed successfully ==="
exit 0
