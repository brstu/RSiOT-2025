#!/bin/bash
set -e

PGHOST=${PGHOST:-postgres-0.postgres.postgres-stateful.svc.cluster.local}
PGUSER=${POSTGRES_USER:-postgres}
PGDATABASE=${POSTGRES_DB:-testdb}
BACKUP_DIR=${BACKUP_DIR:-/backup}

if [ -z "$PGPASSWORD" ] && [ -z "$POSTGRES_PASSWORD" ]; then
    echo "ERROR: PostgreSQL password not set" >&2
    exit 1
fi

export PGPASSWORD=${PGPASSWORD:-$POSTGRES_PASSWORD}

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DATE}.sql"

echo "Starting backup of database ${PGDATABASE} at $(date)"
echo "Host: ${PGHOST}, User: ${PGUSER}, Database: ${PGDATABASE}"

pg_dump -h $PGHOST -U $PGUSER -d $PGDATABASE > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "Backup completed successfully: ${BACKUP_FILE}"
    echo "Backup size: $(du -h ${BACKUP_FILE} | cut -f1)"
    echo "Backup ${DATE}" >> ${BACKUP_DIR}/backup.log
    
    cd $BACKUP_DIR
    ls -t backup_*.sql 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null || true
    echo "Old backups cleaned up"
else
    echo "Backup failed!"
    exit 1
fi