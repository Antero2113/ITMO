#!/usr/local/bin/bash

psql -p 9746 -U testuser -d loudwhiteuser -c "SELECT now();"
echo "exit code: $?"
