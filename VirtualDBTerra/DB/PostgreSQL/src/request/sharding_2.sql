BEGIN;
ALTER TABLE orders RENAME TO orders2;

CREATE TABLE orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);

CREATE TABLE orders_1 (
    CHECK ( price > 499 )
) INHERITS (orders);

CREATE TABLE orders_2 (
    CHECK ( price <= 499 )
) INHERITS (orders);

CREATE INDEX orders_1_price ON orders_1 (price);
CREATE INDEX orders_2_price ON orders_2 (price);

CREATE OR REPLACE FUNCTION orders_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF ( NEW.price > 499 ) THEN
        INSERT INTO orders_1 VALUES (NEW.*);
    ELSIF ( NEW.price <= 499 ) THEN
        INSERT INTO orders_2 VALUES (NEW.*);
    END IF;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER insert_orders_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION orders_insert_trigger();

INSERT INTO orders SELECT * FROM orders2;
DROP TABLE orders2;
COMMIT;
