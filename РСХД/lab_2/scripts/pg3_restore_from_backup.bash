#!/usr/local/bin/bash

export BACKUP_HOST=pg199
export BACKUP_USER=postgres2
export REMOTE_BACKUP_DIR=~/backups
export LOCAL_BACKUP_DIR=~/restore_tmp

mkdir -p $LOCAL_BACKUP_DIR

LATEST_BACKUP=$(ssh $BACKUP_USER@$BACKUP_HOST "ls -t $REMOTE_BACKUP_DIR/pg_full_*.sql.gz | head -1")

scp $BACKUP_USER@$BACKUP_HOST:$LATEST_BACKUP $LOCAL_BACKUP_DIR/

LOCAL_FILE=$(ls -t $LOCAL_BACKUP_DIR/pg_full_*.sql.gz | head -1)

zcat $LOCAL_FILE | psql -p 9746 -U testuser -d loudwhiteuser
