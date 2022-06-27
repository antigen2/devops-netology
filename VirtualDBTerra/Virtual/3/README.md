
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"


## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

### Ответ
```bash
docker build -t test-nginx:1.0 .  
docker tag test-nginx:1.0 antigen2/test-nginx:1.0  
docker login --username antigen2 
docker push antigen2/test-nginx:1.0
```
```bash
docker run --name test-nginx -d -p 8080:80 antigen2/test-nginx:1.0
```
[Ссылка](https://hub.docker.com/r/antigen2/test-nginx)

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

### Ответ
- Высоконагруженное монолитное java веб-приложение \
Необходима физическая машина, т.к. все ресурсы должны быть предоставлены приложению.

- Nodejs веб-приложение. \
Docker контейнер. Проще управлять, обновлять и расширять.

- Мобильное приложение c версиями для Android и iOS. \
Не уверен что подойдет какой-то из вариантов. Мобильное приложение - это файл для запуска на телефоне.

- Шина данных на базе Apache Kafka. \
Docker контейнер. Проще управлять, обновлять и расширять.

- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana. \
Docker контейнел или ВМ.

- Мониторинг-стек на базе Prometheus и Grafana. \
Docker контейнер. Проще управлять, обновлять и расширять.

- MongoDB, как основное хранилище данных для java-приложения. \
ВМ или физическая машина для прода. Хотя для разработки можно использовать и docker контейнер.

- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry. \
Возможен docker контейнер.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

### Ответ
```bash
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/3/linux$ docker run -t -d --name cent7 -v /home/antigen/netology/devops-netology/VirtualDBTerra/Virtual/3/linux/data:/data centos:7
a77f4c18976977b5b19d4f4a011c810cc93f9cfd110ffac99d4b07a5824ffe10
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/3/linux$ docker run -t -d --name deb11 -v /home/antigen/netology/devops-netology/VirtualDBTerra/Virtual/3/linux/data:/data debian:11
eff34133e1d3abd997dd70e6b1cca91e0708130377dba7bdad6bd7995944561e
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/3/linux$ docker ps -a
CONTAINER ID   IMAGE       COMMAND       CREATED          STATUS          PORTS     NAMES
eff34133e1d3   debian:11   "bash"        6 seconds ago    Up 5 seconds              deb11
a77f4c189769   centos:7    "/bin/bash"   13 seconds ago   Up 13 seconds             cent7
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/3/linux$ docker exec -it cent7 bash
[root@a77f4c189769 /]# lsblk > /data/cent7.txt
[root@a77f4c189769 /]# exit
exit
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/3/linux$ ls -lah > data/host.txt
antigen@gramm:~/netology/devops-netology/VirtualDBTerra/Virtual/3/linux$ docker exec -it deb11 bash
root@eff34133e1d3:/# ls -lah /data/
total 16K
drwxr-xr-x 2 1000 1000 4.0K Jun 27 12:59 .
drwxr-xr-x 1 root root 4.0K Jun 27 12:57 ..
-rw-r--r-- 1 root root  235 Jun 27 12:59 cent7.txt
-rw-r--r-- 1 1000 1000  175 Jun 27 12:59 host.txt
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

### Ответ

[Ссылка](https://hub.docker.com/r/antigen2/ansible)

```bash
docker build -t antigen2/ansible:2.10.7 .
docker login --username antigen2
docker push antigen2/ansible:2.10.7 
```


