# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

### Ответ
Листинг `docker-compose.yml`
```bash
version: '2.7'

networks:
  mynet:
    driver: bridge

volumes:
  pg_data: {}

services:

  db:
    image: postgres:13-alpine
    restart: always
    environment:
      POSTGRES_USER: netology
      POSTGRES_PASSWORD: passwd
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./request:/request
    networks:
      - mynet
```
Вывода подсказки по имеющимся в `psql` управляющим командам:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -c "\?"
General
  \copyright             show PostgreSQL usage and distribution terms
  \crosstabview [COLUMNS] execute query and display results in crosstab
  \errverbose            show most recent error message at maximum verbosity
  \g [FILE] or ;         execute query (and send results to file or |pipe)
  \gdesc                 describe result of query, without executing it
  \gexec                 execute query, then execute each value in its result
  \gset [PREFIX]         execute query and store results in psql variables
  \gx [FILE]             as \g, but forces expanded output mode
  \q                     quit psql
  \watch [SEC]           execute query every SEC seconds

Help
  \? [commands]          show help on backslash commands
  \? options             show help on psql command-line options
  \? variables           show help on special variables
  \h [NAME]              help on syntax of SQL commands, * for all commands

Query Buffer
  \e [FILE] [LINE]       edit the query buffer (or file) with external editor
  \ef [FUNCNAME [LINE]]  edit function definition with external editor
  \ev [VIEWNAME [LINE]]  edit view definition with external editor
  \p                     show the contents of the query buffer
  \r                     reset (clear) the query buffer
  \s [FILE]              display history or save it to file
  \w FILE                write query buffer to file

Input/Output
  \copy ...              perform SQL COPY with data stream to the client host
  \echo [STRING]         write string to standard output
  \i FILE                execute commands from file
  \ir FILE               as \i, but relative to location of current script
  \o [FILE]              send all query results to file or |pipe
  \qecho [STRING]        write string to query output stream (see \o)

Conditional
  \if EXPR               begin conditional block
  \elif EXPR             alternative within current conditional block
  \else                  final alternative within current conditional block
  \endif                 end conditional block

Informational
  (options: S = show system objects, + = additional detail)
  \d[S+]                 list tables, views, and sequences
  \d[S+]  NAME           describe table, view, sequence, or index
  \da[S]  [PATTERN]      list aggregates
  \dA[+]  [PATTERN]      list access methods
  \db[+]  [PATTERN]      list tablespaces
  \dc[S+] [PATTERN]      list conversions
  \dC[+]  [PATTERN]      list casts
  \dd[S]  [PATTERN]      show object descriptions not displayed elsewhere
  \dD[S+] [PATTERN]      list domains
  \ddp    [PATTERN]      list default privileges
  \dE[S+] [PATTERN]      list foreign tables
  \det[+] [PATTERN]      list foreign tables
  \des[+] [PATTERN]      list foreign servers
  \deu[+] [PATTERN]      list user mappings
  \dew[+] [PATTERN]      list foreign-data wrappers
  \df[anptw][S+] [PATRN] list [only agg/normal/procedures/trigger/window] functions
  \dF[+]  [PATTERN]      list text search configurations
  \dFd[+] [PATTERN]      list text search dictionaries
  \dFp[+] [PATTERN]      list text search parsers
  \dFt[+] [PATTERN]      list text search templates
  \dg[S+] [PATTERN]      list roles
  \di[S+] [PATTERN]      list indexes
  \dl                    list large objects, same as \lo_list
  \dL[S+] [PATTERN]      list procedural languages
  \dm[S+] [PATTERN]      list materialized views
  \dn[S+] [PATTERN]      list schemas
  \do[S+] [PATTERN]      list operators
  \dO[S+] [PATTERN]      list collations
  \dp     [PATTERN]      list table, view, and sequence access privileges
  \dP[itn+] [PATTERN]    list [only index/table] partitioned relations [n=nested]
  \drds [PATRN1 [PATRN2]] list per-database role settings
  \dRp[+] [PATTERN]      list replication publications
  \dRs[+] [PATTERN]      list replication subscriptions
  \ds[S+] [PATTERN]      list sequences
  \dt[S+] [PATTERN]      list tables
  \dT[S+] [PATTERN]      list data types
  \du[S+] [PATTERN]      list roles
  \dv[S+] [PATTERN]      list views
  \dx[+]  [PATTERN]      list extensions
  \dy[+]  [PATTERN]      list event triggers
  \l[+]   [PATTERN]      list databases
  \sf[+]  FUNCNAME       show a function's definition
  \sv[+]  VIEWNAME       show a view's definition
  \z      [PATTERN]      same as \dp

