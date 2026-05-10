# Lab3 | PostgreSQL cascade replication

## Topology

* pg_a — primary
* pg_b — synchronous standby
* pg_c — asynchronous standby (replication delay: 10s)
* pgpool — load balancer / routing endpoint (port 9999)
* client — dedicated container for SQL execution and demo flows

---

## System overview

### Primary node (pg_a)

Responsibilities:

* cluster initialization
* creation of replication user `replicator`
* creation of test schema and initial data
* creation of physical replication slots:

  * slot_b → pg_b
  * slot_c → pg_c

---

### Standby node (pg_b)

* initialized via `pg_basebackup` from pg_a
* configured as synchronous standby
* `application_name = pg_b`

---

### Cascading standby (pg_c)

* initialized via `pg_basebackup` from pg_a
* asynchronous replication
* delayed apply configured:

  * `recovery_min_apply_delay = '10s'`
* `application_name = pg_c`

---

### Pgpool

* unified entry point for client traffic
* port: 9999
* provides cluster routing and node visibility via `show pool_nodes`

---

## Startup

```bash
start.cmd
```

---

## Cluster state check

```bash
docker compose ps
```

---

## Logs (primary debugging)

```bash
docker compose logs pg_a
docker compose logs pg_b
docker compose logs pg_c
docker compose logs pgpool
```

---

## Node role verification

```bash
docker exec -u postgres lab3_pg_a psql -c "select pg_is_in_recovery();"
docker exec -u postgres lab3_pg_b psql -c "select pg_is_in_recovery();"
docker exec -u postgres lab3_pg_c psql -c "select pg_is_in_recovery();"
```

Expected:

* pg_a → f (primary)
* pg_b → t (standby)
* pg_c → t (standby)

---

## Replication status (primary)

```bash
docker exec -u postgres lab3_pg_a psql -c "
select application_name, state, sync_state
from pg_stat_replication
order by application_name;
"
```

Expected:

* pg_b → sync
* pg_c → async

---

## Replication slots

```bash
docker exec -u postgres lab3_pg_a psql -c "select * from pg_replication_slots;"
```

---

## System configuration snapshot

```bash
docker exec -e PGPASSWORD=postgres -u postgres lab3_pg_a psql -U postgres -c "
select name, setting
from pg_settings
order by name;
"
```

---

## Pgpool status

```bash
docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -c "show pool_nodes;"
```

---

## Demo execution

```bash
./demo.sh
```

### Validates:

* write routing via pgpool
* synchronous replication (pg_b)
* delayed async replication (pg_c)
* replication lag visibility (≈10–12s)
* eventual consistency across nodes

---

## Manual validation

### Connect via pgpool

```bash
docker exec -e PGPASSWORD=postgres -u postgres lab3_client \
psql -h pgpool -p 9999 -U postgres -d postgres
```

---

### Role checks

```bash
docker exec -u postgres lab3_pg_a psql -c "select pg_is_in_recovery();"
docker exec -u postgres lab3_pg_b psql -c "select pg_is_in_recovery();"
docker exec -u postgres lab3_pg_c psql -c "select pg_is_in_recovery();"
```

---

### Data verification

```bash
docker exec -u postgres lab3_pg_b psql -c "select * from customers order by id desc limit 5;"
docker exec -u postgres lab3_pg_c psql -c "select * from customers order by id desc limit 5;"
```


---

## Reset environment

```bash
./reset.sh
./start.sh
```
