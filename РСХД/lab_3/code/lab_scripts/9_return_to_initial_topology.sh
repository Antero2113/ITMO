#!/usr/bin/env bash
set -euo pipefail

echo
echo "== STEP 1: REBUILD pg_b AS STANDBY OF pg_a =="
echo

echo "== stop old pg_b =="

docker stop lab3_pg_b

echo
echo "== check pg_a state =="

docker exec -u postgres lab3_pg_a psql -c "SELECT pg_is_in_recovery();"

echo
echo "== create replication slot slot_b on pg_a =="

docker exec -u postgres lab3_pg_a psql -c "
SELECT pg_create_physical_replication_slot('slot_b');
"

docker exec -u postgres lab3_pg_a \
psql -U postgres -d postgres -c "
ALTER SYSTEM SET synchronous_standby_names = 'pg_b';
"

docker exec -u postgres lab3_pg_a \
psql -U postgres -d postgres -c "
SELECT pg_reload_conf();
"

echo
echo "== start pg_b container =="

docker start lab3_pg_b

echo
echo "== rebuild pg_b from pg_a (pg_basebackup) =="

docker exec -u root lab3_pg_b bash -lc "
rm -rf /var/lib/postgresql/data/*

export PGPASSWORD=replicator
export PGAPPNAME=pg_b

pg_basebackup \
  -h lab3_pg_a \
  -U replicator \
  -D /var/lib/postgresql/data \
  -P -R \
  -X stream \
  -S slot_b \
  -c fast

chown -R postgres:postgres /var/lib/postgresql/data
"

echo
echo "== mark pg_b as standby =="

docker exec -u postgres lab3_pg_b bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

echo
echo "== restart pg_b and pgpool =="

docker restart lab3_pg_b
docker restart lab3_pgpool

echo
echo "== wait for replication stabilization =="

sleep 10

echo
echo "== pgpool node status =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== DONE: pg_a is primary, pg_b is standby and fully resynced =="