#!/bin/bash
set -e

echo "=== PostgreSQL Backup Script ==="
echo "Student ID: ${STU_ID:-220028}"
echo "Group: ${STU_GROUP:-АС-63}"
echo "Variant: ${STU_VARIANT:-23}"
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"

# Параметры подключения
DB_HOST="${POSTGRES_HOST:-db-postgres-headless}"
DB_PORT="${POSTGRES_PORT:-5432}"
DB_USER="${POSTGRES_USER:-admin}"
DB_NAME="${POSTGRES_DB:-testdb}"

# Путь для backup
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql.gz"

echo "Connecting to PostgreSQL at ${DB_HOST}:${DB_PORT}..."
echo "Database: ${DB_NAME}"

# Проверка доступности базы
until PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "${DB_HOST}" -U "${DB_USER}" -d "${DB_NAME}" -c '\q'; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

echo "PostgreSQL is ready. Starting backup..."

# Создание backup
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump \
  -h "${DB_HOST}" \
  -U "${DB_USER}" \
  -d "${DB_NAME}" \
  --no-owner \
  --no-acl \
  | gzip > "${BACKUP_FILE}"

if [ -f "${BACKUP_FILE}" ]; then
  BACKUP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
  echo "✅ Backup completed successfully!"
  echo "File: ${BACKUP_FILE}"
  echo "Size: ${BACKUP_SIZE}"
  
  # Удаление старых backup (оставляем последние 5)
  echo "Cleaning old backups (keeping last 5)..."
  ls -t ${BACKUP_DIR}/backup_*.sql.gz | tail -n +6 | xargs -r rm -f
  
  # Список всех backup
  echo "Available backups:"
  ls -lh ${BACKUP_DIR}/backup_*.sql.gz 2>/dev/null || echo "No backups found"
else
  echo "❌ Backup failed!"
  exit 1
fi

echo "=== Backup Complete ==="
