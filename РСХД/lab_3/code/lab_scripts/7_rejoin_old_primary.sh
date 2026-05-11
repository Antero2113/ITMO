#!/usr/bin/env bash
set -euo pipefail

echo
echo "== FAILBACK: pg_a -> STANDBY =="
echo

echo "== step 1: stop old primary (pg_a) =="

echo "Stopping pg_a..."
docker stop lab3_pg_a


echo
echo "== step 2: start pg_a container =="

docker start lab3_pg_a

echo
echo "== rebuild pg_a from pg_b (pg_basebackup) =="

docker exec -u root lab3_pg_a bash -lc "
rm -rf /var/lib/postgresql/data/*

export PGPASSWORD=replicator

pg_basebackup \
  -h lab3_pg_b \
  -U replicator \
  -D /var/lib/postgresql/data \
  -P -R \
  -X stream \
  -S slot_a \
  -c fast

chown -R postgres:postgres /var/lib/postgresql/data
"

docker restart lab3_pg_a

echo
echo "== step 4: configure pg_a as standby =="

docker exec -u postgres lab3_pg_a bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

docker restart lab3_pg_a

echo
echo "== step 5: restart pgpool =="

docker restart lab3_pgpool

sleep 10

echo
echo "== final cluster state =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== DONE: pg_a successfully reattached as standby of pg_b =="