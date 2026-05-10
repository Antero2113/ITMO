#!/usr/bin/env bash
set -euo pipefail

echo
echo "== FAILBACK: pg_a -> STANDBY =="
echo

echo "== step 1: stop old primary (pg_a) =="

echo "Stopping pg_a..."
docker stop lab3_pg_a

echo
echo "== step 2: prepare pg_a data directory =="

echo "Cleaning pg_a volume..."

echo
echo "== step 3: start pg_a container =="

docker start lab3_pg_a

echo
echo "== step 4: sync pg_a with new primary (pg_b) =="

docker exec -u postgres lab3_pg_b psql -c "
ALTER ROLE replicator WITH SUPERUSER;
"

docker exec -u postgres lab3_pg_a bash -lc "
/usr/lib/postgresql/16/bin/pg_ctl \
-D /var/lib/postgresql/data \
stop -m immediate
"

docker exec -u root lab3_pg_a bash -lc "rm -f /var/lib/postgresql/data/postmaster.pid"

docker exec -u postgres lab3_pg_a bash -lc "
/usr/lib/postgresql/16/bin/pg_rewind -D /var/lib/postgresql/data \
--source-server='host=pg_b port=5432 dbname=postgres user=replicator password=replicator'
"

docker restart lab3_pg_a

echo
echo "== step 5: configure pg_a as standby =="

docker exec -u postgres lab3_pg_a bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

docker exec -u postgres lab3_pg_a bash -lc "
echo \"primary_conninfo = 'host=pg_b port=5432 user=replicator password=replicator'\" >> /var/lib/postgresql/data/postgresql.auto.conf
"

docker restart lab3_pg_a

echo
echo "== step 6: restart pgpool =="

docker restart lab3_pgpool

sleep 10

echo
echo "== final cluster state =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== DONE: pg_a successfully reattached as standby of pg_b =="