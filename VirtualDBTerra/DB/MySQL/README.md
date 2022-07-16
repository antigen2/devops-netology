# Домашнее задание к занятию "6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

### Ответ
Листинг <code>docker-compose.yml</code>:
```bash
version: '2.7'

networks:
  mysqlnet:
    driver: bridge
    name: mysql_net

volumes:
  mysql_data: {}

services:
  mysql:
    image: mysql:8
    restart: always
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: passwd
      MYSQL_USER: netology
      MYSQL_PASSWORD: passwd
      MYSQL_DATABASE: test_db
    volumes:
      - mysql_data:/var/lib/mysql
      - ./data:/docker-entrypoint-initdb.d
      - ./request:/request
      - ./my.cnf:/etc/mysql/my.cnf
    networks:
      - mysqlnet
```
Список управляющих команд:
```bash
antigen@kenny:~/04$ docker exec -it mysql mysql -unetology -ppasswd test_db -e "\h"
mysql: [Warning] Using a password on the command line interface can be insecure.
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file
```
Версия сервера БД:
```bash
antigen@kenny:~/04$ docker exec -it mysql mysql -unetology -ppasswd test_db -e "\s" | grep Ver
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)
```
Список таблиц в <code>test_db</code>:
```bash
antigen@kenny:~/04$ docker exec -it mysql mysql -unetology -ppasswd test_db -e "SHOW TABLES;"
mysql: [Warning] Using a password on the command line interface can be insecure.
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
```
Количество записей с <code>price > 300</code>
```bashantigen@kenny:~/04$ docker exec -it mysql mysql -unetology -ppasswd test_db -e "SELECT COUNT(*) FROM orders WHERE price > 300"
mysql: [Warning] Using a password on the command line interface can be insecure.
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

### Ответ

Листинг файла <code>request/new_user.sql</code>
```sql
CREATE USER 'test'@'localhost'
        IDENTIFIED WITH mysql_native_password BY 'test-pass'
        WITH MAX_QUERIES_PER_HOUR 100
        PASSWORD EXPIRE INTERVAL 180 DAY
        FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1
        ATTRIBUTE '{"surname": "Pretty", "name": "James"}';
GRANT SELECT ON test_db.* TO 'test'@'localhost';
```
```bash
antigen@kenny:~/04/request$ docker exec -it mysql bash -c "mysql -uroot -ppasswd < request/new_user.sql"
mysql: [Warning] Using a password on the command line interface can be insecure.
```
```bash
antigen@kenny:~/04/request$ docker exec -it mysql mysql -uroot -ppasswd -e "SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';"
mysql: [Warning] Using a password on the command line interface can be insecure.
+------+-----------+----------------------------------------+
| USER | HOST      | ATTRIBUTE                              |
+------+-----------+----------------------------------------+
| test | localhost | {"name": "James", "surname": "Pretty"} |
+------+-----------+----------------------------------------+
```
## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

### Ответ

```bash
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> \u test_db
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> SELECT * FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc;\
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+-------------+------------+--------------------+----------+----------------+---------------+
| TABLE_CATALOG | TABLE_SCHEMA | TABLE_NAME | TABLE_TYPE | ENGINE | VERSION | ROW_FORMAT | TABLE_ROWS | AVG_ROW_LENGTH | DATA_LENGTH | MAX_DATA_LENGTH | INDEX_LENGTH | DATA_FREE | AUTO_INCREMENT | CREATE_TIME         | UPDATE_TIME | CHECK_TIME | TABLE_COLLATION    | CHECKSUM | CREATE_OPTIONS | TABLE_COMMENT |
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+-------------+------------+--------------------+----------+----------------+---------------+
| def           | test_db      | orders     | BASE TABLE | InnoDB |      10 | Dynamic    |          2 |           8192 |       16384 |               0 |            0 |         0 |              5 | 2022-07-15 14:44:56 | NULL        | NULL       | utf8mb4_0900_ai_ci |     NULL |                |               |
+---------------+--------------+------------+------------+--------+---------+------------+------------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+-------------+------------+--------------------+----------+----------------+---------------+
1 row in set (0.00 sec)

mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (2.25 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (1.75 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT TABLE_SCHEMA, TABLE_NAME,  ENGINE FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc;
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0.00 sec)

mysql> SHOW PROFILES;
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                                                                 |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
|        1 | 0.00009725 | SELECT DATABASE()                                                                                                                                     |
|        2 | 0.00051825 | show databases                                                                                                                                        |
|        3 | 0.00068350 | show tables                                                                                                                                           |
|        4 | 0.00009925 | SELECT * FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc                                 |
|        5 | 2.24321975 | ALTER TABLE orders ENGINE = MyISAM                                                                                                                    |
|        6 | 1.74763725 | ALTER TABLE orders ENGINE = InnoDB                                                                                                                    |
|        7 | 0.00079050 | SELECT TABLE_SCHEMA, TABLE_NAME,  ENGINE FROM information_schema.TABLES WHERE table_name = 'orders' and  TABLE_SCHEMA = 'test_db' ORDER BY ENGINE asc |
+----------+------------+-------------------------------------------------------------------------------------------------------------------------------------------------------+
7 rows in set, 1 warning (0.00 sec)

mysql> SHOW PROFILE FORE QUERY 5;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'FORE QUERY 5' at line 1
mysql> SHOW PROFILE FOR QUERY 5;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000045 |
| Executing hook on transaction  | 0.000003 |
| starting                       | 0.000012 |
| checking permissions           | 0.000004 |
| checking permissions           | 0.000003 |
| init                           | 0.000007 |
| Opening tables                 | 0.000266 |
| setup                          | 0.000060 |
| creating table                 | 0.000574 |
| waiting for handler commit     | 0.000005 |
| waiting for handler commit     | 0.115292 |
| After create                   | 0.000236 |
| System lock                    | 0.000007 |
| copy to tmp table              | 0.000050 |
| waiting for handler commit     | 0.000005 |
| waiting for handler commit     | 0.000007 |
| waiting for handler commit     | 0.000013 |
| rename result table            | 0.000033 |
| waiting for handler commit     | 0.492337 |
| waiting for handler commit     | 0.000019 |
| waiting for handler commit     | 0.533375 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.559164 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.157820 |
| end                            | 0.238192 |
| query end                      | 0.145501 |
| closing tables                 | 0.000027 |
| waiting for handler commit     | 0.000020 |
| freeing items                  | 0.000107 |
| cleaning up                    | 0.000012 |
+--------------------------------+----------+
31 rows in set, 1 warning (0.00 sec)

mysql> SHOW PROFILE FOR QUERY 6;
+--------------------------------+----------+
| Status                         | Duration |
+--------------------------------+----------+
| starting                       | 0.000093 |
| Executing hook on transaction  | 0.000005 |
| starting                       | 0.000014 |
| checking permissions           | 0.000004 |
| checking permissions           | 0.000003 |
| init                           | 0.000008 |
| Opening tables                 | 0.000144 |
| setup                          | 0.000035 |
| creating table                 | 0.000055 |
| After create                   | 0.879548 |
| System lock                    | 0.000013 |
| copy to tmp table              | 0.000086 |
| rename result table            | 0.000582 |
| waiting for handler commit     | 0.000016 |
| waiting for handler commit     | 0.116347 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.525535 |
| waiting for handler commit     | 0.000012 |
| waiting for handler commit     | 0.058521 |
| waiting for handler commit     | 0.000013 |
| waiting for handler commit     | 0.116104 |
| end                            | 0.000323 |
| query end                      | 0.049623 |
| closing tables                 | 0.000015 |
| waiting for handler commit     | 0.000286 |
| freeing items                  | 0.000212 |
| cleaning up                    | 0.000033 |
+--------------------------------+----------+
27 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

### Ответ
Листинг <code>/etc/mysql/my.cnf</code>
```bash
[mysqld]

# Скорость IO важнее сохранности данных
innodb_flush_method=O_DIRECT
innodb_flush_log_at_trx_commit = 2

# Нужна компрессия таблиц для экономии места на диске
innodb_file_per_table = ON
innodb_file_format = BARRACUDA

# Размер буффера с незакомиченными транзакциями 1 Мб
innodb_log_buffer_size = 1M

# Буффер кеширования 30% от ОЗУ из 4 Gb
innodb_buffer_pool_size = 1228M

# Размер файла логов операций 100 Мб
innodb_log_file_size = 100M
```
