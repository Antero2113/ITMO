#!/usr/local/bin/bash

export PGUSER=testuser
export PGDATABASE=loudwhiteuser

psql -p 9746 -U $PGUSER -d $PGDATABASE <<EOF
INSERT INTO products (name, price) VALUES
('prodA', 10.5),
('prodB', 11.0),
('prodC', 12.0);

INSERT INTO sales (sale_date, amount, product_id) VALUES
('2024-01-15', 20.00, 1),
('2024-02-15', 35.50, 2),
('2024-03-15', 50.00, 3);

SELECT * FROM products ORDER BY id;
SELECT * FROM sales ORDER BY id;
EOF

date "+%Y-%m-%d %H:%M:%S" > ~/pg4_time.txt