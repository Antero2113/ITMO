#!/usr/local/bin/bash

pg_ctl -D $HOME/zfb92 restart

sleep 2

psql -p 9746 -U testuser -d loudwhiteuser -c "SELECT version();"
psql -p 9746 -U testuser -d loudwhiteuser -c "\l"
psql -p 9746 -U testuser -d loudwhiteuser -c "\dt"
psql -p 9746 -U testuser -d loudwhiteuser -c "SELECT spcname FROM pg_tablespace;"
