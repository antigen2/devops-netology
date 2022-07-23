# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

### Ответ

Т.к. эластик не доступен, скачал последний релиз и положил в папку `files`. \
Листинг `Dockerfile`:
```bash
FROM    centos:7

ENV     ES_HOME=/app
ENV     ES_USER=elasticsearch

ADD     files/elasticsearch.tar.gz ${ES_HOME}
RUN     useradd ${ES_USER} && \
        chown -R ${ES_USER}: ${ES_HOME} && \
        mkdir -p /var/lib/elasticsearch && \
        chown -R ${ES_USER}: /var/lib/elasticsearch
COPY    files/elasticsearch.yml ${ES_HOME}/config
WORKDIR ${ES_HOME}
USER    ${ES_USER}
EXPOSE  9200 9300

ENTRYPOINT ["./bin/elasticsearch"]
```
Листинг `files/elasticsearch.yml`:
```
---
discovery.type: single-node

cluster.name: netology

node.name: netology_test

xpack.security.enabled: false

network.host: 0.0.0.0

path.data: /var/lib/elasticsearch
```
Ответ `elasticsearch` на запрос пути `/` в json виде:
```bash
antigen@kenny:~$ docker exec -it goofy_sutherland curl localhost:9200
{
  "name" : "netology_test",
  "cluster_name" : "netology",
  "cluster_uuid" : "BYLutmxKRS-ynieUAxo3Bw",
  "version" : {
    "number" : "8.3.2",
    "build_type" : "tar",
    "build_hash" : "8b0b1f23fbebecc3c88e4464319dea8989f374fd",
    "build_date" : "2022-07-06T15:15:15.901688194Z",
    "build_snapshot" : false,
    "lucene_version" : "9.2.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```
