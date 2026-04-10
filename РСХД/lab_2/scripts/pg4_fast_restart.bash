#!/usr/local/bin/bash

export PGUSER=testuser
export PGDATABASE=loudwhiteuser

psql -p 9746 -U $PGUSER -d $PGDATABASE <<EOF
DELETE FROM sales WHERE id IN (
    SELECT id FROM sales ORDER BY id DESC LIMIT 2
);

DELETE FROM products WHERE id IN (
    SELECT id FROM products ORDER BY id DESC LIMIT 2
);

SELECT * FROM products ORDER BY id;
SELECT * FROM sales ORDER BY id;
EOF