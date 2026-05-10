#!/bin/bash

set -e

echo
echo "== FINAL CHECK: FULL REPLICATION TEST =="
echo

echo "== topology (pgpool nodes) =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"

echo
echo "== create tables =="

docker exec -i -e PGPASSWORD=postgres -u postgres lab3_client \
psql -a -e -h pgpool -p 9999 -U postgres postgres <<EOF

CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    owner TEXT,
    balance INT
);

CREATE TABLE IF NOT EXISTS operations (
    id SERIAL PRIMARY KEY,
    account_id INT,
    operation_type TEXT,
    amount INT,
    created_at TIMESTAMP DEFAULT now()
);

EOF

echo
echo "== insert data =="

docker exec -i -e PGPASSWORD=postgres -u postgres lab3_client \
psql -a -e -h pgpool -p 9999 -U postgres postgres <<EOF

BEGIN;

INSERT INTO accounts(owner, balance)
VALUES
('Alice', 1000),
('Bob', 500);

INSERT INTO operations(account_id, operation_type, amount)
VALUES
(1, 'deposit', 1000),
(2, 'deposit', 500);

COMMIT;

EOF

echo
echo "== update data =="

docker exec -i -e PGPASSWORD=postgres -u postgres lab3_client \
psql -a -e -h pgpool -p 9999 -U postgres postgres <<EOF

BEGIN;

UPDATE accounts
SET balance = balance - 200
WHERE id = 1;

UPDATE accounts
SET balance = balance + 200
WHERE id = 2;

INSERT INTO operations(account_id, operation_type, amount)
VALUES
(1, 'transfer_out', 200),
(2, 'transfer_in', 200);

COMMIT;

EOF

echo
echo "== read through pgpool =="

docker exec -i -e PGPASSWORD=postgres -u postgres lab3_client \
psql -a -e -h pgpool -p 9999 -U postgres postgres <<EOF

SELECT * FROM accounts ORDER BY id;

SELECT * FROM operations ORDER BY id;

EOF

echo
echo "== primary node (pg_a) =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_pg_a \
psql -U postgres -c "
select pg_is_in_recovery();

select * from accounts order by id;

select * from operations order by id;
"

echo
echo "== standby node (pg_b) =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_pg_b \
psql -U postgres -c "
select pg_is_in_recovery();

select * from accounts order by id;

select * from operations order by id;
"

echo
echo "== wait for async replication =="

sleep 12

echo
echo "== cascade standby (pg_c) =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_pg_c \
psql -U postgres -c "
select pg_is_in_recovery();

select * from accounts order by id;

select * from operations order by id;
"

echo
echo "== replication status (pg_a) =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_pg_a \
psql -U postgres -c "
select
    application_name,
    state,
    sync_state
from pg_stat_replication;
"

echo
echo "== replication status (pg_b) =="

docker exec -e PGPASSWORD=postgres -u postgres lab3_pg_b \
psql -U postgres -c "
select
    application_name,
    state,
    sync_state
from pg_stat_replication;
"

echo
echo "== DONE: full read/write/replication verification completed successfully =="