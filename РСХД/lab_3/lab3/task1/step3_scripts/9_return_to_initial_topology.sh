#!/usr/bin/env bash
set -euo pipefail

echo "== STEP 1: PROMOTE pg_a =="

docker exec lab3_pg_a env PGPASSWORD=postgres \
psql -h 127.0.0.1 -U postgres -d postgres \
-c "SELECT pg_promote(wait_seconds => 60);"

sleep 5

echo
echo "== STEP 2: VERIFY pg_a is primary =="

docker exec lab3_pg_a env PGPASSWORD=postgres \
psql -h 127.0.0.1 -U postgres -d postgres \
-t -A -c "SELECT NOT pg_is_in_recovery();"

echo
echo "== STEP 3: CREATE slot for pg_b =="

docker exec lab3_pg_a env PGPASSWORD=postgres \
psql -h 127.0.0.1 -U postgres -d postgres \
-c "
SELECT pg_drop_replication_slot('slot_b')
WHERE EXISTS (
  SELECT 1 FROM pg_replication_slots WHERE slot_name='slot_b'
);
" || true

docker exec lab3_pg_a env PGPASSWORD=postgres \
psql -h 127.0.0.1 -U postgres -d postgres \
-c "SELECT pg_create_physical_replication_slot('slot_b');"

echo
echo "== STEP 4: STOP pg_b (no delete) =="

docker stop lab3_pg_b || true

echo
echo "== STEP 5: CLEAN pg_b DATA volume =="

docker volume rm task1_pg_b_data || true
docker volume create task1_pg_b_data

echo
echo "== STEP 6: BASEBACKUP pg_b FROM pg_a (inside network) =="

docker run --rm \
  --network task1_pgnet \
  -v task1_pg_b_data:/var/lib/postgresql/data \
  postgres:16 \
  bash -c "
set -e
rm -rf /var/lib/postgresql/data/*

PGPASSWORD=replicator pg_basebackup \
  -h pg_a \
  -U replicator \
  -D /var/lib/postgresql/data \
  -X stream \
  -R \
  -S slot_b

chown -R 999:999 /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data
"

echo
echo "== STEP 7: START pg_b via compose =="

docker compose up -d pg_b

echo
echo "== DONE: pg_a primary, pg_b standby =="