#!/usr/local/bin/bash

DB_HOST="pg196"
DB_USER="postgres2"
DB_PASSWORD="6lVL8X5a"
BACKUP_HOST="pg199"
BACKUP_USER="postgres2"
BACKUP_PATH="backups"
RETENTION_DAYS=28

export PGPASSWORD="$DB_PASSWORD"

BACKUP_NAME="pg_full_$(date +%Y%m%d_%H%M%S).sql.gz"
TEMP_BACKUP="/tmp/$BACKUP_NAME"

pg_dump -h "$DB_HOST" -U "$DB_USER" -d postgres -F p | gzip > "$TEMP_BACKUP"

scp -o ProxyJump=s368273@helios.cs.ifmo.ru:2222 "$TEMP_BACKUP" "$BACKUP_USER@$BACKUP_HOST:$BACKUP_PATH/"

rm -f "$TEMP_BACKUP"

unset PGPASSWORD

ssh -J s368273@helios.cs.ifmo.ru:2222 "$BACKUP_USER@$BACKUP_HOST" "find $BACKUP_PATH -name 'pg_full_*.sql.gz' -mtime +$RETENTION_DAYS -delete"
