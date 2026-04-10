#!/usr/local/bin/bash

export PGUSER=postgres2
export PGDATABASE=postgres

psql -U $PGUSER -d $PGDATABASE -c "SELECT count(*) FROM pg_tables WHERE schemaname='public';"
psql -U $PGUSER -d $PGDATABASE -c "SELECT now();"
psql -U $PGUSER -d $PGDATABASE -c "\dt"
