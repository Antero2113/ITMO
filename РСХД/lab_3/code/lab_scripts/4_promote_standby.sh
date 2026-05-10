#!/usr/bin/env bash
set -euo pipefail

echo
echo "== PG_B ROLE CHECK / PROMOTE =="
echo

echo "== check recovery state =="

state=$(docker exec -u postgres lab3_pg_b \
  psql -t -A -U postgres -d postgres \
  -c "SELECT pg_is_in_recovery();")

echo "pg_is_in_recovery=$state"

if [ "$state" = "t" ]; then
  echo
  echo "== promoting pg_b =="

  docker exec -u postgres lab3_pg_b \
    psql -U postgres -d postgres \
    -c "SELECT pg_promote(wait_seconds => 60);"
else
  echo
  echo "== already primary =="
fi

echo
echo "== final state check =="

docker exec -u postgres lab3_pg_b \
  psql -U postgres -d postgres \
  -c "SELECT pg_is_in_recovery();"

echo
echo "== DONE: pg_b role verified, promotion executed if required =="