#!/usr/bin/env bash
set -euo pipefail

echo
echo "== NODE ROLE AND REPLICATION CHECK =="
echo

check_node () {
  local node=$1

  echo
  echo "== node: $node =="

  docker exec lab3_$node \
    env PGPASSWORD=postgres \
    psql \
      -h 127.0.0.1 \
      -U postgres \
      -d postgres \
      -t -A \
      -c "
SELECT
  CASE
    WHEN pg_is_in_recovery()
    THEN 'standby'
    ELSE 'primary'
  END;
"
}

echo
echo "== node roles =="

check_node pg_a
check_node pg_b
check_node pg_c

echo
echo "== replication state (pg_b as upstream) =="

docker exec lab3_pg_b \
  env PGPASSWORD=postgres \
  psql \
    -h 127.0.0.1 \
    -U postgres \
    -d postgres \
    -x \
    -c "
SELECT
  application_name,
  client_addr,
  state,
  sync_state
FROM pg_stat_replication;
"

echo
echo "== replication slots (pg_b) =="

docker exec lab3_pg_b \
  env PGPASSWORD=postgres \
  psql \
    -h 127.0.0.1 \
    -U postgres \
    -d postgres \
    -c "
SELECT slot_name, active
FROM pg_replication_slots;
"

echo
echo "== DONE: replication topology inspected successfully =="