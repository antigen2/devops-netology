# Домашнее задание к занятию «Конфигурация приложений»

### Цель задания

В тестовой среде Kubernetes необходимо создать конфигурацию и продемонстрировать работу приложения.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8s).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым GitHub-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/configuration/secret/) Secret.
2. [Описание](https://kubernetes.io/docs/concepts/configuration/configmap/) ConfigMap.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

> 1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
> 2. Решить возникшую проблему с помощью ConfigMap.
> 3. Продемонстрировать, что pod стартовал и оба конейнера работают.
> 4. Сделать простую веб-страницу и подключить её к Nginx с помощью ConfigMap. Подключить Service и показать вывод curl или в браузере.
> 5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

Листинг `deployment.yml`:
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: main
  name: mydeploy
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
          envFrom:
            - configMapRef:
                name: my-configmap-multitool
          imagePullPolicy: IfNotPresent
        - image: busybox
          name: busybox
          command: ['sh', '-c', 'sleep infinity']
          imagePullPolicy: IfNotPresent
```
Листинг `cm-multitool.yml`:
```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap-multitool
data:
  HTTP_PORT: '8080'
  HTTPS_PORT: '8443'
```
Применяем последовательно и смотрим результат:
```bash
antigen@deb11notepad:~/netology/08$ kubectl apply -f deployment.yml
deployment.apps/mydeploy created
antigen@deb11notepad:~/netology/08$ kubectl get all
NAME                            READY   STATUS                       RESTARTS   AGE
pod/mydeploy-585487b768-j859n   1/2     CreateContainerConfigError   0          7s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mydeploy   0/1     1            0           7s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/mydeploy-585487b768   1         1         0       7s
antigen@deb11notepad:~/netology/08$ kubectl apply -f cm-multitool.yml
configmap/my-configmap-multitool created
antigen@deb11notepad:~/netology/08$ kubectl get all
NAME                            READY   STATUS    RESTARTS   AGE
pod/mydeploy-585487b768-j859n   2/2     Running   0          29s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mydeploy   1/1     1            1           29s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/mydeploy-585487b768   1         1         1       29s
```
Листинг `deployment-nginx.yml`:
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
        - image: nginx:1.23
          name: nginx
          ports:
            - containerPort: 80
              name: web
              protocol: TCP
            - containerPort: 443
              name: tls
              protocol: TCP
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: config
              mountPath: /etc/nginx/conf.d/
            - name: html
              mountPath: /usr/share/nginx/html
            - name: ssl
              mountPath: /etc/ssl
      volumes:
        - name: config
          configMap:
            name: my-configmap-nginx-conf
        - name: html
          configMap:
            name: my-configmap-nginx-html
        - name: ssl
          secret:
            secretName: my-secret
---
apiVersion: v1
kind: Service
metadata:
  name: my-svc
  namespace: default
spec:
  type: NodePort
  ports:
    - port: 9001
      targetPort: 80
      nodePort: 30080
      name: web1
    - port: 9002
      targetPort: 433
      nodePort: 30443
      name: tls2
  selector:
    app: main
```
Листинг `cm-nginx.yml`:
```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap-nginx-html
data:
  index.html: |
    <!DOCTYPE html>
    <html>
      <head>
        <title>Hello, World</title>
      </head>
      <body>
        "Hello, Netology!"
      </body>
    </html>

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap-nginx-conf
data:
  default.conf: |
    server {
      listen 80;
      server_name _;
      location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
      }
    }
    server {
      server_name _;
      listen 443 ssl;
      ssl_certificate /etc/ssl/nginx.crt;
      ssl_certificate_key /etc/ssl/nginx.key;
      location / {
        root /usr/share/nginx/html;
        index index.html;
      }
    }
---
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
stringData:
  nginx.key: |
    -----BEGIN PRIVATE KEY-----
    MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDFPQiDredhEOJC
    bmUWrqtuNSG4yn1TIvI2g+dRzePD3qZh5w3RP6GzCBS/xs/FdX3g5w/YKiYmgoJA
    EIcL247YIVv6w9oOgnMjkYBJ8OoG9MOrg64i1iGK7TylVfSLwHXyMcYdEu/+SsNI
    DSaU2uhjn6mqAkgwo+6TFnr4YgQjfYCLxAjfliEP7rhIRZIGmsd3SLPF+spJm9jL
    PlM0S9qmkIRfN8Hcb6/7YHLjivTGGqKdlCMNgjmR63AFn/NabPEbs878kWYNR1XN
    ElBAOb8YjxVXtvE4SGkqCDyt95i9L4lVLwVJekrWU58I/H95HJCylZKX20o+Pxx3
    +trNGenVAgMBAAECggEBAIwepdPWUY/1jKehAZOxlvv+Juy+fXX4V5Y+8rB80hgu
    LolSudAzok4rqYHsXWJr63dA71Kj7uJgyON2WlokKkCEwnFNfbXdGqrkDP16dudm
    LzPDoowBD2dAzlquy8IUgjYDAjlZYMGIn16qaQRK19kebkvmvx4+95fq2oVmLIaA
    uzQfIJsxTyS/DBpnIb/ZIPIHpni4F7VxlDxdW3M6TkIZkXNkZctgPoSO17LeF7pX
    gntv3EJtK2tlF/tM7wGGwdLiMiCifIvVgYYiPD9PixQK3+HiLkNWqu8SNXLEhoYe
    Lp2ZzzdQEOTXFgGJRI8m2/2gpbHVw526ozdHO8GNkwECgYEA+XAKRsfeqDqhVpha
    jDaTGrj7rBGcKHG0orCywz6zoJyvJu7PzuRmHwt59Q6r/RIChqhZ75l9MSH26hDk
    s0rxZG23jgpEbAp9VsRUasFIAUb+2xX/EKmK3947bDpIjGV+O9xMNKwD8Rr4mApu
    vtbI42D4vzfk71sDUWuLHTaT6TUCgYEAym1uiNF9dfZyP/7LAm5fGMs66kvlC+8w
    FFfVeXTJpnTFwQA/hHjP/HvUhV24H27y8hkWOGlKKUKn0oazeUDnk7VuJPn5JpSC
    rxlCukIOC7OvSJqKfdnP4LwmhnVd0ScopkCiQf/VsZUKwVuSFbRxMqIYrZNMqaxV
    wIC9GVqasiECgYBlZqim0YWwefUwkMruiRkQGfclohsLTf4SzSY+vPSk7E0/1IFi
    J/Nj13SCrK46OOIR/8pf3tPH73jC+o8eW+751qhx87aQ/UqqxTFUHLK64jOkuLJy
    AZpVG7CodKEdgfzpNMs99le74i0BEeynZAVSeg9lHMHSk/srVD6/Z3qFqQKBgFFa
    x7i/EQAuyt4DZc2VVCzfyM7PL7+rIpSadFY65Kw8dBnMIrr33wcnMVNkRhKEAanh
    ATgswLxyaIZI0qqhtjB8E0dTG5owx5Ddwx6eW4zCa2jvi0dnGY/FrmoNk2Xyqfif
    M1b5HgYf01HAnqaQfYoO8YIZGA99Dn2uf9FHw7JhAoGBALS+3ffepFopJQjRkzQm
    KLoer+03ojb8MdqRd3yFSSAeN+EnCsYYaW/aI5E62TkwSznukusV/XW4EVpsHYqx
    FWEdCk5zT2J1qRZmH9NuADPG3IOake5nzzEgmkd9+kxbztn4iUdhpAr9ONs3hW9+
    6ONM1dLvFChHLo6o33yRUCsZ
    -----END PRIVATE KEY-----
  nginx.crt: |
    -----BEGIN CERTIFICATE-----
    MIIDazCCAlOgAwIBAgIULI61bS02Sa2i2/9FZQj3o+N3MT4wDQYJKoZIhvcNAQEL
    BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
    GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMzA1MjUxNzIxMDlaFw0yNDA1
    MjQxNzIxMDlaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
    HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
    AQUAA4IBDwAwggEKAoIBAQDFPQiDredhEOJCbmUWrqtuNSG4yn1TIvI2g+dRzePD
    3qZh5w3RP6GzCBS/xs/FdX3g5w/YKiYmgoJAEIcL247YIVv6w9oOgnMjkYBJ8OoG
    9MOrg64i1iGK7TylVfSLwHXyMcYdEu/+SsNIDSaU2uhjn6mqAkgwo+6TFnr4YgQj
    fYCLxAjfliEP7rhIRZIGmsd3SLPF+spJm9jLPlM0S9qmkIRfN8Hcb6/7YHLjivTG
    GqKdlCMNgjmR63AFn/NabPEbs878kWYNR1XNElBAOb8YjxVXtvE4SGkqCDyt95i9
    L4lVLwVJekrWU58I/H95HJCylZKX20o+Pxx3+trNGenVAgMBAAGjUzBRMB0GA1Ud
    DgQWBBT2a8sMcBTfItXnT0LJuI/WJnnmoDAfBgNVHSMEGDAWgBT2a8sMcBTfItXn
    T0LJuI/WJnnmoDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBn
    gbUPP5uYrVEGOXBoKBAFTrd9xspi3NFbSPjNNJRlBoYnJUMOglXM62MNr8CdxOS3
    yZUdODFfI8BKgXMEakJUCAkKSNfNfK+ucIgT2xtzwPWVngrTh9sAfOngXKySo0kE
    oEX09Ip6J5BL8DNzTCZTfC5hoxTjie7VzHidBiyPOMGiYNMBYpvlA4blHxVHkGc1
    gzD2SW775TK/zMiHnzvkY+oRmdSWAnjTCzC7xUQtEdGgh/QcEd9w4hsY2bpjbpBb
    GHaKKQdqApSYxo+XxK2Ahfv441ZGzcSLpF+vKykBDBSNRS78g05yg0INC/bGXWUG
    YVi/xlNe331J1xj67mcj
    -----END CERTIFICATE-----
```
Сертификаты создал заранее:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```
Применяем конфиги, смотрим результат:
```bash
antigen@deb11notepad:~/netology/08$ kubectl apply -f deployment-nginx.yml
deployment.apps/main created
service/my-svc created
antigen@deb11notepad:~/netology/08$ kubectl apply -f cm-nginx.yml
configmap/my-configmap-nginx-html unchanged
configmap/my-configmap-nginx-conf unchanged
secret/my-secret configured
antigen@deb11notepad:~/netology/08$ kubectl get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/main-566c66cc7f-g22k5   1/1     Running   0          19s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP                         178m
service/my-svc       NodePort    10.152.183.110   <none>        9001:30080/TCP,9002:30443/TCP   19s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/main   1/1     1            1           19s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/main-566c66cc7f   1         1         1       19s
```
Проверяем:
```commandline
C:\Users\admin>curl 192.168.3.210:30080
<!DOCTYPE html>
<html>
  <head>
    <title>Hello, World</title>
  </head>
  <body>
    "Hello, Netology!"
  </body>
</html>
```

------

### Задание 2. Создать приложение с вашей веб-страницей, доступной по HTTPS 

> 1. Создать Deployment приложения, состоящего из Nginx.
> 2. Создать собственную веб-страницу и подключить её как ConfigMap к приложению.
> 3. Выпустить самоподписной сертификат SSL. Создать Secret для использования сертификата.
> 4. Создать Ingress и необходимый Service, подключить к нему SSL в вид. Продемонстировать доступ к приложению по HTTPS. 
> 5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

Кое-что сделал раньше, повторюсь. \
Сертификаты создал заранее:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```
Листинг `deployment-nginx-2.yml`:
```yaml
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
        - image: nginx:1.23
          name: nginx
          ports:
            - containerPort: 443
              name: tls
              protocol: TCP
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - name: config
              mountPath: /etc/nginx/conf.d/
            - name: html
              mountPath: /usr/share/nginx/html
            - name: ssl
              mountPath: /etc/ssl
      volumes:
        - name: config
          configMap:
            name: my-configmap-nginx-conf
        - name: html
          configMap:
            name: my-configmap-nginx-html
        - name: ssl
          secret:
            secretName: my-secret
---
apiVersion: v1
kind: Service
metadata:
  name: my-svc
  namespace: default
spec:
  ports:
    - name: nginx-https
      port: 443
  selector:
    app: main
```
Листинг `ingress.yml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: https-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
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
              name: nginx-https
              #number: 443
```

Применяем и смотрим, что получилось:
```bash
antigen@deb11notepad:~/netology/08$ kubectl apply -f cm-nginx.yml
configmap/my-configmap-nginx-html unchanged
configmap/my-configmap-nginx-conf unchanged
secret/my-secret configured
antigen@deb11notepad:~/netology/08$ kubectl apply -f deployment-nginx-2.yml
deployment.apps/my-nginx created
service/my-svc unchanged
antigen@deb11notepad:~/netology/08$ kubectl apply -f ingress.yml
ingress.networking.k8s.io/https-ingress created
antigen@deb11notepad:~/netology/08$ kubectl get all -o wide
NAME                         READY   STATUS    RESTARTS   AGE     IP            NODE           NOMINATED NODE   READINESS GATES
pod/backend-dcfdff59-c7zgp   1/1     Running   0          2m37s   10.1.86.195   deb11notepad   <none>           <none>

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/my-svc       ClusterIP   10.152.183.184   <none>        443/TCP   14m     app=main
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP   9m39s   <none>

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES       SELECTOR
deployment.apps/backend   1/1     1            1           2m37s   nginx        nginx:1.23   app=main

NAME                               DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES       SELECTOR
replicaset.apps/backend-dcfdff59   1         1         1       2m37s   nginx        nginx:1.23   app=main,pod-template-hash=dcfdff59
```
Проверяем с виндовой машины:
```commandline
C:\Users\admin>curl -k https://192.168.3.210
<!DOCTYPE html>
<html>
  <head>
    <title>Hello, World</title>
  </head>
  <body>
    "Hello, Netology!"
  </body>
</html>
```

------
