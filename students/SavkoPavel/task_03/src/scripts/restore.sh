#!/bin/sh
# restore.sh - восстанавливает Redis из дампа RDB
# Требует: $REDIS_PASSWORD установлен

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: restore.sh /backup/dump-YYYYMMDDHHMMSS.rdb"
  exit 1
fi

echo "[$(date)] Starting Redis restore from $BACKUP_FILE..."

# Останавливаем Redis (если запускаем внутри контейнера - Redis должен быть остановлен)
# Здесь предполагаем, что контейнер с Redis не работает
cp $BACKUP_FILE /data/dump.rdb
echo "[$(date)] Restore completed. You can now start Redis."
