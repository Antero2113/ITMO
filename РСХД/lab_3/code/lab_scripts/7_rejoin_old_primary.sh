#!/usr/bin/env bash
set -euo pipefail

echo "== 1. stop pg_a (old primary) =="

echo "== 2. clean pg_a volume and up pg_a =="

echo "== 3. create basebackup from pg_b (current primary) =="

docker start lab3_pg_a

echo "== 4. do pg_rewind and restart pg_a =="

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

echo "== 5. replication signals =="


docker exec -u postgres lab3_pg_a bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

docker exec -u postgres lab3_pg_a bash -lc "
echo \"primary_conninfo = 'host=pg_b port=5432 user=replicator password=replicator'\" >> /var/lib/postgresql/data/postgresql.auto.conf
"

docker restart lab3_pg_a

echo "== 6. restart pgpool and show =="

docker restart lab3_pgpool

sleep 10

docker exec -e PGPASSWORD=postgres -u postgres lab3_client psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"


echo "== DONE =="
echo "pg_a should now be standby of pg_b"