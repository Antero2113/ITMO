#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
export PAGER=cat

TOKEN="FAILOVER_PREP_$(date +%s)"

printf '== Replication state on primary ==\n'
psql -P pager=off -x \
  -h pg_a \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT application_name,state,sync_state FROM pg_stat_replication ORDER BY application_name;"

printf '\n== Client session 1: write to primary ==\n'

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

printf '\n== Client session 2: read from standby B ==\n'

rows_b=$(psql -t -A \
  -h pg_b \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT count(*) FROM stage2_test WHERE token='${TOKEN}';")

echo "rows_on_pg_b=$rows_b"

printf '\n== Client session 3: read from cascading standby C ==\n'
printf '\n== wait 12 seconds ==\n'

sleep 12

rows_c=$(psql -t -A \
  -h pg_c \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT count(*) FROM stage2_test WHERE token='${TOKEN}';")

echo "rows_on_pg_c_now=$rows_c"

printf '\n== Active client connections ==\n'

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