Formatting
  \a                     toggle between unaligned and aligned output mode
  \C [STRING]            set table title, or unset if none
  \f [STRING]            show or set field separator for unaligned query output
  \H                     toggle HTML output mode (currently off)
  \pset [NAME [VALUE]]   set table output option
                         (border|columns|csv_fieldsep|expanded|fieldsep|
                         fieldsep_zero|footer|format|linestyle|null|
                         numericlocale|pager|pager_min_lines|recordsep|
                         recordsep_zero|tableattr|title|tuples_only|
                         unicode_border_linestyle|unicode_column_linestyle|
                         unicode_header_linestyle)
  \t [on|off]            show only rows (currently off)
  \T [STRING]            set HTML <table> tag attributes, or unset if none
  \x [on|off|auto]       toggle expanded output (currently off)

Connection
  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "netology")
  \conninfo              display information about current connection
  \encoding [ENCODING]   show or set client encoding
  \password [USERNAME]   securely change the password for a user

Operating System
  \cd [DIR]              change the current working directory
  \setenv NAME [VALUE]   set or unset environment variable
  \timing [on|off]       toggle timing of commands (currently off)
  \! [COMMAND]           execute command in shell or start interactive shell

Variables
  \prompt [TEXT] NAME    prompt user to set internal variable
  \set [NAME [VALUE]]    set internal variable, or list all if no parameters
  \unset NAME            unset (delete) internal variable

Large Objects
  \lo_export LOBOID FILE
  \lo_import FILE [COMMENT]
  \lo_list
  \lo_unlink LOBOID      large object operations
```
Вывода списка БД:
```bash
  \l[+]   [PATTERN]      list databases
```
Подключения к БД:
```bash
  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database
```
Вывода списка таблиц:
```bash
  \dt[S+] [PATTERN]      list tables
```
Вывода описания содержимого таблиц:
```bash
  \d[S+]                 list tables, views, and sequences
```
Выхода из psql:
```bash
  \q                     quit psql
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

### Ответ
Создание БД:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -c "CREATE DATABASE test_database;"
CREATE DATABASE
```
Восстановление бэкапа БД в `test_database`:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 bash -c "psql -U netology -d test_database < /request/test_db.sql"
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
ERROR:  role "postgres" does not exist
CREATE SEQUENCE
ERROR:  role "postgres" does not exist
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
```
ANALYZE:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -d test_database
psql (12.11)
Type "help" for help.

test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```
Команда: `SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders';` \
Результат:
```bash
test_database=# \d pg_stats;
                     View "pg_catalog.pg_stats"
         Column         |   Type   | Collation | Nullable | Default
------------------------+----------+-----------+----------+---------
 schemaname             | name     |           |          |
 tablename              | name     |           |          |
 attname                | name     |           |          |
 inherited              | boolean  |           |          |
 null_frac              | real     |           |          |
 avg_width              | integer  |           |          |
 n_distinct             | real     |           |          |
 most_common_vals       | anyarray |           |          |
 most_common_freqs      | real[]   |           |          |
 histogram_bounds       | anyarray |           |          |
 correlation            | real     |           |          |
 most_common_elems      | anyarray |           |          |
 most_common_elem_freqs | real[]   |           |          |
 elem_count_histogram   | real[]   |           |          |

test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders';
 attname | avg_width
---------+-----------
 price   |         4
 id      |         4
 title   |        16
(3 rows)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

### Ответ
Нашел 2 варианта разбиения таблицы.
#### Вариант 1.
Листинг `request\sharding_1.sql`
```sql
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
```
Запуск скрипта:
```bash
antigen@kenny:~/05/request$ docker exec -it 05_db_1 psql -U netology -d test_database -f /request/sharding_1.sql
BEGIN
ALTER TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
INSERT 0 8
DROP TABLE
COMMIT
```
Запускаем скрипт:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -d test_database -f /request/sharding.sql
BEGIN
ALTER TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE FUNCTION
CREATE TRIGGER
INSERT 0 0
DROP TABLE
COMMIT
```
Листинг `request/new_values.sql`:
```sql
INSERT INTO orders (id, title, price) VALUES
    (10, 'MY FIRST', 1000),
    (11, 'MY SECOND', 10),
    (12, 'MY THIRD', 500);
```
Вносим новые значения:
```bash
antigen@kenny:~/05/request$ docker exec -it 05_db_1 psql -U netology -d test_database -f /request/new_values.sql
INSERT 0 3
```
Смотрим что получилось:
```bash
antigen@kenny:~/05/request$ docker exec -it 05_db_1 psql -U netology -d test_database -c "SELECT * FROM orders;"
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
 11 | MY SECOND            |    10
  2 | My little database   |   500
  6 | WAL never lies       |   900
  7 | Me and my bash-pet   |   499
  8 | Dbiezdmin            |   501
 10 | MY FIRST             |  1000
 12 | MY THIRD             |   500
(11 rows)

antigen@kenny:~/05/request$ docker exec -it 05_db_1 psql -U netology -d test_database -c "SELECT * FROM orders_1;"
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  7 | Me and my bash-pet |   499
  8 | Dbiezdmin          |   501
 10 | MY FIRST           |  1000
 12 | MY THIRD           |   500
(6 rows)

antigen@kenny:~/05/request$ docker exec -it 05_db_1 psql -U netology -d test_database -c "SELECT * FROM orders_2;"
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
 11 | MY SECOND            |    10
(5 rows)
```

