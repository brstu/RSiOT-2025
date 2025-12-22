#!/bin/bash
# Восстановление PostgreSQL из backup
# Использование: ./restore.sh [host] [database] [backup_file]

set -e

# Параметры по умолчанию
PGHOST="${1:-db-postgres-0.postgres-headless.state-lab03.svc.cluster.local}"
PGDATABASE="${2:-testdb}"
PGUSER="postgres"
PGPASSWORD="${POSTGRES_PASSWORD:-StrongPa$$w0rd123}"
BACKUP_DIR="./backups"
BACKUP_FILE="${3:-$(ls -t $BACKUP_DIR/backup-*.sql 2>/dev/null | head -1)}"

echo "=== Восстановление PostgreSQL ==="
echo "Хост: $PGHOST"
echo "База данных: $PGDATABASE"
echo "Backup файл: $BACKUP_FILE"
echo "Время: $(date)"

# Проверка файла backup
if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Файл backup не найден!"
    echo "Доступные backup файлы:"
    ls -la "$BACKUP_DIR"/backup-*.sql 2>/dev/null || echo "   (нет файлов)"
    exit 1
fi

echo "Размер backup файла: $(du -h "$BACKUP_FILE" | cut -f1)"

# Проверка подключения к PostgreSQL
echo "Проверка подключения к PostgreSQL..."
if ! PGPASSWORD="$PGPASSWORD" pg_isready -h "$PGHOST" -U "$PGUSER" -t 5; then
    echo "❌ Не удалось подключиться к PostgreSQL"
    exit 1
fi

# Подтверждение (для безопасности)
echo ""
echo "⚠️  ВНИМАНИЕ: Это перезапишет данные в базе $PGDATABASE!"
read -p "Продолжить? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено пользователем"
    exit 0
fi

# Восстановление
echo "Восстановление базы данных..."
PGPASSWORD="$PGPASSWORD" psql \
    -h "$PGHOST" \
    -U "$PGUSER" \
    -d "$PGDATABASE" \
    -f "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Восстановление успешно завершено!"
    
    # Проверка восстановленных данных
    echo ""
    echo "Проверка восстановленных данных:"
    echo "1. Количество таблиц:"
    PGPASSWORD="$PGPASSWORD" psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -t \
        -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';"
    
    echo ""
    echo "2. Данные в таблице lab_test (если существует):"
    if PGPASSWORD="$PGPASSWORD" psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -t \
        -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'lab_test');" | grep -q "t"; then
        PGPASSWORD="$PGPASSWORD" psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" \
            -c "SELECT COUNT(*) as total_records FROM lab_test; \
                SELECT * FROM lab_test ORDER BY id DESC LIMIT 3;"
    else
        echo "   Таблица lab_test не найдена"
    fi
else
    echo "❌ Ошибка при восстановлении!"
    exit 1
fi

echo "=== Восстановление завершено ==="