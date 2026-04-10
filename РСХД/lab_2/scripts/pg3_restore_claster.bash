#!/usr/local/bin/bash

export PGDATA=$HOME/zfb92
export NEW_KLS=/var/db/postgres2/new_kls10
export NEW_OPY=/var/db/postgres2/new_opy85

mkdir -p $PGDATA
mkdir -p $NEW_KLS
mkdir -p $NEW_OPY

initdb -D $PGDATA --encoding=KOI8-R --locale=ru_RU.KOI8-R

mkdir -p $PGDATA/log

cat > $PGDATA/pg_hba.conf << 'EOF'
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
EOF

cat > $PGDATA/postgresql.conf << 'EOF'
port = 9746
listen_addresses = 'localhost'
max_connections = 7

shared_buffers = 2GB
temp_buffers = 64MB
work_mem = 128MB
effective_cache_size = 5GB

fsync = on
commit_delay = 100000
checkpoint_timeout = 30min

log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql.log'
log_min_messages = ERROR
log_disconnections = on
log_duration = on
EOF

pg_ctl -D $PGDATA -l $PGDATA/log/postgresql.log start

sleep 5

psql -p 9746 -U postgres2 -d postgres << EOF
CREATE TABLESPACE kls10 LOCATION '$NEW_KLS';
CREATE TABLESPACE opy85 LOCATION '$NEW_OPY';
CREATE ROLE testuser WITH LOGIN PASSWORD 'testpass';
GRANT CONNECT ON DATABASE template1 TO testuser;
CREATE DATABASE loudwhiteuser OWNER testuser TEMPLATE template1 ENCODING 'KOI8-R' LC_COLLATE 'ru_RU.KOI8-R' LC_CTYPE 'ru_RU.KOI8-R';
GRANT CREATE ON TABLESPACE kls10 TO testuser;
GRANT CREATE ON TABLESPACE opy85 TO testuser;
EOF