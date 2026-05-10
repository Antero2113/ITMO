#!/usr/bin/env bash
set -euo pipefail

echo
echo "== POSTGRES LOG CHECK =="
echo

echo "== COLLECT LOGS =="

docker compose logs --since 10m pg_a pg_b pg_c | \
grep -Ei \
'terminating|FATAL|PANIC|could not connect|connection lost|database system is shut down|invalid record length|waiting for WAL|promoted|redo done|selected new timeline|checkpoint'

echo
echo "== DONE: log analysis completed successfully =="