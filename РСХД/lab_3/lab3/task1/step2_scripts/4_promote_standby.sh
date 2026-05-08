#!/usr/bin/env bash
set -euo pipefail

echo '== Checking pg_b recovery state =='

state=$(docker exec -u postgres lab3_pg_b \
  psql -t -A -U postgres -d postgres \
  -c "SELECT pg_is_in_recovery();")

echo "pg_is_in_recovery=$state"

if [ "$state" = "t" ]; then
  echo
  echo '== Promoting pg_b to primary =='

  docker exec -u postgres lab3_pg_b \
    psql -U postgres -d postgres \
    -c "SELECT pg_promote(wait_seconds => 60);"

else
  echo
  echo '== pg_b is already primary =='
fi

echo
echo '== Final role check =='

docker exec -u postgres lab3_pg_b \
  psql -U postgres -d postgres \
  -c "SELECT pg_is_in_recovery();"