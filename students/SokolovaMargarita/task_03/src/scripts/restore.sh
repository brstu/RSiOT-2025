#!/bin/bash
set -e

echo "=== PostgreSQL Restore Script ==="
echo "Student ID: ${STU_ID:-220024}"
echo "Group: ${STU_GROUP:-АС-63}"
echo "Variant: ${STU_VARIANT:-19}"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

# Параметры подключения
DB_HOST="${POSTGRES_HOST:-db-postgres-headless}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_USER="${POSTGRES_USER:-admin}"
DB_NAME="${POSTGRES_DB:-testdb}"

# Путь для backup
BACKUP_DIR="/backups"

echo "Connecting to PostgreSQL at ${DB_HOST}:${DB_PORT}..."
echo "Database: ${DB_NAME}"

# Проверка доступности базы
until PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c '\q'; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

echo "PostgreSQL is ready."

# Поиск последнего backup
LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/backup_*.sql.gz 2>/dev/null | head -n1)

if [ -z "${LATEST_BACKUP}" ]; then
  echo "❌ No backup files found in ${BACKUP_DIR}"
  exit 1
fi

echo "Found backup: ${LATEST_BACKUP}"
BACKUP_SIZE=$(du -h "${LATEST_BACKUP}" | cut -f1)
echo "Backup size: ${BACKUP_SIZE}"

# Подтверждение восстановления
echo "⚠️  This will DROP and RECREATE the database!"
echo "Database: ${DB_NAME}"
echo "Backup file: ${LATEST_BACKUP}"

# Восстановление
echo "Starting restore..."

# Удаление существующих соединений
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d postgres -c "
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = '${DB_NAME}'
  AND pid <> pg_backend_pid();
" || true

# Пересоздание базы
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};"
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d postgres -c "CREATE DATABASE ${DB_NAME};"

# Восстановление данных
gunzip < "${LATEST_BACKUP}" | PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}"

if [ $? -eq 0 ]; then
  echo "✅ Restore completed successfully!"
  
  # Проверка восстановленных данных
  echo "Checking restored data..."
  TABLE_COUNT=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")
  echo "Tables restored: ${TABLE_COUNT}"
else
  echo "❌ Restore failed!"
  exit 1
fi

echo "=== Restore Complete ==="
