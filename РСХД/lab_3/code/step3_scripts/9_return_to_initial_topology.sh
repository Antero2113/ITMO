#!/usr/bin/env bash
set -euo pipefail

echo "== STEP 1: PROMOTE pg_a =="

docker stop lab3_pg_b

docker exec -u postgres lab3_pg_a psql -c "SELECT pg_is_in_recovery();"
docker exec -u postgres lab3_pg_a psql -c "
SELECT pg_create_physical_replication_slot('slot_b');
"

docker start lab3_pg_b
# docker exec -u postgres lab3_pg_b bash -lc "
# /usr/lib/postgresql/16/bin/pg_ctl \
# -D /var/lib/postgresql/data \
# stop -m immediate
# "
# docker exec -u root lab3_pg_b bash -lc "rm -f /var/lib/postgresql/data/postmaster.pid"

# docker exec -u postgres lab3_pg_b bash -lc "
# /usr/lib/postgresql/16/bin/pg_rewind -D /var/lib/postgresql/data \
# --source-server='host=pg_a port=5432 dbname=postgres user=replicator password=replicator'
# "

docker exec -u root lab3_pg_b bash -lc "rm -rf /var/lib/postgresql/data/*"
docker exec -u postgres -e PGPASSWORD=replicator lab3_pg_b bash -lc "
pg_basebackup -h lab3_pg_a -U replicator -D /var/lib/postgresql/data -P -R"

docker exec -u postgres lab3_pg_b bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

docker exec -u postgres lab3_pg_b bash -lc "
echo \"primary_conninfo = 'host=pg_a port=5432 user=replicator password=replicator'\" >> /var/lib/postgresql/data/postgresql.auto.conf
"

docker restart lab3_pg_b
docker restart lab3_pgpool

# docker run --rm \
# -v task1_pg_b_data:/var/lib/postgresql/data \
# bash bash -lc "
# cat > /var/lib/postgresql/data/postgresql.auto.conf <<'EOF'
# primary_conninfo = 'host=pg_a port=5432 user=replicator password=replicator application_name=pg_b'
# primary_slot_name = 'slot_c'
# recovery_min_apply_delay = '0s'
# EOF
# "

sleep 10

docker exec -e PGPASSWORD=postgres -u postgres lab3_client psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== DONE: pg_a primary, pg_b standby =="


docker exec -u root lab3_pg_c bash -lc "rm -rf /var/lib/postgresql/data/*"
docker exec -u postgres -e PGPASSWORD=replicator lab3_pg_c bash -lc "
pg_basebackup -h lab3_pg_b -U replicator -D /var/lib/postgresql/data -P -R"

docker exec -u postgres lab3_pg_c bash -lc "
touch /var/lib/postgresql/data/standby.signal
"

docker run --rm \
-v task1_pg_c_data:/var/lib/postgresql/data \
busybox sh -c "
cp /var/lib/postgresql/data/postgresql.auto.conf /tmp/backup.conf && \
grep -v 'primary_conninfo\|primary_slot_name\|recovery_min_apply_delay' \
/tmp/backup.conf \
> /var/lib/postgresql/data/postgresql.auto.conf
"

docker run --rm \
-v task1_pg_c_data:/var/lib/postgresql/data \
busybox sh -c "
echo \"primary_conninfo = 'host=pg_b port=5432 user=replicator password=replicator application_name=pg_c'\" >> /var/lib/postgresql/data/postgresql.auto.conf

echo \"primary_slot_name = 'slot_c'\" >> /var/lib/postgresql/data/postgresql.auto.conf

echo \"recovery_min_apply_delay = '10s'\" >> /var/lib/postgresql/data/postgresql.auto.conf
"

docker restart lab3_pg_c
docker restart lab3_pgpool

sleep 10

docker exec -e PGPASSWORD=postgres -u postgres lab3_client psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== DONE: pg_c replication rebuilded =="