#!/usr/bin/env bash
set -euo pipefail

echo "STEP 1 - start pg_a"
docker compose up -d pg_a

echo "WAIT pg_a"
until docker exec lab3_pg_a pg_isready -U postgres; do sleep 2; done

echo "BOOTSTRAP ROLE"
docker exec -i lab3_pg_a psql -U postgres -c "
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='replicator') THEN
    CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator';
  END IF;
END
\$\$;
"

echo "CREATE DB"
docker exec -i lab3_pg_a psql -U postgres -c "CREATE DATABASE appdb" || true

echo "INIT SCHEMA"
docker exec -i lab3_pg_a psql -U postgres -d appdb <<'SQL'
CREATE TABLE IF NOT EXISTS customers (
    id BIGSERIAL PRIMARY KEY,
    full_name TEXT,
    city TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT,
    product_name TEXT,
    amount NUMERIC(10,2),
    created_at TIMESTAMPTZ DEFAULT now()
);
SQL

echo "CREATE SLOTS"
docker exec -i lab3_pg_a psql -U postgres -d postgres <<'SQL'
SELECT pg_create_physical_replication_slot('slot_b')
WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name='slot_b');

SELECT pg_create_physical_replication_slot('slot_c')
WHERE NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name='slot_c');
SQL

echo "COPY CONFIGS INTO PG_A DATA DIR"

docker exec -u root lab3_pg_a bash -lc "
cp /etc/postgresql/custom/postgresql.conf \$PGDATA/postgresql.conf
cp /etc/postgresql/custom/pg_hba.conf \$PGDATA/pg_hba.conf
chown -R postgres:postgres \$PGDATA
"

echo "RESTART PRIMARY"
docker restart lab3_pg_a
sleep 5

echo "START REPLICAS"
docker compose up -d pg_b pg_c
docker compose up -d pgpool client