#!/usr/bin/env bash
set -euo pipefail

echo "== Stop old pg_a =="

docker rm -f lab3_pg_a || true

echo "== Recreate clean volume =="

docker volume rm task1_pg_a_data || true
docker volume create task1_pg_a_data

echo "== Create basebackup from pg_b =="

docker run --rm \
  --network task1_pgnet \
  -v task1_pg_a_data:/var/lib/postgresql/data \
  postgres:16 \
  bash -c "
set -e

rm -rf /var/lib/postgresql/data/*

PGPASSWORD=replicator pg_basebackup \
  -h pg_b \
  -p 5432 \
  -U replicator \
  -D /var/lib/postgresql/data \
  -R \
  -X stream \
  -S slot_a

chown -R 999:999 /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data
"

echo "== Start pg_a as standby =="

docker run -d \
  --name lab3_pg_a \
  --network task1_pgnet \
  -p 9437:5432 \
  -e PRIMARY_HOST=pg_b \
  -e PRIMARY_PORT=5432 \
  -e REPLICATION_USER=replicator \
  -e REPLICATION_PASSWORD=replicator \
  -e REPLICATION_SLOT=slot_a \
  -e STANDBY_NAME=pg_a \
  -e APPLY_DELAY=0s \
  -e PGDATA=/var/lib/postgresql/data \
  -v task1_pg_a_data:/var/lib/postgresql/data \
  -v $(pwd)/standby/conf:/etc/postgresql/custom:ro \
  task1-pg_a \
  /usr/local/bin/standby-entrypoint.sh

echo
echo "== pg_a restarted as standby of pg_b =="