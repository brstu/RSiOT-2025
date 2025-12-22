#!/bin/bash
# Резервное копирование PostgreSQL
# Использование: ./backup.sh [host] [database]

set -e

# Параметры по умолчанию
PGHOST="${1:-db-postgres-0.postgres-headless.state-lab03.svc.cluster.local}"
PGDATABASE="${2:-testdb}"
PGUSER="postgres"
PGPASSWORD="${POSTGRES_PASSWORD:-StrongPa$$w0rd123}"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP.sql"

# Создание директории
mkdir -p "$BACKUP_DIR"

echo "=== Резервное копирование PostgreSQL ==="
echo "Хост: $PGHOST"
echo "База данных: $PGDATABASE"
echo "Время: $(date)"
echo "Backup файл: $BACKUP_FILE"

# Проверка подключения
echo "Проверка подключения к PostgreSQL..."
if ! PGPASSWORD="$PGPASSWORD" pg_isready -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -t 5; then
    echo "❌ Не удалось подключиться к PostgreSQL"
    exit 1
fi

# Создание backup
echo "Создание backup..."
PGPASSWORD="$PGPASSWORD" pg_dump \
    -h "$PGHOST" \
    -U "$PGUSER" \
    -d "$PGDATABASE" \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    > "$BACKUP_FILE"

# Проверка результата
if [ $? -eq 0 ] && [ -s "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    BACKUP_LINES=$(wc -l < "$BACKUP_FILE")
    echo "✅ Backup успешно создан!"
    echo "   Файл: $BACKUP_FILE"
    echo "   Размер: $BACKUP_SIZE"
    echo "   Строк: $BACKUP_LINES"
    
    # Удаление старых бэкапов (оставляем последние 5)
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/backup-*.sql 2>/dev/null | wc -l || echo "0")
    if [ "$BACKUP_COUNT" -gt 5 ]; then
        echo "Удаление старых бэкапов..."
        ls -t "$BACKUP_DIR"/backup-*.sql | tail -n +6 | xargs rm -f
    fi
    
    echo "Оставшиеся backup файлы:"
    ls -lh "$BACKUP_DIR"/backup-*.sql 2>/dev/null || echo "   (нет файлов)"
else
    echo "❌ Ошибка при создании backup!"
    exit 1
fi

echo "=== Backup завершен ==="