#### Вариант 2.
Листинг `request\sharding_2.sql`
```sql
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
```
Листинг `request/new_values.sql`:
```sql
INSERT INTO orders (id, title, price) VALUES
    (10, 'MY FIRST', 1000),
    (11, 'MY SECOND', 10),
    (12, 'MY THIRD', 500);
```
Заносим новые значения в таблицу:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -d test_database -f /request/new_values.sql
INSERT 0 3
```
Смотрим что получилось:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -d test_database -c "SELECT * FROM orders;"
 id |        title         | price
----+----------------------+-------
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
 10 | MY FIRST             |  1000
 12 | MY THIRD             |   500
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
 11 | MY SECOND            |    10
(11 rows)

antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -d test_database -c "SELECT * FROM orders_1;"
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
 10 | MY FIRST           |  1000
 12 | MY THIRD           |   500
(5 rows)

antigen@kenny:~/05$ docker exec -it 05_db_1 psql -U netology -d test_database -c "SELECT * FROM orders_2;"
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
 11 | MY SECOND            |    10
(6 rows)
```
Чтобы изначально исключить "ручное" разбиение при проектировании таблицы orders, необходимо использовать декларативное секционирование с предложением PARTITION BY.
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

### Ответ
Делаем бэкап:
```bash
antigen@kenny:~/05$ docker exec -it 05_db_1 pg_dump -U netology -d test_database > ./test_db.dump
```
Смотрим бэкап:
```bash
antigen@kenny:~/05$ cat test_db.dump
--
-- PostgreSQL database dump
--

-- Dumped from database version 12.11
-- Dumped by pg_dump version 12.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: orders; Type: TABLE; Schema: public; Owner: netology
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
)
PARTITION BY RANGE (price);


ALTER TABLE public.orders OWNER TO netology;

SET default_table_access_method = heap;

--
-- Name: orders_1; Type: TABLE; Schema: public; Owner: netology
--

CREATE TABLE public.orders_1 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);
ALTER TABLE ONLY public.orders ATTACH PARTITION public.orders_1 FOR VALUES FROM (499) TO (1000000);


ALTER TABLE public.orders_1 OWNER TO netology;

--
-- Name: orders_2; Type: TABLE; Schema: public; Owner: netology
--

CREATE TABLE public.orders_2 (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
);
ALTER TABLE ONLY public.orders ATTACH PARTITION public.orders_2 FOR VALUES FROM (0) TO (499);


ALTER TABLE public.orders_2 OWNER TO netology;

--
-- Data for Name: orders_1; Type: TABLE DATA; Schema: public; Owner: netology
--

COPY public.orders_1 (id, title, price) FROM stdin;
2       My little database      500
6       WAL never lies  900
7       Me and my bash-pet      499
8       Dbiezdmin       501
10      MY FIRST        1000
12      MY THIRD        500
\.


--
-- Data for Name: orders_2; Type: TABLE DATA; Schema: public; Owner: netology
--

COPY public.orders_2 (id, title, price) FROM stdin;
1       War and peace   100
3       Adventure psql time     300
4       Server gravity falls    300
5       Log gossips     123
11      MY SECOND       10
\.


--
-- PostgreSQL database dump complete
--

```
Уникальности можно добиться добавив `UNIQUE` в описание столбца:
```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
)
```