[Ссылка на образ в репозитории dockerhub](https://hub.docker.com/r/antigen2/elasticsearch)

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

### Ответ
Создаем и запускаем `docker-compose.yml`. Его листинг:
```bash
version: '2.7'

networks:
  mynet:
    driver: bridge

services:
  db:
    image: antigen2/elasticsearch:8.3.2
    restart: always
    container_name: elasticsearch
    networks:
      - mynet
    volumes:
      - ./scr:/scr
```
Листинг bash скрипта для создания индексов `scr/add_index.sh`
```bash
#!/usr/bin/env bash

curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0, "number_of_shards": 1 }}'
curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 1, "number_of_shards": 2 }}'
curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 2, "number_of_shards": 4 }}'
```
Запускаем:
```bash
antigen@kenny:~$ docker exec -it elasticsearch bash -c "/scr/add_index.sh"
{"acknowledged":true,"shards_acknowledged":true,"index":"ind-1"}{"acknowledged":true,"shards_acknowledged":true,"index":"ind-2"}{"acknowledged":true,"shards_acknowledged":true,"index":"ind-3"}
```
Смотрим индексы:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   ind-3 OjUPj15pSEOyOyf2KGx6Hg   4   2          0            0       900b           900b
yellow open   ind-2 on3n1RzgRy-LyOONppjuTA   2   1          0            0       450b           450b
green  open   ind-1 3us0YukgRKqCXT5HTu7ecQ   1   0          0            0       225b           225b
```
Смотрим состояние кластера `elasticsearch`:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -XGET localhost:9200/_cluster/health/?pretty
{
  "cluster_name" : "netology",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```
Состояние `yellow` т.к. кластер состоит из одной ноды и потеря этой ноды приведет к потере данных. \
Листинг скрипта удаления индексов `scr/rm_index.sh`:
```bash
#!/usr/bin/env bash

curl -X DELETE 'http://localhost:9200/ind-1'
curl -X DELETE 'http://localhost:9200/ind-2'
curl -X DELETE 'http://localhost:9200/ind-3'
```
Запускаем:
```bash
antigen@kenny:~$ docker exec -it elasticsearch bash -c "/scr/rm_index.sh"
{"acknowledged":true}{"acknowledged":true}{"acknowledged":true}
```
Проверяем:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

### Ответ
Изменил `Dockerfile`:
```bash
FROM    centos:7

ENV     ES_HOME=/app \
        ES_USER=elasticsearch
ADD     files/elasticsearch.tar.gz ${ES_HOME}
RUN     useradd ${ES_USER} && \
        chown -R ${ES_USER}: ${ES_HOME} && \
        mkdir -p /var/lib/elasticsearch && \
        chown -R ${ES_USER}: /var/lib/elasticsearch && \
        mkdir /snapshots && \
        chown -R ${ES_USER}: /snapshots
COPY    files/elasticsearch.yml ${ES_HOME}/config
WORKDIR ${ES_HOME}
USER    ${ES_USER}
EXPOSE  9200 9300

ENTRYPOINT ["./bin/elasticsearch"]
```
и файл `elasticsearch.yml`:
```bash
---
discovery.type: single-node

cluster.name: netology

node.name: netology_test

xpack.security.enabled: false

network.host: 0.0.0.0

path.data: /var/lib/elasticsearch
path.repo: /snapshots
```
Ребилдим образ и запускаем `docker-compose`. Заставляем `elasticsearch` использовать директорию `/snapshots` как `snapshot repository` c именем `netology_backup`:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d' { "type": "fs",   "settings": { "location": "/snapshots" } }'
{
  "acknowledged" : true
}
```
Создаём индекс `test` с 0 реплик и 1 шардом и выводим индексы:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0, "number_of_shards": 1 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}
antigen@kenny:~$ docker exec -it elasticsearch curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  JBbyOafKSVGmpIkMqg8D0w   1   0          0            0       225b           225b

```
Создаём `snapshot` состояния кластера `elasticsearch`:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X PUT "localhost:9200/_snapshot/netology_backup/my_snapshot?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "my_snapshot",
    "uuid" : "FojW8jzpQS2tHglZGQ9iFg",
    "repository" : "netology_backup",
    "version_id" : 8030299,
    "version" : "8.3.2",
    "indices" : [
      ".geoip_databases",
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-07-23T22:15:36.301Z",
    "start_time_in_millis" : 1658614536301,
    "end_time" : "2022-07-23T22:15:39.303Z",
    "end_time_in_millis" : 1658614539303,
    "duration_in_millis" : 3002,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```
Смотрим список файлов снапшота:
```bash
antigen@kenny:~$ docker exec -it elasticsearch ls -lah /snapshots
total 44K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Jul 23 22:15 .
drwxr-xr-x 1 root          root          4.0K Jul 23 21:49 ..
-rw-r--r-- 1 elasticsearch elasticsearch  844 Jul 23 22:15 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Jul 23 22:15 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch 4.0K Jul 23 22:15 indices
-rw-r--r-- 1 elasticsearch elasticsearch  19K Jul 23 22:15 meta-FojW8jzpQS2tHglZGQ9iFg.dat
-rw-r--r-- 1 elasticsearch elasticsearch  357 Jul 23 22:15 snap-FojW8jzpQS2tHglZGQ9iFg.dat
```
Удаляем индекс `test` и создаем `test-2`
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X DELETE "localhost:9200/test"
{"acknowledged":true}
antigen@kenny:~$ docker exec -it elasticsearch curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'{ "settings": { "index": { "number_of_shards": 1, "number_of_replicas": 0 } } }'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
antigen@kenny:~$ docker exec -it elasticsearch curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 QtN2svrvQoqCTk5ltGjh0w   1   0          0            0       225b           225b
```
Восстановим бэкап:
```bash
antigen@kenny:~$ docker exec -it elasticsearch curl -X POST localhost:9200/_snapshot/netology_backup/my_snapshot/_restore?pretty -H 'Content-Type: application/json' -d'{ "indices" : "test" }'
{
  "accepted" : true
}
antigen@kenny:~$ docker exec -it elasticsearch curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test   IDZj1nMER7iC600X5A-HiA   1   0          0            0       225b           225b
green  open   test-2 QtN2svrvQoqCTk5ltGjh0w   1   0          0            0       225b           225b
```

