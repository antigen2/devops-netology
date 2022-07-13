# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

### Ответ
Листинг файла <code>docker-compose.yml</code>:
```yaml
version: '2.1'

networks:
  mynet:
    driver: bridge

volumes:
  pg_data: {}
  pg_backup: {}

services:

  db:
    image: postgres:12-alpine
    restart: always
    environment:
      POSTGRES_USER: netology
      POSTGRES_PASSWORD: passwd
    volumes:
      - pg_data:/var/lib/postgresql/data
      - pg_backup:/backup
    networks:
      - mynet

  adminer:
    image: adminer
    restart: always
    networks:
      - mynet
    ports:
      - 8080:8080
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Ответ
Листинг файла <code>request/db.sql</code>:
```sql
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
```
В <code>docker-compose.yml</code> добавил пункт в станзу <code>volumes</code>: <code>- /request:/request</code>
```bash
antigen@kenny:~/03$ docker exec -it 03_db_1 psql -U netology -f /request/db.sql
CREATE ROLE
CREATE DATABASE
You are now connected to database "test_db" as user "netology".
CREATE TABLE
CREATE TABLE
GRANT
CREATE ROLE
GRANT
```
- итоговый список БД после выполнения пунктов выше
```bash
test_db=# \l+
                                                                   List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+------------+------------+-----------------------+---------+------------+--------------------------------------------
 netology  | netology | UTF8     | en_US.utf8 | en_US.utf8 |                       | 7977 kB | pg_default |
 postgres  | netology | UTF8     | en_US.utf8 | en_US.utf8 |                       | 7977 kB | pg_default | default administrative connection database
 template0 | netology | UTF8     | en_US.utf8 | en_US.utf8 | =c/netology          +| 7833 kB | pg_default | unmodifiable empty database
           |          |          |            |            | netology=CTc/netology |         |            |
 template1 | netology | UTF8     | en_US.utf8 | en_US.utf8 | =c/netology          +| 7833 kB | pg_default | default template for new databases
           |          |          |            |            | netology=CTc/netology |         |            |
 test_db   | netology | UTF8     | en_US.utf8 | en_US.utf8 |                       | 8097 kB | pg_default |
(5 rows)
```
- описание таблиц (describe)
```bash
test_db=# \d+ orders
                                                       Table "public.orders"
 Column |         Type          | Collation | Nullable |              Default               | Storage  | Stats target | Description
--------+-----------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id     | integer               |           | not null | nextval('orders_id_seq'::regclass) | plain    |              |
 goods  | character varying(50) |           | not null |                                    | extended |              |
 price  | integer               |           | not null |                                    | plain    |              |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_ordersid_fkey" FOREIGN KEY (ordersid) REFERENCES orders(id)
Access method: heap

test_db=# \d+ clients
                                                        Table "public.clients"
  Column  |         Type          | Collation | Nullable |               Default               | Storage  | Stats target | Description
----------+-----------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id       | integer               |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 sourname | character varying(20) |           | not null |                                     | extended |              |
 country  | character varying(20) |           | not null |                                     | extended |              |
 ordersid | integer               |           |          |                                     | plain    |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_ordersid_fkey" FOREIGN KEY (ordersid) REFERENCES orders(id)
Access method: heap
```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```sql
SELECT * FROM information_schema.table_privileges WHERE table_name IN ('orders','clients');
```
- список пользователей с правами над таблицами test_db
```bash
test_db=# SELECT * FROM information_schema.table_privileges WHERE table_name IN ('orders','clients');
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 netology | netology         | test_db       | public       | orders     | INSERT         | YES          | NO
 netology | netology         | test_db       | public       | orders     | SELECT         | YES          | YES
 netology | netology         | test_db       | public       | orders     | UPDATE         | YES          | NO
 netology | netology         | test_db       | public       | orders     | DELETE         | YES          | NO
 netology | netology         | test_db       | public       | orders     | TRUNCATE       | YES          | NO
 netology | netology         | test_db       | public       | orders     | REFERENCES     | YES          | NO
 netology | netology         | test_db       | public       | orders     | TRIGGER        | YES          | NO
 netology | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 netology | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 netology | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 netology | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 netology | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 netology | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 netology | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 netology | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 netology | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 netology | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 netology | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 netology | netology         | test_db       | public       | clients    | INSERT         | YES          | NO
 netology | netology         | test_db       | public       | clients    | SELECT         | YES          | YES
 netology | netology         | test_db       | public       | clients    | UPDATE         | YES          | NO
 netology | netology         | test_db       | public       | clients    | DELETE         | YES          | NO
 netology | netology         | test_db       | public       | clients    | TRUNCATE       | YES          | NO
 netology | netology         | test_db       | public       | clients    | REFERENCES     | YES          | NO
 netology | netology         | test_db       | public       | clients    | TRIGGER        | YES          | NO
 netology | test-admin-user  | test_db       | public       | clients    | INSERT         | NO           | NO
 netology | test-admin-user  | test_db       | public       | clients    | SELECT         | NO           | YES
 netology | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO           | NO
 netology | test-admin-user  | test_db       | public       | clients    | DELETE         | NO           | NO
 netology | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 netology | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
 netology | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
 netology | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 netology | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 netology | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 netology | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(36 rows)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.


