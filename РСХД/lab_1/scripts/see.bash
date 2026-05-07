#!/usr/local/bin/bash
psql -p 9746 -d loudwhiteuser -U testuser -f 07_verify.sql
