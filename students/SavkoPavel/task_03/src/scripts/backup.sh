#!/bin/sh
# backup.sh - сохраняет RDB дамп Redis в /backup
# Требует: $REDIS_PASSWORD установлен

BACKUP_DIR=/backup
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="$BACKUP_DIR/dump-$TIMESTAMP.rdb"

# Создаем директорию, если не существует
mkdir -p $BACKUP_DIR

echo "[$(date)] Starting Redis backup..."
redis-cli -a $REDIS_PASSWORD BGSAVE

# Ждем окончания сохранения
while true; do
  STATUS=$(redis-cli -a $REDIS_PASSWORD INFO persistence | grep rdb_bgsave_in_progress | awk -F: '{print $2}' | tr -d '\r')
  if [ "$STATUS" = "0" ]; then
    break
  fi
  echo "[$(date)] Waiting for Redis BGSAVE..."
  sleep 1
done

# Копируем файл dump.rdb в директорию backup с отметкой времени
cp /data/dump.rdb $BACKUP_FILE
echo "[$(date)] Backup saved to $BACKUP_FILE"
