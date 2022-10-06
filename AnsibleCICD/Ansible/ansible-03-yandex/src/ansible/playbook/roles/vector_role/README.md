Role Name
=========

Роль для установки `vector`. Пока только `rpm`.

Requirements
------------

none

Role Variables
--------------

Файл `vars/main.yml`:
- `vector_vers`: Версия `vector`
- `vector_config_file`: Расположение конфигурационного файла 
- `vector_config`: Переменная для генерации файла конфигурации

Файл `defaults/main.yml`:
- `clickhouse_user`: Пользователь `clickhouse`
- `clickhouse_password`: Пароль `clickhouse`

Dependencies
------------

none

Example Playbook
----------------

```yaml
- hosts: vector
  roles:
    - role: vector_role
```
License
-------

GPLv3

Author Information
------------------

antigen2
