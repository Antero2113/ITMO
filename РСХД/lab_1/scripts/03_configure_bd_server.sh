#!/bin/bash

cat > $HOME/zfb92/postgresql.conf << 'EOF'

port = 9746
listen_addresses = 'localhost'
max_connections = 7

shared_buffers = 512MB
temp_buffers = 64MB
work_mem = 128MB
effective_cache_size = 2GB

fsync = on
commit_delay = 100000
checkpoint_timeout = 30min

log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql.log'
log_min_messages = ERROR
log_disconnections = on
log_duration = on
EOF

mkdir -p /var/db/postgres2/kls10
mkdir -p /var/db/postgres2/opy85