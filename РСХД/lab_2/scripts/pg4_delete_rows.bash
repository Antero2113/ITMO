#!/usr/local/bin/bash

export PGUSER=testuser
export PGDATABASE=loudwhiteuser

psql -p 9746 -U $PGUSER -d $PGDATABASE <<EOF
DELETE FROM sales WHERE id = (SELECT MAX(id) FROM sales);
DELETE FROM products WHERE id = (SELECT MAX(id) FROM products);

SELECT * FROM products ORDER BY id;
SELECT * FROM sales ORDER BY id;
EOF