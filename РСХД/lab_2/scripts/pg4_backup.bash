#!/usr/local/bin/bash

export PGDATA=$HOME/zfb92
export BASE_BACKUP=$HOME/base_backup_pg4

rm -rf $BASE_BACKUP
mkdir -p $BASE_BACKUP

pg_basebackup -D $BASE_BACKUP -Ft -z -P -U postgres2