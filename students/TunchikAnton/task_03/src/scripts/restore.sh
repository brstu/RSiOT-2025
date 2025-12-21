#!/bin/bash
set -e

PGHOST=${PGHOST:-postgres-0.postgres.postgres-stateful.svc.cluster.local}
PGUSER=${POSTGRES_USER:-postgres}
PGDATABASE=${POSTGRES_DB:-testdb}
BACKUP_DIR=${BACKUP_DIR:-/backup}
BACKUP_FILE=${BACKUP_FILE:-backup_latest}

if [ -z "$PGPASSWORD" ] && [ -z "$POSTGRES_PASSWORD" ]; then
    echo "ERROR: PostgreSQL password not set" >&2
    exit 1
fi

export PGPASSWORD=${PGPASSWORD:-$POSTGRES_PASSWORD}

if [ "$BACKUP_FILE" = "backup_latest" ]; then
    BACKUP_FILE=$(ls -t ${BACKUP_DIR}/backup_*.sql 2>/dev/null | head -1)
    if [ -z "$BACKUP_FILE" ]; then
        echo "ERROR: No backup files found in ${BACKUP_DIR}" >&2
        exit 1
    fi
else
    BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE}"
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: ${BACKUP_FILE}" >&2
    exit 1
fi

echo "Starting restore of database ${PGDATABASE}"
echo "Host: ${PGHOST}, User: ${PGUSER}, Database: ${PGDATABASE}"
echo "Backup file: ${BACKUP_FILE}"
echo "Start time: $(date)"

echo "Cleaning database..."
psql -h $PGHOST -U $PGUSER -d $PGDATABASE -c "
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO ${PGUSER};
GRANT ALL ON SCHEMA public TO public;
" 2>/dev/null || true

echo "Restoring database from ${BACKUP_FILE}..."
psql -h $PGHOST -U $PGUSER -d $PGDATABASE < "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Restore completed successfully at $(date)"
    echo "Restored from: ${BACKUP_FILE}"
    echo "Restore size: $(du -h ${BACKUP_FILE} | cut -f1)"
else
    echo "Restore failed!" >&2
    exit 1
fi