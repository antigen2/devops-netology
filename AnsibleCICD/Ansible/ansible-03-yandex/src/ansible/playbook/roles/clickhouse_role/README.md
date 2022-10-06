Role Name
=========

Роль для установки `clickhouse`. Пока только `rpm`.

Requirements
------------

none

Role Variables
--------------

Файл `vars/main.yml`:
- `clickhouse_version`: Версия пакета для установки
- `clickhouse_packages`: Список пакетов для установки
- `clickhouse_config_file`: Расположение конфигурационного файла сервера
- `clickhouse_users_file`: Расположение конфигурационного файла пользователя
- `clickhouse_create_table`: Запрос для создания таблиц в БД

Файл `defaults/main.yml`:
- `clickhouse_user`: Пользователь
- `clickhouse_password`: Пароль

Dependencies
------------

none

Example Playbook
----------------

```yaml
- hosts: clickhouse
  roles:
    - role: clickhouse_role
```
License
-------

GPLv3

Author Information
------------------

antigen2
