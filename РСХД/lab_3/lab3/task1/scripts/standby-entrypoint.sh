#!/usr/bin/env bash
set -euo pipefail

export PGDATA="${PGDATA:-/var/lib/postgresql/data}"
PRIMARY_HOST="${PRIMARY_HOST:?PRIMARY_HOST is required}"
PRIMARY_PORT="${PRIMARY_PORT:-5432}"
REPLICATION_USER="${REPLICATION_USER:-replicator}"
REPLICATION_PASSWORD="${REPLICATION_PASSWORD:-replicator}"
REPLICATION_SLOT="${REPLICATION_SLOT:?REPLICATION_SLOT is required}"
STANDBY_NAME="${STANDBY_NAME:?STANDBY_NAME is required}"
APPLY_DELAY="${APPLY_DELAY:-0s}"
DOWNSTREAM_SLOT="${DOWNSTREAM_SLOT:-}"

if [ ! -f "$PGDATA/standby.signal" ] && [ ! -s "$PGDATA/postgresql.auto.conf" ]; then
  echo "[standby] Waiting for primary ${PRIMARY_HOST}:${PRIMARY_PORT}..."
  until pg_isready -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U postgres -d postgres >/dev/null 2>&1; do
    sleep 2
  done

  echo "[standby] Taking base backup for ${STANDBY_NAME}..."
  rm -rf "${PGDATA:?}"/*
  export PGPASSWORD="$REPLICATION_PASSWORD"
  pg_basebackup \
    -h "$PRIMARY_HOST" \
    -p "$PRIMARY_PORT" \
    -U "$REPLICATION_USER" \
    -D "$PGDATA" \
    -R \
    -X stream \
    -S "$REPLICATION_SLOT" \
    -c fast

  {
    echo "primary_conninfo = 'host=${PRIMARY_HOST} port=${PRIMARY_PORT} user=${REPLICATION_USER} password=${REPLICATION_PASSWORD} application_name=${STANDBY_NAME}'"
    echo "primary_slot_name = '${REPLICATION_SLOT}'"
    echo "recovery_min_apply_delay = '${APPLY_DELAY}'"
  } >> "$PGDATA/postgresql.auto.conf"

  cp /etc/postgresql/custom/postgresql.conf "$PGDATA/postgresql.conf"
  cp /etc/postgresql/custom/pg_hba.conf "$PGDATA/pg_hba.conf"
  chown -R postgres:postgres "$PGDATA"
  chmod 700 "$PGDATA"
fi

su postgres -c "
postgres \
  -c 'config_file=$PGDATA/postgresql.conf' \
  -c 'hba_file=$PGDATA/pg_hba.conf'
" &

pg_pid=$!

until pg_isready -h 127.0.0.1 -p 5432 -U postgres >/dev/null 2>&1; do
  sleep 1
done

if [ -n "${DOWNSTREAM_SLOT:-}" ]; then
  echo "[standby] Creating downstream replication slot ${DOWNSTREAM_SLOT}"

su postgres -c "psql -U postgres -d postgres" <<SQL
SELECT pg_create_physical_replication_slot('${DOWNSTREAM_SLOT}')
WHERE NOT EXISTS (
  SELECT 1
  FROM pg_replication_slots
  WHERE slot_name='${DOWNSTREAM_SLOT}'
);
SQL
fi

pg_pid=$!
wait "$pg_pid"