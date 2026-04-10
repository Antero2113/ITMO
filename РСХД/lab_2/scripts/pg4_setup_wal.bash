#!/usr/local/bin/bash

export PGDATA=$HOME/zfb92
export WAL_ARCHIVE=$HOME/wal_archive

mkdir -p $WAL_ARCHIVE

cat >> $PGDATA/postgresql.conf <<EOF
wal_level = replica
archive_mode = on
archive_command = 'cp %p $WAL_ARCHIVE/%f'
EOF

pg_ctl -D $PGDATA restart

sleep 3

psql -p 9746 -U testuser -d loudwhiteuser -c "SHOW archive_mode;"
psql -p 9746 -U testuser -d loudwhiteuser -c "SHOW archive_command;"