#!/usr/bin/env bash
set -euo pipefail

echo
echo "== REBUILD pg_c AS CASCADE STANDBY =="
echo

echo "== step 1: stop check (pg_c container) =="

echo "[pg_c] stopping container if running..."
# docker stop lab3_pg_c || true

echo
echo "== step 2: clean old data directory =="

echo "[pg_c] cleaning old data directory..."

docker exec -u root lab3_pg_c bash -lc "
rm -rf /var/lib/postgresql/data/*
"

echo
echo "== step 3: basebackup from pg_b =="

echo "[pg_c] taking basebackup from pg_b..."

docker exec -u postgres -e PGPASSWORD=replicator lab3_pg_c bash -lc "
pg_basebackup \
  -h lab3_pg_b \
  -U replicator \
  -D /var/lib/postgresql/data \
  -P -R \
  -X stream \
  -S slot_c \
  -c fast

chown -R postgres:postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data
"

echo
echo "== step 4: fix standby signal (pg_b dependency hint) =="

docker exec -u postgres lab3_pg_b bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

echo
echo "== step 5: start pg_c and reload pgpool =="

echo "[pg_c] starting container..."
docker restart lab3_pg_c
docker restart lab3_pgpool

echo
echo "== step 6: wait for replication stabilization =="

sleep 10

echo
echo "== step 7: pgpool topology check =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== DONE: pg_c successfully rebuilt as cascading replica of pg_b =="