# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

> 1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
> 2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
> 3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
> 4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
> 5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

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
  replicas: 3
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
              value: '8080'
          imagePullPolicy: IfNotPresent
```
Манифест `service.yaml`:
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
      port: 9001
      targetPort: 80
    - name: multitool-http
      port: 9002
      targetPort: 8080
  selector:
    app: main
```
Манифест `pod.yaml`:
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
Запускаем сервис и деплоймент, смотрим результат:
```bash
antigen@deb11notepad:~/netology/04$ kubectl apply -f deployment.yaml
deployment.apps/main created
antigen@deb11notepad:~/netology/04$ kubectl apply -f service.yaml
service/my-svc created
antigen@deb11notepad:~/netology/04$ kubectl get deployments,svc,pods -o wide
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                                 SELECTOR
deployment.apps/main   3/3     3            3           12s   nginx,multitool   nginx:1.19.1,wbitt/network-multitool   app=main

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP             25h   <none>
service/my-svc       ClusterIP   10.152.183.179   <none>        9001/TCP,9002/TCP   5s    app=main

NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/main-6f6b7c4c4b-ptwq2   2/2     Running   0          12s   10.1.86.248   deb11notepad   <none>           <none>
pod/main-6f6b7c4c4b-tdvqs   2/2     Running   0          12s   10.1.86.250   deb11notepad   <none>           <none>
pod/main-6f6b7c4c4b-lxfdc   2/2     Running   0          12s   10.1.86.249   deb11notepad   <none>           <none>
```
Создаем отдельно `multitool` и смотрим все что запустилось:
```bash
antigen@deb11notepad:~/netology/04$ kubectl apply -f pod.yaml
pod/multitool created
antigen@deb11notepad:~/netology/04$ kubectl get deployments,svc,pods -o wide
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                                 SELECTOR
deployment.apps/main   3/3     3            3           44s   nginx,multitool   nginx:1.19.1,wbitt/network-multitool   app=main

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP             25h   <none>
service/my-svc       ClusterIP   10.152.183.179   <none>        9001/TCP,9002/TCP   37s   app=main

NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
pod/main-6f6b7c4c4b-ptwq2   2/2     Running   0          44s   10.1.86.248   deb11notepad   <none>           <none>
pod/main-6f6b7c4c4b-tdvqs   2/2     Running   0          44s   10.1.86.250   deb11notepad   <none>           <none>
pod/main-6f6b7c4c4b-lxfdc   2/2     Running   0          44s   10.1.86.249   deb11notepad   <none>           <none>
pod/multitool               1/1     Running   0          14s   10.1.86.251   deb11notepad   <none>           <none>
```
Проверяем оба порта:
```bash
antigen@deb11notepad:~/netology/04$ kubectl exec -it multitool -- curl my-svc:9001
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
antigen@deb11notepad:~/netology/04$
antigen@deb11notepad:~/netology/04$
antigen@deb11notepad:~/netology/04$ kubectl exec -it multitool -- curl my-svc:9002
WBITT Network MultiTool (with NGINX) - main-6f6b7c4c4b-tdvqs - 10.1.86.250 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
antigen@deb11notepad:~/netology/04$
```
------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

> 1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
> 2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
> 3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

Листинг `service-nodeport.yaml`:
```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: my-external-svc
  namespace: default
spec:
  type: NodePort
  ports:
    - name: nginx-http
      port: 9001
      targetPort: 80
      protocol: TCP
      nodePort: 30080
  selector:
    app: main
```
Вывод `curl`:
```cmd
C:\Users\admin>curl http://192.168.3.210:30080/
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

C:\Users\admin>
```
Скрин:
![](img/01.png)
