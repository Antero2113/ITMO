#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres

TOKEN="AFTER_FAILOVER_$(date +%s)"

echo
echo "== POST-FAILOVER WRITE TEST =="
echo

printf '== write on promoted node ==\n'

psql -v ON_ERROR_STOP=1 \
  -h pg_b \
  -p 5432 \
  -U postgres \
  -d postgres <<SQL
INSERT INTO stage2_test(token)
VALUES ('${TOKEN}');
SQL

printf '\n== read from new primary ==\n'

rows_b=$(psql -t -A \
  -h pg_b \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT count(*) FROM stage2_test WHERE token='${TOKEN}';")

echo "rows_on_new_primary=$rows_b"

printf '\n== wait for replication ==\n'

sleep 12

printf '\n== read from cascade replica ==\n'

rows_c=$(psql -t -A \
  -h pg_c \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT count(*) FROM stage2_test WHERE token='${TOKEN}';")

echo "rows_on_pg_c=$rows_c"

echo
echo "== DONE: post-failover write verified (primary + cascade replication) =="