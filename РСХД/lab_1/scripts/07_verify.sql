SELECT 
    spcname AS tablespace_name,
    pg_tablespace_location(oid) AS location
FROM pg_tablespace;

-- Список объектов по табличным пространствам
SELECT 
    t.spcname AS tablespace_name,
    c.relname AS object_name,
    c.relkind AS object_type
FROM pg_class c
JOIN pg_tablespace t ON c.reltablespace = t.oid
WHERE c.reltablespace > 0
ORDER BY t.spcname, c.relname;

-- Информация о партициях
SELECT 
    inhrelid::regclass AS partition_name,
    pg_get_expr(relpartbound, inhrelid) AS partition_bound,
    (SELECT spcname FROM pg_tablespace WHERE oid = reltablespace) AS tablespace
FROM pg_inherits
JOIN pg_class ON inhrelid = pg_class.oid
WHERE inhparent = 'sales'::regclass;

SELECT 
    'kls10' AS tablespace,
    relname AS object_name,
    relkind AS object_type
FROM pg_class
WHERE reltablespace = (SELECT oid FROM pg_tablespace WHERE spcname = 'kls10')
ORDER BY relname;

SELECT 
    'opy85' AS tablespace,
    relname AS object_name,
    relkind AS object_type
FROM pg_class
WHERE reltablespace = (SELECT oid FROM pg_tablespace WHERE spcname = 'opy85')
ORDER BY relname;