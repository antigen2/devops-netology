Role Name
=========

Роль для установки `lighthouse`. Пока только `rpm`.

Requirements
------------

none

Role Variables
--------------

Файл `vars/main.yml`:
- `lighthouse_git`: Ссылка для скачивания дистрибутива `lighthouse`
- `lighthouse_dir`: Каталог установки `lighthouse`
- `lighthouse_access_log_name`: Имя файла логирования

Файл `defaults/main.yml`:
- `clickhouse_user`: Пользователь `clickhouse`
- `clickhouse_password`: Пароль `clickhouse`

Dependencies
------------

none

Example Playbook
----------------

```yaml
- hosts: lighthouse
  roles:
    - role: lighthouse_role
```
License
-------

GPLv3

Author Information
------------------

antigen2
