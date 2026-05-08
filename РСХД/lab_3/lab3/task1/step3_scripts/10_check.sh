#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres

echo "== FINAL TOPOLOGY CHECK =="

echo
echo "== Node roles =="

for node in pg_a pg_b pg_c
do
  echo "--- $node ---"

  docker exec lab3_$node env PGPASSWORD=postgres psql \
    -h 127.0.0.1 \
    -U postgres \
    -d postgres \
    -t -A \
    -c "
SELECT CASE
         WHEN pg_is_in_recovery()
           THEN 'standby'
         ELSE 'primary'
       END;
"
done

echo
echo "== Replication state on primary pg_a =="

docker exec lab3_pg_a env PGPASSWORD=postgres psql \
  -h 127.0.0.1 \
  -U postgres \
  -d postgres \
  -x \
  -c "
SELECT application_name,
       client_addr,
       state,
       sync_state
FROM pg_stat_replication
ORDER BY application_name;
"

echo
echo "== Replication slots on pg_a =="

docker exec lab3_pg_a env PGPASSWORD=postgres psql \
  -h 127.0.0.1 \
  -U postgres \
  -d postgres \
  -c "
SELECT slot_name,
       active
FROM pg_replication_slots
ORDER BY slot_name;
"

echo
echo "== Data consistency check =="

docker exec lab3_pg_a env PGPASSWORD=postgres psql \
  -h 127.0.0.1 \
  -U postgres \
  -d postgres \
  -c "
SELECT count(*) AS rows_on_pg_a
FROM stage2_test;
"

docker exec lab3_pg_b env PGPASSWORD=postgres psql \
  -h 127.0.0.1 \
  -U postgres \
  -d postgres \
  -c "
SELECT count(*) AS rows_on_pg_b
FROM stage2_test;
"

docker exec lab3_pg_c env PGPASSWORD=postgres psql \
  -h 127.0.0.1 \
  -U postgres \
  -d postgres \
  -c "
SELECT count(*) AS rows_on_pg_c
FROM stage2_test;
"

echo
echo "== Pgpool state =="

docker exec lab3_pgpool env PGPASSWORD=postgres psql \
  -h 127.0.0.1 \
  -p 9999 \
  -U postgres \
  -d postgres \
  -c "SHOW pool_nodes;"