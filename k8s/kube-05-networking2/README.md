# Домашнее задание к занятию «Сетевое взаимодействие в K8S. Часть 2»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Service.
3. [Описание](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress.
4. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложений backend и frontend

> 1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
> 2. Создать Deployment приложения _backend_ из образа multitool. 
> 3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
> 4. Продемонстрировать, что приложения видят друг друга с помощью Service.
> 5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

Манифест `deployment.yaml`
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: main
  name: frontend
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
        - image: nginx:1.23
          ports:
            - containerPort: 80
              name: web
              protocol: TCP
          name: nginx
          imagePullPolicy: IfNotPresent

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: main
  name: backend
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
        - image: wbitt/network-multitool
          name: multitool
          env:
            - name: HTTP_PORT
              value: '8080'
            - name: HTTPS_PORT
              value: '8443'
          imagePullPolicy: IfNotPresent

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
      port: 8080
    - name: multitool-https
      port: 8443
  selector:
    app: main
```
Приминение манифеста и просмотр результата:
```bash
antigen@deb11notepad:~/netology/05$ kubectl apply -f deployment.yaml
deployment.apps/frontend created
deployment.apps/backend created
service/my-svc created
antigen@deb11notepad:~/netology/05$ kubectl get all -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
pod/frontend-5ff8c86dd7-d67jg   1/1     Running   0          3m12s   10.1.86.249   deb11notepad   <none>           <none>
pod/frontend-5ff8c86dd7-kmfdt   1/1     Running   0          3m12s   10.1.86.251   deb11notepad   <none>           <none>
pod/frontend-5ff8c86dd7-5nk85   1/1     Running   0          3m12s   10.1.86.241   deb11notepad   <none>           <none>
pod/backend-8444d5778c-ldx75    1/1     Running   0          3m12s   10.1.86.250   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                            AGE     SELECTOR
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP                            5d2h    <none>
service/my-svc       ClusterIP   10.152.183.141   <none>        80/TCP,443/TCP,8080/TCP,8443/TCP   3m12s   app=main

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                    SELECTOR
deployment.apps/frontend   3/3     3            3           3m12s   nginx        nginx:1.23                app=main
deployment.apps/backend    1/1     1            1           3m12s   multitool    wbitt/network-multitool   app=main

NAME                                  DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES                    SELECTOR
replicaset.apps/frontend-5ff8c86dd7   3         3         3       3m12s   nginx        nginx:1.23                app=main,pod-template-hash=5ff8c86dd7
replicaset.apps/backend-8444d5778c    1         1         1       3m12s   multitool    wbitt/network-multitool   app=main,pod-template-hash=8444d5778c
```
Проверяем доступность приложений через сервис:
```bash
antigen@deb11notepad:~/netology/05$ kubectl exec deployments/frontend -- curl my-svc:8080
WBITT Network MultiTool (with NGINX) - backend-8444d5778c-ldx75 - 10.1.86.250 - HTTP: 8080 , HTTPS: 8443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   143  100   143    0     0  71500      0 --:--:-- --:--:-- --:--:-- 71500
antigen@deb11notepad:~/netology/05$
antigen@deb11notepad:~/netology/05$
antigen@deb11notepad:~/netology/05$
antigen@deb11notepad:~/netology/05$ kubectl exec deployments/backend -- curl my-svc:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   300k      0 --:--:-- --:--:-- --:--:--  300k
```
------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

> 1. Включить Ingress-controller в MicroK8S.
> 2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
> 3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
> 4. Предоставить манифесты и скриншоты или вывод команды п.2.

Включаем Ingress-controller в MicroK8S
```bash
microk8s enable ingress
```
Создаем манифест:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: http-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-svc
            port:
              name: nginx-http
              #number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: my-svc
            port:
              name: multitool-http
              #number: 8080
```
Применяем и проверяем внутри ВМ:
```bash
antigen@deb11notepad:~/netology/05$ kubectl apply -f ingress.yaml
ingress.networking.k8s.io/http-ingress configured
antigen@deb11notepad:~/netology/05$ curl localhost/api
WBITT Network MultiTool (with NGINX) - backend-8444d5778c-f4dvb - 10.1.86.204 - HTTP: 8080 , HTTPS: 8443 . (Formerly praqma/network-multitool)
antigen@deb11notepad:~/netology/05$
antigen@deb11notepad:~/netology/05$ curl localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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
Проверяем снуружи:
```cmd
C:\Users\admin>curl 192.168.3.210
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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

C:\Users\admin>curl 192.168.3.210/api
WBITT Network MultiTool (with NGINX) - backend-8444d5778c-f4dvb - 10.1.86.204 - HTTP: 8080 , HTTPS: 8443 . (Formerly praqma/network-multitool)
```

------