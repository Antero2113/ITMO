#!/usr/bin/env bash

for node in lab3_pg_a lab3_pg_b lab3_pg_c; do
  echo "==================== $node ===================="

  echo "--- replication slots ---"
  docker exec -u postgres $node psql -x -c "
    SELECT slot_name, slot_type, active, restart_lsn, confirmed_flush_lsn, wal_status
    FROM pg_replication_slots;
  "

  echo "--- replication status (if primary) ---"
  docker exec -u postgres $node psql -x -c "
    SELECT pid, usename, application_name, client_addr, state, sync_state,
           write_lag, flush_lag, replay_lag
    FROM pg_stat_replication;
  "

  echo "--- standby status ---"
  docker exec -u postgres $node psql -x -c "
    SELECT
      pg_is_in_recovery() AS is_standby,
      pg_last_wal_receive_lsn(),
      pg_last_wal_replay_lsn();
  "

  echo "--- replication config (IMPORTANT) ---"
  docker exec -u postgres $node psql -x -c "
    SELECT name, setting
    FROM pg_settings
    WHERE name IN (
      'primary_conninfo',
      'primary_slot_name',
      'hot_standby',
      'wal_level',
      'max_wal_senders',
      'max_replication_slots',
      'wal_keep_size',
      'recovery_min_apply_delay'
    );
  "

  echo "--- WAL receiver processes ---"
  docker exec -u postgres $node psql -x -c "
    SELECT pid, status, receive_start_lsn, latest_end_lsn, slot_name
    FROM pg_stat_wal_receiver;
  "

  echo
done