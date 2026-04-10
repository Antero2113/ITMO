#!/usr/local/bin/bash

export PGDATA=/var/db/postgres2/data
export PGUSER=postgres2
export PGDATABASE=postgres

initdb -D $PGDATA

pg_ctl -D $PGDATA start

sleep 3

createuser -s $PGUSER 2>/dev/null

createdb -O $PGUSER $PGDATABASE 2>/dev/null
