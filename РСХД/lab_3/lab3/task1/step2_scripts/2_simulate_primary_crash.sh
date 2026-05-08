#!/usr/bin/env bash
set -euo pipefail

echo '== Simulating sudden primary crash =='

docker stop -t 0 lab3_pg_a

echo '== Primary node stopped =='