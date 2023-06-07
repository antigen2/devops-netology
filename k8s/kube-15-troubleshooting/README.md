# Домашнее задание к занятию Troubleshooting

### Цель задания

Устранить неисправности при деплое приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

> 1. Установить приложение по команде:
> ```shell
> kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
> ```
> 2. Выявить проблему и описать.
> 3. Исправить проблему, описать, что сделано.
> 4. Продемонстрировать, что проблема решена.

Устанавливаем:
```bash
antigen@deb11notepad:~/netology/15$ kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "web" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
```
Создаем `namespaces`:
```bash
antigen@deb11notepad:~/netology/15$ kubectl create ns web
namespace/web created
antigen@deb11notepad:~/netology/15$ kubectl create ns data
namespace/data created
```
Ставим еще разок:
```bash
antigen@deb11notepad:~/netology/15$ kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
deployment.apps/web-consumer created
deployment.apps/auth-db created
service/auth-db created
```
Смотрим логи:
```bash
antigen@deb11notepad:~/netology/15$ kubectl -n web logs deployments/web-consumer
Found 2 pods, using pod/web-consumer-577d47b97d-bn6fp
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
antigen@deb11notepad:~/netology/15$ kubectl -n data logs deployments/auth-db
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
```
Проблема на поверхности: поды находятся в разных нэймспейсах и не могут увидеть друг друга.

Возможные решения:
- Самый очевидный способ исправления - это перенести все приложения в один неймспейс. Это не наш метод :)
- Создать сервис, который расскажет о существовании приложения веб-консамеру

Скачиваем манифест:
```bash
antigen@deb11notepad:~/netology/15$ curl -k https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml -O
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   937  100   937    0     0   1342      0 --:--:-- --:--:-- --:--:--  1342
```
Приводим к виду:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-consumer
  namespace: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-consumer
  template:
    metadata:
      labels:
        app: web-consumer
    spec:
      containers:
      - command:
        - sh
        - -c
        - while true; do curl auth-db; sleep 5; done
        image: radial/busyboxplus:curl
        name: busybox
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-db
  namespace: data
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auth-db
  template:
    metadata:
      labels:
        app: auth-db
    spec:
      containers:
      - image: nginx:1.19.1
        name: nginx
        ports:
        - containerPort: 80
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: auth-db
  namespace: data
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: auth-db
---
apiVersion: v1
kind: Service
metadata:
  name: auth-db
  namespace: web
spec:
  type: ExternalName
  externalName: auth-db.data.svc.cluster.local
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: auth-db
```
Применяем манифест:
```bash
antigen@deb11notepad:~/netology/15$ kubectl apply -f task.yaml
deployment.apps/web-consumer unchanged
deployment.apps/auth-db unchanged
service/auth-db unchanged
service/auth-db created
```
Смотрим что получилось:
```bash
antigen@deb11notepad:~/netology/15$ kubectl -n data get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/auth-db-795c96cddc-8dhds   1/1     Running   0          24m

NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/auth-db   ClusterIP   10.152.183.126   <none>        80/TCP    24m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/auth-db   1/1     1            1           24m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/auth-db-795c96cddc   1         1         1       24m
antigen@deb11notepad:~/netology/15$ kubectl -n web get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/web-consumer-577d47b97d-bn6fp   1/1     Running   0          25m
pod/web-consumer-577d47b97d-sw6l7   1/1     Running   0          25m

NAME              TYPE           CLUSTER-IP   EXTERNAL-IP                      PORT(S)   AGE
service/auth-db   ExternalName   <none>       auth-db.data.svc.cluster.local   80/TCP    16m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-consumer   2/2     2            2           25m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/web-consumer-577d47b97d   2         2         2       25m
```
Смотрим логи:
```bash
antigen@deb11notepad:~/netology/15$ kubectl -n data logs deployments/auth-db
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
10.1.86.194 - - [07/Jun/2023:16:28:48 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.35.0" "-"
10.1.86.245 - - [07/Jun/2023:16:28:48 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.35.0" "-"
10.1.86.245 - - [07/Jun/2023:16:28:53 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.35.0" "-"
10.1.86.194 - - [07/Jun/2023:16:28:53 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.35.0" "-"
10.1.86.245 - - [07/Jun/2023:16:28:58 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.35.0" "-"
10.1.86.194 - - [07/Jun/2023:16:28:58 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.35.0" "-"
```
