CREATE USER "test-admin-user";
CREATE DATABASE test_db;
\c test_db;
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    goods VARCHAR(50) NOT NULL,
    price INT NOT NULL
);
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    sourname VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL,
    ordersid INT REFERENCES orders(id)
);
GRANT ALL PRIVILEGES ON orders, clients TO "test-admin-user";
CREATE USER "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";
