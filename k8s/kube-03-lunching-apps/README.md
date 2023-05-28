# Домашнее задание к занятию «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

> 1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
> 2. После запуска увеличить количество реплик работающего приложения до 2.
> 3. Продемонстрировать количество подов до и после масштабирования.
> 4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
> 5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

Манифест `deployment.yaml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: main
  name: main
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
  template:
    metadata:
      labels:
        app: main
    spec:
      containers:
        - image: nginx:1.19.1
          ports:
            - containerPort: 80
              name: web
              protocol: TCP
          name: nginx
          imagePullPolicy: IfNotPresent
        - image: wbitt/network-multitool
          name: multitool
          env:
            - name: HTTP_PORT
              value: '1180'
            - name: HTTPS_PORT
              value: '11443'
          imagePullPolicy: IfNotPresent
```
Запускаем деплой:
```bash
antigen@deb11notepad:~/netology/03$ kubectl create -f deployment.yml
deployment.apps/main created
antigen@deb11notepad:~/netology/03$ kubectl get pods
NAME                   READY   STATUS              RESTARTS   AGE
main-b967cfc59-bt9n7   0/2     ContainerCreating   0          6s
antigen@deb11notepad:~/netology/03$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
main-b967cfc59-bt9n7   2/2     Running   0          10s
```
Меняем в `deployment.yaml` значение `replicas` на 2. Смотрим:
```bash
antigen@deb11notepad:~/netology/03$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
main-b967cfc59-bt9n7   2/2     Running   0          7m23s
main-b967cfc59-lfl6c   2/2     Running   0          29s
```
Создал манифест для сервиса:
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: my-svc
  namespace: default
spec:
  ports:
    - name: nginx-http
      port: 80
    - name: nginx-https
      port: 443
    - name: multitool-http
      port: 1180
    - name: multitool-https
      port: 11443
  selector:
    app: main
```
Применил этот конфиг:
```bash
antigen@deb11notepad:~/netology/03$ kubectl apply -f service.yaml
service/my-svc created
```
Смотрю, что получилось:
```bash
antigen@deb11notepad:~/netology/03$ kubectl get deployments,svc,pods -o wide
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                                 SELECTOR
deployment.apps/main   2/2     2            2           21m   nginx,multitool   nginx:1.19.1,wbitt/network-multitool   app=main

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                             AGE     SELECTOR
service/kubernetes   ClusterIP   10.152.183.1    <none>        443/TCP                             3d17h   <none>
service/my-svc       ClusterIP   10.152.183.96   <none>        80/TCP,443/TCP,1180/TCP,11443/TCP   5m14s   app=main

NAME                       READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/main-b967cfc59-bt9n7   2/2     Running   0          21m   10.1.86.213   deb11notepad   <none>           <none>
pod/main-b967cfc59-lfl6c   2/2     Running   0          14m   10.1.86.214   deb11notepad   <none>           <none>
```
Листинг `pod.yaml`:
```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: multitool
  namespace: default
  labels:
    app: multitool
spec:
  containers:
    - name: multitool
      image: wbitt/network-multitool
```
Запускаю отдельный `pod` `multitool`:
```bash
antigen@deb11notepad:~/netology/03$ kubectl apply -f pod.yaml
pod/multitool created
antigen@deb11notepad:~/netology/03$ kubectl get pods
NAME                   READY   STATUS    RESTARTS   AGE
main-b967cfc59-bt9n7   2/2     Running   0          27m
main-b967cfc59-lfl6c   2/2     Running   0          20m
multitool              1/1     Running   0          7s
```
Проверяем доступность из `multitool` до приложения:
```bash
antigen@deb11notepad:~/netology/03$ kubectl exec multitool -- curl 10.152.183.96
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   400k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

> 1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
> 2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
> 3. Создать и запустить Service. Убедиться, что Init запустился.
> 4. Продемонстрировать состояние пода до и после запуска сервиса.

Для начала активируем `DNS` в `microk8s`:
```bash
microk8s enable dns
```
Листинг `deployment.yaml`:
```bash
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx:1.19.1
          ports:
            - containerPort: 80
              name: web
              protocol: TCP
          name: nginx
          imagePullPolicy: IfNotPresent
      initContainers:
        - name: delay
          image: busybox
          command: ['sh', '-c', 'until nslookup nginx-service.default.svc.cluster.local; do echo Waiting for nginx-service! Sleep 3s!; sleep 3; done;']
```
Листинг `nginx-svc.yaml`:
```bash
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: default
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  selector:
    app: nginx
```
Создаем наш деплоймент, проверяем созданный под:
```bash
antigen@deb11notepad:~/netology/03$ kubectl create -f deployment.yml
deployment.apps/nginx created
antigen@deb11notepad:~/netology/03$ kubectl get deployments,svc,pods -o wide
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/nginx   0/1     1            0           13s   nginx        nginx:1.19.1   app=nginx

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   40m   <none>

NAME                         READY   STATUS     RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/nginx-7fff5475ff-xsv9q   0/1     Init:0/1   0          13s   10.1.86.247   deb11notepad   <none>           <none>
```
Запускаем сервис, но перед этим еще раз проверяем состояние пода:
```bash
antigen@deb11notepad:~/netology/03$ kubectl get deployments,svc,pods -o wide
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/nginx   0/1     1            0           23s   nginx        nginx:1.19.1   app=nginx

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes      ClusterIP   10.152.183.1    <none>        443/TCP   40m   <none>
service/nginx-service   ClusterIP   10.152.183.19   <none>        80/TCP    2s    app=nginx

NAME                         READY   STATUS            RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/nginx-7fff5475ff-xsv9q   0/1     PodInitializing   0          23s   10.1.86.247   deb11notepad   <none>           <none>
antigen@deb11notepad:~/netology/03$ kubectl apply -f nginx-nginx.yaml
service/nginx-service created
antigen@deb11notepad:~/netology/03$ kubectl get deployments,svc,pods -o wide
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/nginx   1/1     1            1           27s   nginx        nginx:1.19.1   app=nginx

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/kubernetes      ClusterIP   10.152.183.1    <none>        443/TCP   40m   <none>
service/nginx-service   ClusterIP   10.152.183.19   <none>        80/TCP    6s    app=nginx

NAME                         READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/nginx-7fff5475ff-xsv9q   1/1     Running   0          27s   10.1.86.247   deb11notepad   <none>           <none>
```
Под поднялся!