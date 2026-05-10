#!/usr/bin/env bash
set -euo pipefail

PG="docker exec lab3_pg_b env PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -d postgres"

echo
echo "== REPLICATION SLOT RESET =="
echo

echo "== check pg_b is primary =="

IS_PRIMARY=$($PG -t -A -c "SELECT NOT pg_is_in_recovery();")

if [ "$IS_PRIMARY" != "t" ]; then
  echo "ERROR: pg_b is not primary"
  exit 1
fi

echo "pg_b is primary: OK"

echo
echo "== recreate slot slot_a =="

$PG -c "
SELECT pg_drop_replication_slot('slot_a')
WHERE EXISTS (
  SELECT 1
  FROM pg_replication_slots
  WHERE slot_name='slot_a'
);
" || true

$PG -c "SELECT pg_create_physical_replication_slot('slot_a');"

echo
echo "== verify replication slots =="

$PG -x -c "
SELECT slot_name, active
FROM pg_replication_slots;
"

echo
echo "== DONE: replication slot slot_a recreated on pg_b =="