DROP TABLE IF EXISTS sales CASCADE;
CREATE TABLE sales (
    id SERIAL,
    sale_date DATE NOT NULL,
    amount DECIMAL(10,2),
    product_id INTEGER
) PARTITION BY RANGE (sale_date);

CREATE TABLE sales_2024_q1 PARTITION OF sales
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01')
    TABLESPACE kls10;

CREATE TABLE sales_2024_q2 PARTITION OF sales
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01')
    TABLESPACE opy85;

CREATE TABLE sales_2024_q3 PARTITION OF sales
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01')
    TABLESPACE kls10;

CREATE TABLE sales_2024_q4 PARTITION OF sales
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01')
    TABLESPACE opy85;

INSERT INTO sales (sale_date, amount, product_id) VALUES
    ('2024-01-15', 100.50, 1),
    ('2024-02-20', 200.75, 2),
    ('2024-03-10', 150.25, 1),
    ('2024-04-05', 300.00, 3),
    ('2024-05-12', 250.50, 2),
    ('2024-06-18', 175.80, 1),
    ('2024-07-22', 400.20, 4),
    ('2024-08-30', 350.00, 3),
    ('2024-09-14', 225.90, 2),
    ('2024-10-01', 500.00, 5),
    ('2024-11-11', 275.60, 1),
    ('2024-12-25', 600.00, 4);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10,2)
) TABLESPACE kls10;

CREATE INDEX idx_sales_amount ON sales(amount) TABLESPACE opy85;

INSERT INTO products (name, price) VALUES
    ('Product A', 100.00),
    ('Product B', 200.00),
    ('Product C', 300.00),
    ('Product D', 400.00),
    ('Product E', 500.00);


