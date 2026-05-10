#!/usr/bin/env bash
set -euo pipefail

echo
echo "== FAILOVER TEST: PRIMARY CRASH =="
echo

echo "== Step 1: Simulate primary failure =="

echo "Stopping primary node pg_a..."
docker stop lab3_pg_a

echo
echo "== DONE: Primary pg_a stopped, failover simulation triggered =="