### Ответ
Листинг <code>request/data1.sql</code>:
```sql
INSERT INTO orders (goods, price) VALUES
    ('Шоколад', 10),
    ('Принтер', 3000),
    ('Книга', 500),
    ('Монитор', 7000),
    ('Гитара', 4000);
INSERT INTO clients (sourname, country) VALUES
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia');
```
Наполняем таблицу:
```bash
antigen@kenny:~/03$ docker exec -it 03_db_1 psql -U netology -d test_db -f /request/data1.sql
INSERT 0 5
INSERT 0 5
```
- вычислите количество записей для каждой таблицы. Запросы: 
```sql
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM clients;
```
- вычислите количество записей для каждой таблицы. Результат:
```bash
test_db=# SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)

test_db=# SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)
``` 

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

### Ответ
Листинг <code>request/data2.sql</code>
```sql
UPDATE clients SET ordersid = (SELECT id from orders WHERE goods = 'Книга') 
WHERE sourname = 'Иванов Иван Иванович';
UPDATE clients SET ordersid = (SELECT id from orders WHERE goods = 'Монитор') 
WHERE sourname = 'Петров Петр Петрович';
UPDATE clients SET ordersid = (SELECT id from orders WHERE goods = 'Гитара') 
WHERE sourname = 'Иоганн Себастьян Бах';
```
Применяем изменения:
```bash
antigen@kenny:~/03$ docker exec -it 03_db_1 psql -U netology -d test_db -f /request/data2.sql
UPDATE 1
UPDATE 1
UPDATE 1
```
Все пользователи совершившие заказ.Запрос:
```sql
SELECT sourname FROM clients WHERE NOT (ordersid IS NULL);
```
Все пользователи совершившие заказ.Вывод:
```bash
test_db=# SELECT sourname FROM clients WHERE NOT (ordersid IS NULL);
       sourname
----------------------
 Иванов Иван Иванович
 Петров Петр Петрович
 Иоганн Себастьян Бах
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

### Ответ
```sql
test_db=# EXPLAIN SELECT sourname FROM clients WHERE NOT (ordersid IS NULL);
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..15.30 rows=527 width=58)
   Filter: (ordersid IS NOT NULL)
(2 rows)
```
<code>Seq Scan on clients</code> - <code>postgres</code> открывает файл с таблицей clients, читает строки одну за другой и возвращает их пользователю. \
<code>cost=0.00..15.30</code> - Числа, как приблизительная стоимость по времени. Первое - время до начала этапа вывода данных. Второе - приблизительное время выполнения запроса. \
<code>rows=527</code> - ожидаемое число строк, которое должно быть выведено. \
<code>width=58</code> - ожидаемый средний размер строк \
<code>Filter: (ordersid IS NOT NULL)</code> - отбрасывает строки удовлетворяющие последующему условию

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

### Ответ
Снятие дампа:
```sql
pg_dump -U netology -d test_db > /backup/test_db.dump
```
Восстановление БД:
```sql
psql -U netology -d test_db < /backup/test_db.dump
```

Создаем бэкап:
```bash
antigen@kenny:~/03$ docker exec -it 03_db_1 bash -c "pg_dump -U netology -d test_db > /backup/test_db.dump"
antigen@kenny:~/03$ docker exec -it 03_db_1 ls -lah /backup
total 20K
drwxr-xr-x    2 root     root        4.0K Jul 13 14:10 .
drwxr-xr-x    1 root     root        4.0K Jul 13 14:11 ..
-rw-r--r--    1 root     root        4.1K Jul 13 14:10 test_db.dump
antigen@kenny:~/03$ docker-compose down
Stopping 03_adminer_1 ... done
Stopping 03_db_1      ... done
Removing 03_adminer_1 ... done
Removing 03_db_1      ... done
Removing network 03_mynet
```
Листинг <code>docker-compose-second.yml</code>
```yaml
version: '2.1'

networks:
  mynet:
    driver: bridge

volumes:
  pg_backup: {}

services:

  db:
    image: postgres:12-alpine
    restart: always
    environment:
      POSTGRES_USER: netology
      POSTGRES_PASSWORD: passwd
    volumes:
      - pg_backup:/backup
    networks:
      - mynet

  adminer:
    image: adminer
    restart: always
    networks:
      - mynet
    ports:
      - 8080:8080
```
Запускаем:
```bash
antigen@kenny:~/03$ docker-compose -f docker-compose-second.yml up -d
Creating network "03_mynet" with driver "bridge"
Creating 03_db_1      ... done
Creating 03_adminer_1 ... done
antigen@kenny:~/03$ docker exec -it 03_db_1 psql -U netology -c "CREATE DATABASE test_db;"
CREATE DATABASE
antigen@kenny:~/03$ docker exec -it 03_db_1 bash -c "psql -U netology -d test_db < /backup/test_db.dump"
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
ALTER TABLE
ERROR:  role "test-admin-user" does not exist
ERROR:  role "test-simple-user" does not exist
ERROR:  role "test-admin-user" does not exist
ERROR:  role "test-simple-user" does not exist
antigen@kenny:~/03$ docker exec -it 03_db_1 psql -U netology -d test_db  -c "SELECT * FROM clients;"
 id |       sourname       | country | ordersid
----+----------------------+---------+----------
  4 | Ронни Джеймс Дио     | Russia  |
  5 | Ritchie Blackmore    | Russia  |
  1 | Иванов Иван Иванович | USA     |        3
  2 | Петров Петр Петрович | Canada  |        4
  3 | Иоганн Себастьян Бах | Japan   |        5
(5 rows)
```