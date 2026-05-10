#!/usr/bin/env sh

set -e

docker compose up -d --build

echo "Cluster is starting."
echo "Check readiness with: docker compose ps"
echo "Then run: ./demo.sh"