#!/usr/bin/env bash
set -euo pipefail

echo '== Simulating sudden primary crash =='

docker stop lab3_pg_a

echo '== Primary node stopped =='