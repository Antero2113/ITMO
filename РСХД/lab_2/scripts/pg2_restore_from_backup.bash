#!/usr/local/bin/bash

export PGDATA=/var/db/postgres2/data
export PGUSER=postgres2
export PGDATABASE=postgres
export BACKUP_DIR=~/backups

LATEST_BACKUP=$(ls -t $BACKUP_DIR/pg_full_*.sql.gz | head -1)

pg_ctl -D $PGDATA stop 2>/dev/null

rm -rf $PGDATA/*

initdb -D $PGDATA

pg_ctl -D $PGDATA start

sleep 3

createuser -s $PGUSER 2>/dev/null
createdb -O $PGUSER $PGDATABASE 2>/dev/null

zcat $LATEST_BACKUP | psql -U $PGUSER -d $PGDATABASE

pg_ctl -D $PGDATA restart

sleep 2

psql -U $PGUSER -d $PGDATABASE -c "SELECT version();"
psql -U $PGUSER -d $PGDATABASE -c "\l"
