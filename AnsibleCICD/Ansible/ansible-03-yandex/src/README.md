# Playbook
==========
Playbook устанавливает и конфигурирует `clickhouse`, `lighthouse` и `vector`

## Clickhouse
- установка
- создание БД

## Vector
- установка

## Lighthouse
- установка
- конфигурирование
- запуск `nginx`

## Действия
Разворачивает `Lighthouse`, `Clickhouse` и `Vector`.

## Переменные
Файл: ./ansible/playbook/group_vars/lighthouse/vars.yaml
- `nginx_user_name`
- `worker_processes`
- `worker_connections`
А так же в ролях.

## Тэги:
- `clickhouse` - установка и конфигурирование `clickhouse` 
- `vector` - установка `vector`
- `lighthouse` -  установка `lighthouse` 