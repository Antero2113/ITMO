#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
export PAGER=cat

TOKEN="FAILOVER_PREP_$(date +%s)"

echo
echo "== replication state on primary (pg_a) =="

psql -P pager=off -x \
  -h pg_a \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT application_name,state,sync_state FROM pg_stat_replication ORDER BY application_name;"

echo
echo "== client session 1: write to primary =="

psql -v ON_ERROR_STOP=1 \
  -P pager=off \
  -h pg_a \
  -p 5432 \
  -U postgres \
  -d postgres <<SQL
CREATE TABLE IF NOT EXISTS stage2_test (
  id serial primary key,
  token text,
  created_at timestamptz default now()
);

INSERT INTO stage2_test(token)
VALUES ('${TOKEN}');
SQL

echo
echo "== client session 2: read from standby B =="

rows_b=$(psql -t -A \
  -h pg_b \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT count(*) FROM stage2_test WHERE token='${TOKEN}';")

echo "rows_on_pg_b=$rows_b"

echo
echo "== client session 3: read from cascade standby C =="

echo "== waiting for replication lag (12s) =="
sleep 12

rows_c=$(psql -t -A \
  -h pg_c \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT count(*) FROM stage2_test WHERE token='${TOKEN}';")

echo "rows_on_pg_c_now=$rows_c"

echo
echo "== active client connections =="

psql -P pager=off -x \
  -h pg_a \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "
SELECT pid,usename,application_name,state,client_addr
FROM pg_stat_activity
WHERE backend_type='client backend';
"

echo
echo "== DONE: replication validation completed (write + standby + cascade + connections) =="