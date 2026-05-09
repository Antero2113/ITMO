#!/usr/bin/env bash
set -euo pipefail

echo "== 1. stop pg_a (old primary) =="

docker compose stop pg_a || true
docker rm -f lab3_pg_a || true

echo "== 2. clean pg_a volume =="

docker volume rm pg_a_data || true
docker volume create pg_a_data

echo "== 3. create basebackup from pg_b (current primary) =="

docker run --rm \
  --network task1_pgnet \
  -u postgres \
  -e PGPASSWORD=replicator \
  -v pg_a_data:/var/lib/postgresql/data \
  postgres:16 \
  bash -lc "
set -e

rm -rf /var/lib/postgresql/data/*

pg_basebackup \
  -h pg_b \
  -p 5432 \
  -U replicator \
  -D /var/lib/postgresql/data \
  -X stream \
  -R \
  -S slot_a
"

echo "== 4. start pg_a as standby via compose =="

docker compose up -d pg_a

echo "== DONE =="
echo "pg_a should now be standby of pg_b"