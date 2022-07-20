BEGIN;

ALTER TABLE orders RENAME TO orders2;

CREATE TABLE orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE(price);

CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (499) to (1000000);
CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (0) to (499);
INSERT INTO orders SELECT * FROM orders2;

DROP TABLE orders2;

COMMIT;
