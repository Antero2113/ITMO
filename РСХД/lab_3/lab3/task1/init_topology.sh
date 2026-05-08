#!/usr/bin/env bash
set -euo pipefail

echo "== INIT CASCADE TOPOLOGY =="

export PGPASSWORD=postgres

# pg_a → slot_b (для pg_b)
psql -h pg_a -U postgres -d postgres <<'SQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name='slot_b') THEN
    PERFORM pg_create_physical_replication_slot('slot_b');
  END IF;
END $$;
SQL

# pg_b → slot_c (для pg_c)
psql -h pg_b -U postgres -d postgres <<'SQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name='slot_c') THEN
    PERFORM pg_create_physical_replication_slot('slot_c');
  END IF;
END $$;
SQL

echo "== CASCADE INIT DONE =="