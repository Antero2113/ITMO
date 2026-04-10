#!/usr/local/bin/bash

export PGDATA=$HOME/zfb92
export BASE_BACKUP=$HOME/base_backup_pg4
export WAL_ARCHIVE=$HOME/wal_archive
export PGUSER=testuser
export PGDATABASE=loudwhiteuser

pg_ctl -D $PGDATA stop -m fast 2>/dev/null

rm -rf $PGDATA
mkdir -p $PGDATA

tar -xzf $BASE_BACKUP/base.tar.gz -C $PGDATA
tar -xzf $BASE_BACKUP/pg_wal.tar.gz -C $PGDATA

touch $PGDATA/recovery.signal

cat >> $PGDATA/postgresql.conf <<EOF
restore_command = 'cp $WAL_ARCHIVE/%f %p'
recovery_target_time = '$(cat ~/pg4_time.txt)'
EOF

pg_ctl -D $PGDATA -l $PGDATA/logfile start

sleep 5

psql -p 9746 -U $PGUSER -d $PGDATABASE <<EOF
SELECT * FROM products ORDER BY id;
SELECT * FROM sales ORDER BY id;
EOF